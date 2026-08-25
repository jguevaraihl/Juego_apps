import 'dart:math';
import 'dart:math' as math;

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
    return GameStep(_refillOrders(base, now));
  }

  /// Se llama al cargar una partida guardada. Calcula la ganancia pasiva,
  /// rellena pedidos faltantes y garantiza que el jugador tenga salida.
  GameStep resume({required GameState state, required DateTime now}) {
    final List<GameEvent> events = <GameEvent>[];
    GameState next = _refillOrders(state, now);

    // Se acumula en la caja lo vendido mientras la app estuvo cerrada. No se
    // acredita solo: cobrar es un gesto del jugador, y ese gesto es medio
    // punto del bucle de volver.
    //
    // El aviso se dispara por lo que se juntó **en esta ausencia**, no por el
    // saldo de la caja. Mirar el saldo hacía que quien cerraba el juego sin
    // cobrar viera "mientras no estabas se juntaron N monedas" en cada
    // apertura, aunque hubiera vuelto a los diez segundos y no se hubiera
    // juntado nada. Era falso y además insistía.
    final double before = next.idleAccrued;
    next = _accrueIncome(next, now);
    final int earned = (next.idleAccrued - before).floor();
    if (earned >= config.offlineMinClaim) {
      events.add(OfflineEarningsClaimed(earned: earned, total: next.tillCoins));
    }

    next = next.copyWith(lastSeenAt: now);
    final GameStep relieved = relieveIfStuck(next);
    return GameStep(relieved.state, <GameEvent>[...events, ...relieved.events]);
  }

  // --------------------------------------------------------------------
  // Ganancia pasiva
  // --------------------------------------------------------------------

  /// Acredita la ganancia pasiva acumulada desde la última vez.
  ///
  /// Es un único camino para los dos casos: el contador que corre en vivo
  /// mientras se juega (elapsed de un segundo) y el cobro al volver después de
  /// un rato (elapsed grande, topado en [EconomyConfig.offlineCapHours]).
  ///
  /// La parte fraccionaria se guarda en [GameState.idleAccrued] para que el
  /// contador suba de forma continua y no a saltos de una moneda.
  /// Capacidad de la caja: cuántas monedas aguanta antes de llenarse.
  int tillCapacity(GameState state) =>
      state.shopTier.coinsPerHour * config.tillHours(state.tillLevel);

  /// ¿La caja ya está llena? A partir de acá el almacén deja de acumular.
  bool isTillFull(GameState state) => state.idleAccrued >= tillCapacity(state);

  /// Cuándo se llenará la caja, o null si ya está llena o no genera nada.
  DateTime? tillFullAt(GameState state) {
    final int rate = state.shopTier.coinsPerHour;
    if (rate <= 0) return null;
    final double missing = tillCapacity(state) - state.idleAccrued;
    if (missing <= 0) return null;
    final double hours = missing / rate;
    return state.lastIncomeAt.add(
      Duration(milliseconds: (hours * Duration.millisecondsPerHour).round()),
    );
  }

  /// Acumula en la caja lo vendido desde la última vez, **con tope**.
  ///
  /// Es un único camino para el latido de un segundo mientras se juega y para
  /// el rato que la app estuvo cerrada. El tope es lo que convierte a la caja
  /// en una razón para volver: llena, el almacén deja de producir.
  GameState _accrueIncome(GameState state, DateTime now) {
    final Duration elapsed = now.difference(state.lastIncomeAt);
    if (elapsed.isNegative) {
      // El reloj del dispositivo retrocedió: no se regala nada, sólo se
      // reancla el punto de partida.
      return state.copyWith(lastIncomeAt: now);
    }

    final double hours = elapsed.inMilliseconds / Duration.millisecondsPerHour;
    final double earned = state.shopTier.coinsPerHour * hours;
    final double total = math.min(
      state.idleAccrued + earned,
      tillCapacity(state).toDouble(),
    );

    return state.copyWith(idleAccrued: total, lastIncomeAt: now);
  }

  /// Avance del contador en vivo. La UI lo llama cada segundo.
  GameStep tickIncome(GameState state, DateTime now) =>
      GameStep(_accrueIncome(state, now));

  /// Cobrar la caja: pasa a monedas lo acumulado y la deja vacía.
  GameStep collectTill(GameState state, DateTime now) {
    final GameState accrued = _accrueIncome(state, now);
    final int amount = accrued.idleAccrued.floor();
    if (amount <= 0) return GameStep(accrued);

    return GameStep(
      accrued.copyWith(
        coins: accrued.coins + amount,
        idleAccrued: accrued.idleAccrued - amount,
      ),
      <GameEvent>[TillCollected(amount)],
    );
  }

  /// Ampliar la caja para que aguante más horas antes de llenarse.
  GameStep upgradeTill(GameState state) {
    if (state.tillLevel >= config.tillMaxLevel) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.tillAtMaxLevel),
      ]);
    }
    final int cost = config.tillUpgradeCost(state.tillLevel + 1);
    if (state.coins < cost) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.notEnoughCoins),
      ]);
    }
    return GameStep(
      state.copyWith(coins: state.coins - cost, tillLevel: state.tillLevel + 1),
      <GameEvent>[TillUpgraded(state.tillLevel + 1, cost)],
    );
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
    required DateTime now,
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
    final bool timeBonus = order.hasTimeBonusAt(now);
    int reward = bonus ? economy.orderBonusReward(order.reward) : order.reward;
    if (timeBonus) reward = economy.timeBonusReward(reward);

    final int levelBefore = state.playerLevel(economy);

    GameState next = state.copyWith(
      board: consumed,
      coins: state.coins + reward,
      xp: state.xp + order.xp,
      totalOrdersCompleted: state.totalOrdersCompleted + 1,
    );

    final List<GameEvent> events = <GameEvent>[
      OrderCompleted(
        reward: reward,
        xp: order.xp,
        withBonus: bonus,
        withTimeBonus: timeBonus,
      ),
    ];

    if (next.tutorialStep == TutorialStep.completeOrder) {
      next = next.copyWith(tutorialStep: TutorialStep.upgrade);
      events.add(const TutorialAdvanced());
    }

    next = _applyLevelUps(next, levelBefore, events);
    // El pedido nuevo ocupa el hueco del entregado, no el final de la fila.
    next = _replaceOrderAt(next, position, now);
    next = _refillOrders(next, now);
    return GameStep(next, events);
  }

  /// Entregar un pedido a medias, cobrando menos de lo proporcional.
  ///
  /// Existe para los niveles altos, donde un pedido puede pedir un producto
  /// caro que el jugador no alcanza a juntar: entregar la parte que sí tiene
  /// es mejor que dejar el pedido ocupando un espacio para siempre. El castigo
  /// hace que completar el pedido siga siendo la mejor jugada.
  GameStep completeOrderPartially(
    GameState state,
    int orderId, {
    required DateTime now,
  }) {
    if (state.playerLevel(economy) < config.partialDeliveryPlayerLevel) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.partialNotAvailable),
      ]);
    }

    final int position = state.orders.indexWhere(
      (CustomerOrder o) => o.id == orderId,
    );
    if (position < 0) return GameStep(state);

    final CustomerOrder order = state.orders[position];
    final double coverage = order.coverageIn(state.board);
    if (coverage <= 0) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.orderNotReady),
      ]);
    }
    // Si está completo, se entrega completo: no tiene sentido castigar a quien
    // ya juntó todo.
    if (coverage >= 1) return completeOrder(state, orderId, now: now);

    final int reward = economy.partialReward(order.reward, coverage);
    final int xp = math.max(1, (order.xp * coverage).round());
    final int levelBefore = state.playerLevel(economy);

    GameState next = state.copyWith(
      board: BoardOps.consumeOrderPartially(state.board, order),
      coins: state.coins + reward,
      xp: state.xp + xp,
      totalOrdersCompleted: state.totalOrdersCompleted + 1,
    );

    final List<GameEvent> events = <GameEvent>[
      OrderPartiallyCompleted(reward: reward, coverage: coverage),
    ];
    next = _applyLevelUps(next, levelBefore, events);
    next = _replaceOrderAt(next, position, now);
    next = _refillOrders(next, now);
    return GameStep(next, events);
  }

  /// Cambiar un pedido que no conviene. Cuesta monedas para que sea una
  /// decisión, no un botón gratis de "saltar contenido".
  GameStep rerollOrder(GameState state, int orderId, {required DateTime now}) {
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
      now,
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

  /// Comprar un producto ya hecho, de un nivel que el jugador ya conozca.
  ///
  /// El precio está deliberadamente **por encima de lo que paga un pedido de
  /// ese nivel** (ver [EconomyConfig.buyPriceRatio]): comprar es un atajo de
  /// conveniencia y un sumidero de monedas, nunca un camino más rentable que
  /// fusionar. Si lo fuera, el core loop del juego dejaría de importar.
  GameStep buyProduct(GameState state, String chainId, int level) {
    if (!ProductCatalog.exists(chainId) ||
        !ProductCatalog.byId(chainId).hasLevel(level)) {
      return GameStep(state);
    }
    if (state.board.isFull) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.boardFull),
      ]);
    }

    final int price = economy.buyPrice(level);
    if (state.coins < price) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.notEnoughCoins),
      ]);
    }

    final BoardItem item = BoardItem(
      id: state.nextItemId,
      chainId: chainId,
      level: level,
    );
    final Board? placed = BoardOps.placeInFirstFree(state.board, item);
    if (placed == null) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.boardFull),
      ]);
    }

    GameState next = state.copyWith(
      board: placed,
      coins: state.coins - price,
      nextItemId: state.nextItemId + 1,
    );
    final List<GameEvent> events = <GameEvent>[
      ProductBought(chainId, level, price),
    ];
    next = _markDiscovered(next, chainId, level, events);
    return GameStep(next, events);
  }

  /// Separar un producto en dos del nivel anterior.
  ///
  /// Es la operación inversa de fusionar, así que no crea valor: devuelve
  /// exactamente lo que se puso. Cobra una comisión y necesita una casilla
  /// libre. Sirve para deshacer una fusión de más cuando un pedido pide el
  /// nivel de abajo.
  GameStep splitItem(GameState state, int index) {
    final BoardItem? item = state.board.at(index);
    if (item == null || item.level <= 1) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.cannotSplit),
      ]);
    }
    // Uno queda en su casilla y el otro necesita una libre.
    if (state.board.freeCells < 1) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.boardFull),
      ]);
    }

    final int cost = economy.splitCost(item.level);
    if (state.coins < cost) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.notEnoughCoins),
      ]);
    }

    final int newLevel = item.level - 1;
    final List<BoardItem?> cells = state.board.mutableCells();
    cells[index] = BoardItem(
      id: state.nextItemId,
      chainId: item.chainId,
      level: newLevel,
    );
    final Board? placed = BoardOps.placeInFirstFree(
      state.board.withCells(cells),
      BoardItem(
        id: state.nextItemId + 1,
        chainId: item.chainId,
        level: newLevel,
      ),
    );
    if (placed == null) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.boardFull),
      ]);
    }

    GameState next = state.copyWith(
      board: placed,
      coins: state.coins - cost,
      nextItemId: state.nextItemId + 2,
    );
    final List<GameEvent> events = <GameEvent>[
      ItemSplit(item.chainId, newLevel, cost),
    ];
    next = _markDiscovered(next, item.chainId, newLevel, events);
    return GameStep(next, events);
  }

  /// Desbloquear una fila más del tablero.
  GameStep expandBoard(GameState state) {
    if (!state.board.canExpand) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.boardAtMaxSize),
      ]);
    }

    final int cost = config.expandCost(state.board.unlockedRows + 1);
    if (state.coins < cost) {
      return GameStep(state, const <GameEvent>[
        ActionRejected(RejectReason.notEnoughCoins),
      ]);
    }

    final Board expanded = state.board.expanded();
    return GameStep(
      state.copyWith(board: expanded, coins: state.coins - cost),
      <GameEvent>[BoardExpanded(expanded.unlockedRows, cost)],
    );
  }

  GameStep updateSettings(GameState state, GameSettings settings) =>
      GameStep(state.copyWith(settings: settings));

  /// Avanza el onboarding un paso sin obligar a hacer la acción.
  ///
  /// El tutorial avanza solo cuando el jugador hace lo que se le pide, pero
  /// alguien que ya entendió —o que prefiere leerlo todo de corrido— tiene que
  /// poder pasar de largo sin saltarse el resto.
  GameStep advanceTutorial(GameState state) {
    if (!state.tutorialStep.isActive) return GameStep(state);
    return GameStep(
      state.copyWith(tutorialStep: state.tutorialStep.next),
      const <GameEvent>[TutorialAdvanced()],
    );
  }

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
  (CustomerOrder, GameState) _makeOrder(GameState state, DateTime now) {
    final (CustomerOrder order, int seed) = _withRng(
      state.rngSeed,
      (Random rng) => generator.generate(
        id: state.nextOrderId,
        playerLevel: state.playerLevel(economy),
        rng: rng,
        bonusUntil: now.add(config.orderBonusWindow),
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
  GameState _replaceOrderAt(GameState state, int position, DateTime now) {
    final (CustomerOrder order, GameState next) = _makeOrder(state, now);
    final List<CustomerOrder> orders = List<CustomerOrder>.of(next.orders);
    orders[position] = order;
    return next.copyWith(orders: orders);
  }

  /// Mantiene siempre [EconomyConfig.visibleOrders] pedidos en pantalla.
  GameState _refillOrders(GameState state, DateTime now) {
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
          bonusUntil: now.add(config.orderBonusWindow),
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
