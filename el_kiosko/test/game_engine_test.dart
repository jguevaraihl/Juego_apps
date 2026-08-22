import 'dart:math';

import 'package:almacen/game/economy/economy_config.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/game_events.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/order.dart';
import 'package:almacen/game/models/product.dart';
import 'package:almacen/game/progression/shop_tiers.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime t0 = DateTime.utc(2026, 8, 22, 12);

extension on GameStep {
  bool hasEvent<T extends GameEvent>() => events.whereType<T>().isNotEmpty;
  T event<T extends GameEvent>() => events.whereType<T>().first;
}

/// Coloca objetos concretos en el tablero, para armar escenarios exactos.
GameState withItems(GameState state, Map<int, BoardItem> placed) {
  final List<BoardItem?> cells = state.board.mutableCells();
  placed.forEach((int index, BoardItem value) => cells[index] = value);
  return state.copyWith(board: state.board.withCells(cells));
}

void main() {
  const String pan = ProductCatalog.panaderia;
  late GameEngine engine;

  setUp(() => engine = GameEngine());

  group('partida nueva', () {
    test('arranca con monedas, pedidos y tutorial en el primer paso', () {
      final GameStep step = engine.newGame(now: t0, seed: 42);

      expect(step.state.coins, EconomyConfig.defaults.startingCoins);
      expect(step.state.orders.length, EconomyConfig.defaults.visibleOrders);
      expect(step.state.tutorialStep, TutorialStep.merge);
      expect(step.state.shopLevel, 1);
      expect(step.state.board.isEmpty, isTrue);
    });

    test('es determinista para una misma semilla', () {
      final GameStep a = engine.newGame(now: t0, seed: 7);
      final GameStep b = engine.newGame(now: t0, seed: 7);

      expect(
        a.state.orders.map((CustomerOrder o) => o.customerId),
        b.state.orders.map((CustomerOrder o) => o.customerId),
      );
    });

    test('los pedidos iniciales sólo piden cadenas desbloqueadas', () {
      for (int seed = 0; seed < 50; seed++) {
        final GameStep step = engine.newGame(now: t0, seed: seed);
        final int level = step.state.playerLevel(engine.economy);
        final Set<String> unlocked = ProductCatalog.unlockedFor(level)
            .map((ProductChain c) => c.id)
            .toSet();

        for (final CustomerOrder order in step.state.orders) {
          for (final OrderLine line in order.lines) {
            expect(unlocked, contains(line.chainId));
            expect(
              line.level,
              lessThanOrEqualTo(
                engine.economy.maxOrderLevel(
                  level,
                  ProductCatalog.byId(line.chainId).maxLevel,
                ),
              ),
            );
          }
        }
      }
    });
  });

  group('generar', () {
    test('cobra el costo y deja un objeto de nivel 1', () {
      final GameState start = engine.newGame(now: t0, seed: 1).state;
      final GameStep step = engine.generate(start);

      expect(
        step.state.coins,
        start.coins - EconomyConfig.defaults.generateCost,
      );
      expect(step.state.board.occupied, 1);
      expect(step.state.board.items().single.level, 1);
      expect(step.hasEvent<ItemGenerated>(), isTrue);
    });

    test('se rechaza sin monedas', () {
      final GameState broke = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 0);
      final GameStep step = engine.generate(broke);

      expect(step.state.board.occupied, 0);
      expect(step.event<ActionRejected>().reason, RejectReason.notEnoughCoins);
    });

    test('se rechaza con el tablero lleno', () {
      GameState state = engine.newGame(now: t0, seed: 1).state;
      final List<BoardItem?> cells = List<BoardItem?>.generate(
        state.board.capacity,
        (int i) => BoardItem(id: i, chainId: pan, level: 1),
      );
      state = state.copyWith(board: state.board.withCells(cells), coins: 999);

      final GameStep step = engine.generate(state);
      expect(step.event<ActionRejected>().reason, RejectReason.boardFull);
    });

    test('registra el producto en el álbum la primera vez', () {
      final GameState start = engine.newGame(now: t0, seed: 1).state;
      final GameStep step = engine.generate(start);

      expect(step.hasEvent<ProductDiscovered>(), isTrue);
      expect(step.state.discovered, isNotEmpty);
    });
  });

  group('merge', () {
    test('cuenta el merge y avanza el tutorial', () {
      GameState state = engine.newGame(now: t0, seed: 1).state;
      state = withItems(state, <int, BoardItem>{
        0: const BoardItem(id: 1, chainId: pan, level: 1),
        1: const BoardItem(id: 2, chainId: pan, level: 1),
      });

      final GameStep step = engine.drop(state, 0, 1);

      expect(step.hasEvent<MergeCompleted>(), isTrue);
      expect(step.state.totalMerges, 1);
      expect(step.state.tutorialStep, TutorialStep.completeOrder);
      expect(step.state.board.at(1)!.level, 2);
    });

    test('un intercambio no cuenta como merge ni avanza el tutorial', () {
      GameState state = engine.newGame(now: t0, seed: 1).state;
      state = withItems(state, <int, BoardItem>{
        0: const BoardItem(id: 1, chainId: pan, level: 1),
        1: const BoardItem(id: 2, chainId: pan, level: 2),
      });

      final GameStep step = engine.drop(state, 0, 1);

      expect(step.hasEvent<MergeCompleted>(), isFalse);
      expect(step.state.totalMerges, 0);
      expect(step.state.tutorialStep, TutorialStep.merge);
    });
  });

  group('pedidos', () {
    test('completar paga, da XP y repone el pedido', () {
      GameState state = engine.newGame(now: t0, seed: 3).state;
      final CustomerOrder order = state.orders.first;

      // Se ponen en el tablero exactamente los productos del pedido.
      int id = 500;
      final Map<int, BoardItem> placed = <int, BoardItem>{};
      int slot = 0;
      for (final OrderLine line in order.lines) {
        for (int q = 0; q < line.quantity; q++) {
          placed[slot++] = BoardItem(
            id: id++,
            chainId: line.chainId,
            level: line.level,
          );
        }
      }
      state = withItems(
        state,
        placed,
      ).copyWith(tutorialStep: TutorialStep.completeOrder);
      final int coinsBefore = state.coins;

      // Se entrega pasada la ventana, para medir la recompensa base.
      final DateTime late = t0.add(const Duration(hours: 1));
      final GameStep step = engine.completeOrder(state, order.id, now: late);

      expect(step.event<OrderCompleted>().withTimeBonus, isFalse);
      expect(step.state.coins, coinsBefore + order.reward);
      expect(step.state.xp, order.xp);
      expect(step.state.totalOrdersCompleted, 1);
      expect(step.state.orders.length, EconomyConfig.defaults.visibleOrders);
      expect(
        step.state.orders.any((CustomerOrder o) => o.id == order.id),
        isFalse,
        reason: 'el pedido entregado no debe seguir en pantalla',
      );
      expect(step.state.board.isEmpty, isTrue);
      expect(step.state.tutorialStep, TutorialStep.upgrade);
    });

    test('completar un pedido no salta el paso 1 del tutorial', () {
      // Un pedido de nivel 1 se puede entregar sin haber fusionado nunca.
      // En ese caso el tutorial sigue pidiendo el merge: no se salta pasos.
      GameState state = engine.newGame(now: t0, seed: 3).state;
      final CustomerOrder order = CustomerOrder(
        id: 777,
        customerId: 0,
        lines: const <OrderLine>[
          OrderLine(chainId: pan, level: 1, quantity: 1),
        ],
        reward: 10,
        xp: 3,
      );
      state = withItems(
        state.copyWith(orders: <CustomerOrder>[order, ...state.orders]),
        <int, BoardItem>{0: const BoardItem(id: 1, chainId: pan, level: 1)},
      );
      expect(state.tutorialStep, TutorialStep.merge);

      final GameStep step = engine.completeOrder(state, 777, now: t0);

      expect(step.hasEvent<OrderCompleted>(), isTrue);
      expect(step.state.tutorialStep, TutorialStep.merge);
    });

    test('entregar dentro de la ventana paga la bonificación por rapidez', () {
      GameState state = engine.newGame(now: t0, seed: 3).state;
      final CustomerOrder order = state.orders.first;

      int id = 700;
      final Map<int, BoardItem> placed = <int, BoardItem>{};
      int slot = 0;
      for (final OrderLine line in order.lines) {
        for (int q = 0; q < line.quantity; q++) {
          placed[slot++] = BoardItem(
            id: id++,
            chainId: line.chainId,
            level: line.level,
          );
        }
      }
      state = withItems(state, placed);
      final int coinsBefore = state.coins;

      final GameStep step = engine.completeOrder(state, order.id, now: t0);

      expect(step.event<OrderCompleted>().withTimeBonus, isTrue);
      expect(
        step.state.coins,
        coinsBefore + engine.economy.timeBonusReward(order.reward),
      );
    });

    test(
      'un pedido nunca caduca: pasada la ventana igual se puede entregar',
      () {
        GameState state = engine.newGame(now: t0, seed: 3).state;
        final CustomerOrder order = state.orders.first;

        int id = 800;
        final Map<int, BoardItem> placed = <int, BoardItem>{};
        int slot = 0;
        for (final OrderLine line in order.lines) {
          for (int q = 0; q < line.quantity; q++) {
            placed[slot++] = BoardItem(
              id: id++,
              chainId: line.chainId,
              level: line.level,
            );
          }
        }
        state = withItems(state, placed);

        // Una semana después: el pedido sigue ahí y sigue pagando.
        final GameStep step = engine.completeOrder(
          state,
          order.id,
          now: t0.add(const Duration(days: 7)),
        );

        expect(step.hasEvent<OrderCompleted>(), isTrue);
        expect(step.event<OrderCompleted>().withTimeBonus, isFalse);
        expect(step.state.totalOrdersCompleted, 1);
      },
    );

    test('no se puede completar sin la mercadería', () {
      final GameState state = engine.newGame(now: t0, seed: 3).state;
      final CustomerOrder order = state.orders.first;

      final GameStep step = engine.completeOrder(state, order.id, now: t0);

      expect(step.event<ActionRejected>().reason, RejectReason.orderNotReady);
      expect(step.state.coins, state.coins);
      expect(step.state.orders.length, state.orders.length);
    });

    test('el bonus del pedido especial duplica el pago', () {
      GameState state = engine.newGame(now: t0, seed: 3).state;
      final CustomerOrder base = state.orders.first;
      final CustomerOrder special = CustomerOrder(
        id: base.id,
        customerId: base.customerId,
        lines: const <OrderLine>[
          OrderLine(chainId: pan, level: 1, quantity: 1),
        ],
        reward: 100,
        xp: 3,
        isSpecial: true,
      );
      state = withItems(
        state.copyWith(
          orders: <CustomerOrder>[special, ...state.orders.skip(1)],
        ),
        <int, BoardItem>{0: const BoardItem(id: 1, chainId: pan, level: 1)},
      );
      final int coinsBefore = state.coins;

      final GameStep step = engine.completeOrder(
        state,
        special.id,
        now: t0,
        withBonus: true,
      );

      expect(step.state.coins, coinsBefore + 200);
      expect(step.event<OrderCompleted>().withBonus, isTrue);
    });

    test('el reroll cobra y cambia el pedido', () {
      final GameState state = engine
          .newGame(now: t0, seed: 3)
          .state
          .copyWith(coins: 500);
      final CustomerOrder order = state.orders.first;
      final int cost = engine.economy.rerollCost(order.reward);

      final GameStep step = engine.rerollOrder(state, order.id, now: t0);

      expect(step.state.coins, 500 - cost);
      expect(
        step.state.orders.any((CustomerOrder o) => o.id == order.id),
        isFalse,
      );
      expect(step.state.orders.length, EconomyConfig.defaults.visibleOrders);
    });

    test('el reroll sólo cambia el pedido tocado, y en su misma posición', () {
      // Regresión: antes se quitaba el pedido y el nuevo se agregaba al final,
      // así que los otros dos se corrían y en pantalla parecía que habían
      // cambiado los tres.
      final GameState state = engine
          .newGame(now: t0, seed: 3)
          .state
          .copyWith(coins: 500);
      final List<CustomerOrder> before = state.orders;

      final GameStep step = engine.rerollOrder(state, before[1].id, now: t0);
      final List<CustomerOrder> after = step.state.orders;

      expect(after.length, before.length);
      // Los vecinos quedan intactos y en su lugar.
      expect(after[0].id, before[0].id);
      expect(after[2].id, before[2].id);
      // Y sólo el del medio cambió.
      expect(after[1].id, isNot(before[1].id));
    });

    test('entregar repone el pedido en el mismo lugar', () {
      GameState state = engine.newGame(now: t0, seed: 3).state;
      final CustomerOrder target = state.orders[2];

      int id = 900;
      final Map<int, BoardItem> placed = <int, BoardItem>{};
      int slot = 0;
      for (final OrderLine line in target.lines) {
        for (int q = 0; q < line.quantity; q++) {
          placed[slot++] = BoardItem(
            id: id++,
            chainId: line.chainId,
            level: line.level,
          );
        }
      }
      final List<CustomerOrder> before = state.orders;
      state = withItems(state, placed);

      final GameStep step = engine.completeOrder(state, target.id, now: t0);
      final List<CustomerOrder> after = step.state.orders;

      expect(after.length, 3);
      expect(after[0].id, before[0].id);
      expect(after[1].id, before[1].id);
      expect(after[2].id, isNot(target.id));
    });

    test('el reroll se rechaza sin monedas', () {
      final GameState state = engine
          .newGame(now: t0, seed: 3)
          .state
          .copyWith(coins: 0);
      final GameStep step = engine.rerollOrder(
        state,
        state.orders.first.id,
        now: t0,
      );

      expect(step.event<ActionRejected>().reason, RejectReason.notEnoughCoins);
    });
  });

  group('entrega parcial', () {
    /// Deja el pedido [order] en la primera posición con [have] unidades de su
    /// primera línea en el tablero.
    (GameState, CustomerOrder) scenarioWithPartial(int playerLevel, int have) {
      GameState state = engine.newGame(now: t0, seed: 11).state;
      const CustomerOrder order = CustomerOrder(
        id: 555,
        customerId: 0,
        lines: <OrderLine>[OrderLine(chainId: pan, level: 2, quantity: 2)],
        reward: 26,
        xp: 12,
      );
      final Map<int, BoardItem> placed = <int, BoardItem>{};
      for (int i = 0; i < have; i++) {
        placed[i] = BoardItem(id: 600 + i, chainId: pan, level: 2);
      }
      state = withItems(
        state.copyWith(
          orders: <CustomerOrder>[order, ...state.orders.skip(1)],
          xp: engine.economy.xpForLevel(playerLevel),
        ),
        placed,
      );
      return (state, order);
    }

    test('paga menos que la parte proporcional', () {
      final (GameState state, CustomerOrder order) = scenarioWithPartial(6, 1);
      final int coinsBefore = state.coins;

      final GameStep step = engine.completeOrderPartially(
        state,
        order.id,
        now: t0,
      );

      final int paid = step.state.coins - coinsBefore;
      expect(paid, greaterThan(0));
      // La mitad del pedido paga menos que la mitad de la recompensa: si no,
      // entregar a medias sería igual de bueno que entregar completo.
      expect(paid, lessThan(order.reward ~/ 2));
      expect(step.hasEvent<OrderPartiallyCompleted>(), isTrue);
    });

    test('consume lo entregado y repone el pedido en su lugar', () {
      final (GameState state, CustomerOrder order) = scenarioWithPartial(6, 1);

      final GameStep step = engine.completeOrderPartially(
        state,
        order.id,
        now: t0,
      );

      expect(step.state.board.countOf(pan, 2), 0);
      expect(step.state.orders.length, EconomyConfig.defaults.visibleOrders);
      expect(step.state.orders.first.id, isNot(order.id));
    });

    test('no está disponible en los primeros niveles', () {
      final (GameState state, CustomerOrder order) = scenarioWithPartial(1, 1);

      final GameStep step = engine.completeOrderPartially(
        state,
        order.id,
        now: t0,
      );

      expect(
        step.event<ActionRejected>().reason,
        RejectReason.partialNotAvailable,
      );
      expect(step.state.board.countOf(pan, 2), 1);
    });

    test('sin nada que entregar no hace nada', () {
      final (GameState state, CustomerOrder order) = scenarioWithPartial(6, 0);

      final GameStep step = engine.completeOrderPartially(
        state,
        order.id,
        now: t0,
      );

      expect(step.event<ActionRejected>().reason, RejectReason.orderNotReady);
    });

    test('con el pedido completo se cobra completo, sin castigo', () {
      final (GameState state, CustomerOrder order) = scenarioWithPartial(6, 2);
      final int coinsBefore = state.coins;

      final GameStep step = engine.completeOrderPartially(
        state,
        order.id,
        now: t0.add(const Duration(hours: 1)),
      );

      expect(step.hasEvent<OrderCompleted>(), isTrue);
      expect(step.state.coins, coinsBefore + order.reward);
    });
  });

  group('onboarding', () {
    test('Siguiente avanza un paso sin hacer la acción', () {
      final GameState state = engine.newGame(now: t0, seed: 1).state;
      expect(state.tutorialStep, TutorialStep.merge);

      final GameState after = engine.advanceTutorial(state).state;
      expect(after.tutorialStep, TutorialStep.completeOrder);

      final GameState end = engine
          .advanceTutorial(engine.advanceTutorial(after).state)
          .state;
      expect(end.tutorialStep, TutorialStep.done);
      // Ya terminado, no hace nada más.
      expect(engine.advanceTutorial(end).state.tutorialStep, TutorialStep.done);
    });
  });

  group('catálogo', () {
    test('las cadenas no tienen todas la misma cantidad de niveles', () {
      final Set<int> lengths = ProductCatalog.chains
          .map((ProductChain c) => c.maxLevel)
          .toSet();
      expect(lengths.length, greaterThan(1));
    });

    test('los pedidos respetan el tope de cada cadena', () {
      for (int seed = 0; seed < 60; seed++) {
        final GameState state = engine
            .newGame(now: t0, seed: seed)
            .state
            .copyWith(xp: engine.economy.xpForLevel(12));
        final GameState refilled = engine
            .rerollOrder(state, state.orders.first.id, now: t0)
            .state;
        for (final CustomerOrder order in refilled.orders) {
          for (final OrderLine line in order.lines) {
            final ProductChain chain = ProductCatalog.byId(line.chainId);
            expect(chain.hasLevel(line.level), isTrue);
          }
        }
      }
    });
  });

  group('progresión del local', () {
    test('mejorar cobra y sube de nivel', () {
      final ShopTier target = ShopTiers.byLevel(2);
      final GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: target.upgradeCost);

      final GameStep step = engine.upgradeShop(state);

      expect(step.state.shopLevel, 2);
      expect(step.state.coins, 0);
      expect(step.event<ShopUpgraded>().newLevel, 2);
    });

    test('no se puede mejorar sin monedas', () {
      final GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 0);
      final GameStep step = engine.upgradeShop(state);

      expect(step.event<ActionRejected>().reason, RejectReason.notEnoughCoins);
      expect(step.state.shopLevel, 1);
    });

    test('el último nivel no se puede superar', () {
      final GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(shopLevel: ShopTiers.maxLevel, coins: 999999);
      final GameStep step = engine.upgradeShop(state);

      expect(step.event<ActionRejected>().reason, RejectReason.maxShopLevel);
    });

    test('subir de nivel de jugador desbloquea la cadena de snacks', () {
      GameState state = engine.newGame(now: t0, seed: 1).state;
      // XP justo bajo el nivel 2, para que un pedido cruce el umbral.
      final int xpForLevel2 = engine.economy.xpForLevel(2);
      state = state.copyWith(xp: xpForLevel2 - 1);

      final CustomerOrder order = CustomerOrder(
        id: 999,
        customerId: 0,
        lines: const <OrderLine>[
          OrderLine(chainId: pan, level: 1, quantity: 1),
        ],
        reward: 10,
        xp: 5,
      );
      state = withItems(
        state.copyWith(orders: <CustomerOrder>[order, ...state.orders]),
        <int, BoardItem>{0: const BoardItem(id: 1, chainId: pan, level: 1)},
      );

      final GameStep step = engine.completeOrder(state, 999, now: t0);

      expect(step.hasEvent<PlayerLeveledUp>(), isTrue);
      expect(
        step.events.whereType<ChainUnlocked>().map(
          (ChainUnlocked e) => e.chainId,
        ),
        contains(ProductCatalog.snacks),
      );
    });
  });

  group('vender', () {
    test('paga el valor de venta y libera la casilla', () {
      GameState state = engine.newGame(now: t0, seed: 1).state;
      state = withItems(state, <int, BoardItem>{
        4: const BoardItem(id: 1, chainId: pan, level: 3),
      });
      final int coinsBefore = state.coins;

      final GameStep step = engine.sell(state, 4);

      expect(step.state.board.at(4), isNull);
      expect(step.state.coins, coinsBefore + engine.economy.sellValue(3));
      expect(step.event<ItemSold>().value, engine.economy.sellValue(3));
    });

    test('vender una casilla vacía no hace nada', () {
      final GameState state = engine.newGame(now: t0, seed: 1).state;
      final GameStep step = engine.sell(state, 4);

      expect(step.state.coins, state.coins);
      expect(step.events, isEmpty);
    });
  });

  group('comprar mercadería', () {
    test('descuenta el precio y deja el producto en el tablero', () {
      final GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 500);
      final int price = engine.economy.buyPrice(3);

      final GameStep step = engine.buyProduct(state, pan, 3);

      expect(step.state.coins, 500 - price);
      expect(step.state.board.countOf(pan, 3), 1);
      expect(step.event<ProductBought>().price, price);
    });

    test('se rechaza sin monedas', () {
      final GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 0);
      final GameStep step = engine.buyProduct(state, pan, 4);

      expect(step.event<ActionRejected>().reason, RejectReason.notEnoughCoins);
      expect(step.state.board.isEmpty, isTrue);
    });

    test('un nivel que no existe en la cadena no hace nada', () {
      final GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 9999);
      final GameStep step = engine.buyProduct(state, pan, 99);

      expect(step.state.coins, 9999);
      expect(step.events, isEmpty);
    });
  });

  group('separar productos', () {
    test('devuelve dos del nivel anterior y cobra', () {
      GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 500);
      state = withItems(state, <int, BoardItem>{
        0: const BoardItem(id: 1, chainId: pan, level: 3),
      });
      final int cost = engine.economy.splitCost(3);

      final GameStep step = engine.splitItem(state, 0);

      expect(step.state.coins, 500 - cost);
      expect(step.state.board.countOf(pan, 2), 2);
      expect(step.state.board.countOf(pan, 3), 0);
      expect(step.event<ItemSplit>().newLevel, 2);
    });

    test('separar y volver a fusionar deja el mismo objeto', () {
      // Separar es la operación inversa de fusionar: no puede crear valor, o
      // sería una máquina de monedas.
      GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 500);
      state = withItems(state, <int, BoardItem>{
        0: const BoardItem(id: 1, chainId: pan, level: 3),
      });

      final GameState split = engine.splitItem(state, 0).state;
      final List<int> parts = split.board.indexesOf(pan, 2);
      expect(parts.length, 2);
      final GameState merged = engine
          .drop(split, parts.first, parts.last)
          .state;

      expect(merged.board.countOf(pan, 3), 1);
      expect(merged.board.occupied, 1);
      // Y el jugador terminó con menos monedas que al empezar.
      expect(merged.coins, lessThan(500));
    });

    test('el nivel 1 no se puede separar', () {
      GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 500);
      state = withItems(state, <int, BoardItem>{
        0: const BoardItem(id: 1, chainId: pan, level: 1),
      });

      final GameStep step = engine.splitItem(state, 0);
      expect(step.event<ActionRejected>().reason, RejectReason.cannotSplit);
    });
  });

  group('ampliar el tablero', () {
    test('la partida nueva empieza con el tablero reducido', () {
      final GameState state = engine.newGame(now: t0, seed: 1).state;
      expect(state.board.unlockedRows, EconomyConfig.defaults.startingRows);
      expect(state.board.playableCapacity, lessThan(state.board.capacity));
    });

    test('desbloquea una fila y cobra', () {
      final GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 99999);
      final int before = state.board.unlockedRows;
      final int cost = EconomyConfig.defaults.expandCost(before + 1);

      final GameStep step = engine.expandBoard(state);

      expect(step.state.board.unlockedRows, before + 1);
      expect(step.state.coins, 99999 - cost);
      expect(step.event<BoardExpanded>().cost, cost);
    });

    test('no se puede pasar del tamaño máximo', () {
      GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 999999);
      while (state.board.canExpand) {
        state = engine.expandBoard(state).state;
      }
      expect(state.board.unlockedRows, EconomyConfig.defaults.boardRows);

      final GameStep step = engine.expandBoard(state);
      expect(step.event<ActionRejected>().reason, RejectReason.boardAtMaxSize);
    });

    test('no se puede soltar una ficha en una fila bloqueada', () {
      GameState state = engine.newGame(now: t0, seed: 1).state;
      state = withItems(state, <int, BoardItem>{
        0: const BoardItem(id: 1, chainId: pan, level: 1),
      });
      final int lockedIndex = state.board.playableCapacity;

      final GameStep step = engine.drop(state, 0, lockedIndex);

      expect(step.state.board.at(0), isNotNull);
      expect(step.state.board.cells[lockedIndex], isNull);
    });

    test('generar nunca coloca en una fila bloqueada', () {
      GameState state = engine
          .newGame(now: t0, seed: 5)
          .state
          .copyWith(coins: 99999);
      for (int i = 0; i < 40; i++) {
        state = engine.generate(state).state;
      }
      for (
        int i = state.board.playableCapacity;
        i < state.board.capacity;
        i++
      ) {
        expect(state.board.cells[i], isNull, reason: 'casilla \$i bloqueada');
      }
    });
  });

  group('ganancia pasiva en vivo', () {
    test('acumula fracciones y las convierte en monedas', () {
      final GameState state = engine.newGame(now: t0, seed: 1).state;
      final int rate = state.shopTier.coinsPerHour;

      // Medio segundo no alcanza para una moneda entera, pero se guarda.
      final GameState half = engine
          .tickIncome(state, t0.add(const Duration(milliseconds: 500)))
          .state;
      expect(half.coins, state.coins);
      expect(half.idleAccrued, greaterThan(0));

      // Una hora completa sí.
      final GameState later = engine
          .tickIncome(state, t0.add(const Duration(hours: 1)))
          .state;
      expect(later.coins, state.coins + rate);
    });

    test('no paga dos veces por el mismo tiempo', () {
      final GameState state = engine.newGame(now: t0, seed: 1).state;
      final DateTime at = t0.add(const Duration(hours: 2));

      final GameState first = engine.tickIncome(state, at).state;
      final GameState second = engine.tickIncome(first, at).state;

      expect(second.coins, first.coins);
    });

    test('un reloj hacia atrás no regala monedas', () {
      final GameState state = engine.newGame(now: t0, seed: 1).state;
      final GameState back = engine
          .tickIncome(state, t0.subtract(const Duration(hours: 5)))
          .state;

      expect(back.coins, state.coins);
      expect(back.idleAccrued, state.idleAccrued);
    });
  });

  group('garantía de no bloqueo', () {
    test('sin monedas y con tablero vacío, el proveedor fía', () {
      final GameState stuck = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 0);

      expect(engine.canMakeProgress(stuck), isFalse);

      final GameStep step = engine.relieveIfStuck(stuck);

      expect(step.hasEvent<EmergencyRelief>(), isTrue);
      expect(
        step.state.coins,
        greaterThanOrEqualTo(EconomyConfig.defaults.generateCost),
      );
      expect(engine.canMakeProgress(step.state), isTrue);
    });

    test('con mercadería en el tablero nunca está bloqueado', () {
      GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(coins: 0);
      state = withItems(state, <int, BoardItem>{
        0: const BoardItem(id: 1, chainId: pan, level: 1),
      });

      // Aunque no pueda generar, siempre puede vender para recuperarse.
      expect(engine.canMakeProgress(state), isTrue);
      expect(engine.relieveIfStuck(state).events, isEmpty);
    });

    test('tablero lleno sin merges posibles sigue teniendo salida', () {
      GameState state = engine.newGame(now: t0, seed: 1).state;
      final int maxLevel = ProductCatalog.byId(pan).maxLevel;
      final List<BoardItem?> cells = List<BoardItem?>.generate(
        state.board.capacity,
        (int i) => BoardItem(id: i, chainId: pan, level: maxLevel),
      );
      state = state.copyWith(board: state.board.withCells(cells), coins: 0);

      expect(state.board.hasPossibleMerge(), isFalse);
      expect(state.board.isFull, isTrue);
      // Vender libera casillas: no es un bloqueo permanente.
      expect(engine.canMakeProgress(state), isTrue);
    });

    test('una partida jugada al azar nunca queda sin jugada posible', () {
      // Prueba de propiedad: 40 partidas × 400 acciones aleatorias.
      for (int seed = 0; seed < 40; seed++) {
        final Random rng = Random(seed);
        GameState state = engine.newGame(now: t0, seed: seed).state;

        for (int turn = 0; turn < 400; turn++) {
          final int action = rng.nextInt(10);
          GameStep step;

          if (action < 5) {
            step = engine.generate(state);
          } else if (action < 8) {
            final List<BoardItem> items = state.board.items();
            if (items.isEmpty) {
              step = engine.generate(state);
            } else {
              final List<int> occupied = <int>[
                for (int i = 0; i < state.board.capacity; i++)
                  if (state.board.at(i) != null) i,
              ];
              step = engine.drop(
                state,
                occupied[rng.nextInt(occupied.length)],
                rng.nextInt(state.board.capacity),
              );
            }
          } else if (action == 8 && state.orders.isNotEmpty) {
            step = engine.completeOrder(
              state,
              state.orders[rng.nextInt(state.orders.length)].id,
              now: t0,
            );
          } else {
            step = engine.sell(state, rng.nextInt(state.board.capacity));
          }

          // Es lo mismo que hace el controller tras cada acción.
          state = engine.relieveIfStuck(step.state).state;

          expect(
            engine.canMakeProgress(state),
            isTrue,
            reason: 'semilla $seed, turno $turn quedó sin salida',
          );
          expect(state.coins, greaterThanOrEqualTo(0));
          expect(state.orders.length, EconomyConfig.defaults.visibleOrders);
        }
      }
    });
  });

  group('volver a la app', () {
    test('cobra la ganancia offline una sola vez', () {
      final GameState state = engine.newGame(now: t0, seed: 1).state;
      final int rate = state.shopTier.coinsPerHour;

      final GameStep first = engine.resume(
        state: state,
        now: t0.add(const Duration(hours: 2)),
      );
      expect(first.state.coins, state.coins + rate * 2);
      expect(first.event<OfflineEarningsClaimed>().amount, rate * 2);

      // Volver de inmediato no vuelve a pagar.
      final GameStep second = engine.resume(
        state: first.state,
        now: t0.add(const Duration(hours: 2)),
      );
      expect(second.state.coins, first.state.coins);
      expect(second.hasEvent<OfflineEarningsClaimed>(), isFalse);
    });

    test('no ofrece cobro por debajo del mínimo', () {
      final GameState state = engine.newGame(now: t0, seed: 1).state;
      final GameStep step = engine.resume(
        state: state,
        now: t0.add(const Duration(seconds: 30)),
      );

      expect(step.hasEvent<OfflineEarningsClaimed>(), isFalse);
      expect(step.state.coins, state.coins);
    });

    test('rellena pedidos faltantes al cargar un save incompleto', () {
      final GameState state = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(orders: const <CustomerOrder>[]);

      final GameStep step = engine.resume(state: state, now: t0);
      expect(step.state.orders.length, EconomyConfig.defaults.visibleOrders);
    });
  });

  test('la semilla siguiente siempre es un nextInt válido', () {
    // Regresión: la cota se calculaba con `1 << 32`, que en la web se
    // desborda a 0 y hace que Random.nextInt lance RangeError.
    GameState state = engine.newGame(now: t0, seed: 1).state;
    for (int i = 0; i < 200; i++) {
      state = engine.generate(state.copyWith(coins: 999)).state;
      expect(state.rngSeed, greaterThanOrEqualTo(0));
      expect(state.rngSeed, lessThan(0x7FFFFFFF));
    }
  });

  test('saltar el tutorial lo marca como terminado', () {
    final GameState state = engine.newGame(now: t0, seed: 1).state;
    final GameStep step = engine.skipTutorial(state);
    expect(step.state.tutorialStep, TutorialStep.done);
  });
}
