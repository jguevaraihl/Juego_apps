import 'dart:math';

import 'board/board_ops.dart';
import 'economy/economy.dart';
import 'economy/economy_config.dart';
import 'game_events.dart';
import 'models/board.dart';
import 'models/board_item.dart';
import 'models/game_state.dart';
import 'models/order.dart';
import 'models/product.dart';
import 'models/settings.dart';
import 'orders/order_generator.dart';
import 'progression/shop_tiers.dart';

/// Resultado de aplicar una acción: el estado siguiente y lo que pasó.
class GameStep {
  const GameStep(this.state, [this.events = const <GameEvent>[]]);

  final GameState state;
  final List<GameEvent> events;

  bool get changed => events.isNotEmpty;
}

/// Motor de juego: función pura de (estado, acción) → (estado, eventos).
///
/// No toca disco, ni reloj global, ni Flutter. Todo el azar entra por la
/// semilla persistida en [GameState.rngSeed], así que una partida es
/// reproducible y los tests no son flaky.
class GameEngine {
  GameEngine({EconomyConfig? config})
    : config = config ?? EconomyConfig.defaults,
      economy = Economy(config ?? EconomyConfig.defaults) {
    generator = OrderGenerator(economy: economy);
  }

  final EconomyConfig config;
  final Economy economy;
  late final OrderGenerator generator;

  // --------------------------------------------------------------------
  // Azar determinista
  // --------------------------------------------------------------------

  /// Cota superior de la semilla siguiente.
  ///
  /// Se escribe como literal a propósito: en la web los enteros de Dart son
  /// doubles de JS y los operadores de bits son de 32 bits, así que `1 << 32`
  /// se desborda a 0 y `nextInt(0)` lanza RangeError. Un literal se comporta
  /// igual en la VM y en la web.
  static const int _seedBound = 0x7FFFFFFF;

  /// Ejecuta [body] con un [Random] derivado de la semilla del estado y
  /// devuelve la semilla siguiente, para que cada acción avance el flujo.
  (T, int) _withRng<T>(int seed, T Function(Random rng) body) {
    final Random rng = Random(seed);
    final T result = body(rng);
    return (result, rng.nextInt(_seedBound));
  }

  // --------------------------------------------------------------------
  // Ciclo de vida
  // --------------------------------------------------------------------

  /// Partida nueva, con los pedidos iniciales ya generados.
  GameStep newGame({required DateTime now, int? seed}) {
    final GameState base = GameState.initial(
      config: config,
      now: now,
      rngSeed: seed ?? now.microsecondsSinceEpoch & 0x7fffffff,
    );
    return GameStep(_refillOrders(base));
  }

  /// Se llama al cargar una partida guardada. Calcula la ganancia pasiva,
  /// rellena pedidos faltantes y garantiza que el jugador tenga salida.
  GameStep resume({required GameState state, required DateTime now}) {
    final List<GameEvent> events = <GameEvent>[];
    GameState next = _refillOrders(state);

    final int earnings = economy.offlineEarnings(
      elapsed: now.difference(state.lastSeenAt),
      coinsPerHour: next.shopTier.coinsPerHour,
    );
    if (earnings >= config.offlineMinClaim) {
      next = next.copyWith(coins: next.coins + earnings);
      events.add(OfflineEarningsClaimed(earnings));
    }

    next = next.copyWith(lastSeenAt: now);
    final GameStep relieved = relieveIfStuck(next);
    return GameStep(relieved.state, <GameEvent>[...events, ...relieved.events]);
  }

  /// Cuánto se acumularía si el jugador volviera en [now], sin aplicarlo.
  int previewOfflineEarnings(GameState state, DateTime now) =>
      economy.offlineEarnings(
        elapsed: now.difference(state.lastSeenAt),
        coinsPerHour: state.shopTier.coinsPerHour,
      );

  // --------------------------------------------------------------------
  // Acciones
  // --------------------------------------------------------------------

  /// Toca la caja del proveedor: cuesta monedas y deja un producto base.
  GameStep generate(GameState state) {
    if (state.board.isFull) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.boardFull),
      ]);
    }
    if (state.coins < config.generateCost) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.notEnoughCoins),
      ]);
    }

    final int playerLevel = state.playerLevel(economy);
    final List<ProductChain> unlocked = ProductCatalog.unlockedFor(playerLevel);

    final ((Board, String), int) result = _withRng(state.rngSeed, (Random rng) {
      final ProductChain chain = unlocked[rng.nextInt(unlocked.length)];
      final BoardItem item = BoardItem(
        id: state.nextItemId,
        chainId: chain.id,
        level: 1,
      );
      final Board? placed = BoardOps.place(
        state.board,
        item,
        (List<int> free) => rng.nextInt(free.length),
      );
      return (placed ?? state.board, chain.id);
    });

    final (Board board, String chainId) = result.$1;
    final int nextSeed = result.$2;

    GameState next = state.copyWith(
      board: board,
      coins: state.coins - config.generateCost,
      nextItemId: state.nextItemId + 1,
      rngSeed: nextSeed,
    );

    final List<GameEvent> events = <GameEvent>[ItemGenerated(chainId)];
    next = _markDiscovered(next, chainId, 1, events);
    return GameStep(next, events);
  }

  /// Arrastrar y soltar: mover, fusionar o intercambiar.
  GameStep drop(GameState state, int from, int to) {
    final DropResult result = BoardOps.drop(
      board: state.board,
      from: from,
      to: to,
      nextItemId: state.nextItemId,
    );
    if (!result.changed) return GameStep(state);

    GameState next = state.copyWith(
      board: result.board,
      nextItemId: result.nextItemId,
    );
    final List<GameEvent> events = <GameEvent>[];

    if (result.kind == DropKind.merge) {
      final BoardItem merged = result.mergedItem!;
      next = next.copyWith(totalMerges: next.totalMerges + 1);
      events.add(MergeCompleted(merged.chainId, merged.level));
      next = _markDiscovered(next, merged.chainId, merged.level, events);
      if (next.tutorialStep == TutorialStep.merge) {
        next = next.copyWith(tutorialStep: TutorialStep.completeOrder);
        events.add(const TutorialAdvanced());
      }
    }

    return GameStep(next, events);
  }

  /// Vender un excedente. Paga menos que generar, así que no es una fuente de
  /// ingreso: es una válvula de escape para liberar casillas.
  GameStep sell(GameState state, int index) {
    final BoardItem? item = state.board.at(index);
    if (item == null) return GameStep(state);

    final int value = economy.sellValue(item.level);
    final GameState next = state.copyWith(
      board: BoardOps.removeAt(state.board, index),
      coins: state.coins + value,
    );
    return GameStep(next, <GameEvent>[ItemSold(value)]);
  }

  /// Entregar un pedido. Es atómico: si falta algo, no consume nada.
  GameStep completeOrder(
    GameState state,
    int orderId, {
    bool withBonus = false,
  }) {
    final int position = state.orders.indexWhere(
      (CustomerOrder o) => o.id == orderId,
    );
    if (position < 0) return GameStep(state);

    final CustomerOrder order = state.orders[position];
    final Board? consumed = BoardOps.consumeOrder(state.board, order);
    if (consumed == null) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.orderNotReady),
      ]);
    }

    final bool bonus = withBonus && order.isSpecial;
    final int reward = bonus
        ? economy.orderBonusReward(order.reward)
        : order.reward;

    final int levelBefore = state.playerLevel(economy);

    GameState next = state.copyWith(
      board: consumed,
      coins: state.coins + reward,
      xp: state.xp + order.xp,
      totalOrdersCompleted: state.totalOrdersCompleted + 1,
    );

    final List<GameEvent> events = <GameEvent>[
      OrderCompleted(reward: reward, xp: order.xp, withBonus: bonus),
    ];

    if (next.tutorialStep == TutorialStep.completeOrder) {
      next = next.copyWith(tutorialStep: TutorialStep.upgrade);
      events.add(const TutorialAdvanced());
    }

    next = _applyLevelUps(next, levelBefore, events);
    // El pedido nuevo ocupa el hueco del entregado, no el final de la fila.
    next = _replaceOrderAt(next, position);
    next = _refillOrders(next);
    return GameStep(next, events);
  }

  /// Cambiar un pedido que no conviene. Cuesta monedas para que sea una
  /// decisión, no un botón gratis de "saltar contenido".
  GameStep rerollOrder(GameState state, int orderId) {
    final int position = state.orders.indexWhere(
      (CustomerOrder o) => o.id == orderId,
    );
    if (position < 0) return GameStep(state);

    final int cost = economy.rerollCost(state.orders[position].reward);
    if (state.coins < cost) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.notEnoughCoins),
      ]);
    }

    final GameState next = _replaceOrderAt(
      state.copyWith(coins: state.coins - cost),
      position,
    );
    return GameStep(next, <GameEvent>[OrderRerolled(cost)]);
  }

  /// Mejorar el local. Es la meta visible de largo plazo.
  GameStep upgradeShop(GameState state) {
    final ShopTier? target = ShopTiers.next(state.shopLevel);
    if (target == null) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.maxShopLevel),
      ]);
    }
    if (state.coins < target.upgradeCost) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.notEnoughCoins),
      ]);
    }

    GameState next = state.copyWith(
      coins: state.coins - target.upgradeCost,
      shopLevel: target.level,
    );
    final List<GameEvent> events = <GameEvent>[ShopUpgraded(target.level)];

    if (next.tutorialStep == TutorialStep.upgrade) {
      next = next.copyWith(tutorialStep: TutorialStep.done);
      events.add(const TutorialAdvanced());
    }
    return GameStep(next, events);
  }

  GameStep updateSettings(GameState state, GameSettings settings) =>
      GameStep(state.copyWith(settings: settings));

  GameStep skipTutorial(GameState state) => GameStep(
    state.copyWith(tutorialStep: TutorialStep.done),
    const <GameEvent>[TutorialAdvanced()],
  );

  GameStep touch(GameState state, DateTime now) =>
      GameStep(state.copyWith(lastSeenAt: now));

  // --------------------------------------------------------------------
  // Garantía de no bloqueo (PLAN_FINAL §3.2)
  // --------------------------------------------------------------------

  /// ¿Le queda al jugador alguna jugada que haga avanzar la partida?
  bool canMakeProgress(GameState state) {
    if (state.board.hasPossibleMerge()) return true;
    if (!state.board.isFull && state.coins >= config.generateCost) return true;
    if (state.orders.any((CustomerOrder o) => o.isSatisfiedBy(state.board))) {
      return true;
    }
    // Vender libera casillas y da monedas: sirve mientras quede algo que vender.
    if (!state.board.isEmpty) return true;
    return false;
  }

  /// Si no queda ninguna salida, el proveedor fía lo justo para seguir.
  /// Nunca se cobra ni se condiciona a ver un anuncio.
  GameStep relieveIfStuck(GameState state) {
    if (canMakeProgress(state)) return GameStep(state);
    final int amount = config.generateCost * config.emergencyGenerations;
    return GameStep(state.copyWith(coins: state.coins + amount), <GameEvent>[
      EmergencyRelief(amount),
    ]);
  }

  // --------------------------------------------------------------------
  // Helpers internos
  // --------------------------------------------------------------------

  /// Crea un pedido nuevo y devuelve el estado con el contador y la semilla
  /// ya avanzados.
  (CustomerOrder, GameState) _makeOrder(GameState state) {
    final (CustomerOrder order, int seed) = _withRng(
      state.rngSeed,
      (Random rng) => generator.generate(
        id: state.nextOrderId,
        playerLevel: state.playerLevel(economy),
        rng: rng,
      ),
    );
    return (
      order,
      state.copyWith(nextOrderId: state.nextOrderId + 1, rngSeed: seed),
    );
  }

  /// Reemplaza el pedido de [position] por uno nuevo **en la misma posición**.
  ///
  /// Importante que sea en el mismo lugar: si se quitara de la lista y el
  /// nuevo se agregara al final, los otros dos pedidos se correrían y en
  /// pantalla parecería que cambiaron los tres.
  GameState _replaceOrderAt(GameState state, int position) {
    final (CustomerOrder order, GameState next) = _makeOrder(state);
    final List<CustomerOrder> orders = List<CustomerOrder>.of(next.orders);
    orders[position] = order;
    return next.copyWith(orders: orders);
  }

  /// Mantiene siempre [EconomyConfig.visibleOrders] pedidos en pantalla.
  GameState _refillOrders(GameState state) {
    if (state.orders.length >= config.visibleOrders) return state;

    final int playerLevel = state.playerLevel(economy);
    final List<CustomerOrder> orders = List<CustomerOrder>.of(state.orders);
    int nextOrderId = state.nextOrderId;
    int seed = state.rngSeed;

    while (orders.length < config.visibleOrders) {
      final (CustomerOrder order, int newSeed) = _withRng(
        seed,
        (Random rng) => generator.generate(
          id: nextOrderId,
          playerLevel: playerLevel,
          rng: rng,
        ),
      );
      orders.add(order);
      nextOrderId++;
      seed = newSeed;
    }

    return state.copyWith(
      orders: orders,
      nextOrderId: nextOrderId,
      rngSeed: seed,
    );
  }

  /// Emite subidas de nivel y desbloqueos de cadena entre dos niveles.
  GameState _applyLevelUps(
    GameState state,
    int levelBefore,
    List<GameEvent> events,
  ) {
    final int levelAfter = state.playerLevel(economy);
    if (levelAfter <= levelBefore) return state;

    for (int level = levelBefore + 1; level <= levelAfter; level++) {
      events.add(PlayerLeveledUp(level));
      for (final ProductChain chain in ProductCatalog.chains) {
        if (chain.unlockPlayerLevel == level) {
          events.add(ChainUnlocked(chain.id));
        }
      }
    }
    return state;
  }

  /// Registra un producto en el álbum la primera vez que se ve.
  GameState _markDiscovered(
    GameState state,
    String chainId,
    int level,
    List<GameEvent> events,
  ) {
    final String key = '$chainId:$level';
    if (state.discovered.contains(key)) return state;
    events.add(ProductDiscovered(chainId, level));
    return state.copyWith(discovered: <String>{...state.discovered, key});
  }
}
