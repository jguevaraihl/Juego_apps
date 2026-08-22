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

      final GameStep step = engine.completeOrder(state, order.id);

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

      final GameStep step = engine.completeOrder(state, 777);

      expect(step.hasEvent<OrderCompleted>(), isTrue);
      expect(step.state.tutorialStep, TutorialStep.merge);
    });

    test('no se puede completar sin la mercadería', () {
      final GameState state = engine.newGame(now: t0, seed: 3).state;
      final CustomerOrder order = state.orders.first;

      final GameStep step = engine.completeOrder(state, order.id);

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

      final GameStep step = engine.rerollOrder(state, order.id);

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

      final GameStep step = engine.rerollOrder(state, before[1].id);
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

      final GameStep step = engine.completeOrder(state, target.id);
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
      final GameStep step = engine.rerollOrder(state, state.orders.first.id);

      expect(step.event<ActionRejected>().reason, RejectReason.notEnoughCoins);
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

      final GameStep step = engine.completeOrder(state, 999);

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
