import 'package:almacen/game/economy/economy_config.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/game_events.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/order.dart';
import 'package:almacen/game/models/product.dart';
import 'package:almacen/game/models/settings.dart';
import 'package:almacen/game/progression/shop_tiers.dart';
import 'package:almacen/game/progression/workers.dart';
import 'package:flutter_test/flutter_test.dart';

/// El trabajador es la primera pieza del juego que actúa sin el jugador
/// delante, así que lo que hay que probar no es sólo que funcione: es que no
/// se pase de la raya. Que no juegue por el jugador, que no le regale logros,
/// que no explote si vuelve una semana después, y que el contrato se acabe.
final DateTime t0 = DateTime.utc(2026, 8, 22, 12);

void main() {
  const String pan = ProductCatalog.panaderia;
  late GameEngine engine;

  setUp(() => engine = GameEngine());

  /// Partida con local de nivel suficiente para contratar y monedas de sobra.
  GameState boss({
    int coins = 100000,
    Map<int, BoardItem> items = const <int, BoardItem>{},
    int shopLevel = Workers.unlockShopLevel,
  }) {
    final GameState base = engine.newGame(now: t0, seed: 3).state;
    final List<BoardItem?> cells = base.board.mutableCells();
    items.forEach((int i, BoardItem item) => cells[i] = item);
    return base.copyWith(
      board: base.board.withCells(cells),
      coins: coins,
      shopLevel: shopLevel,
      lastSeenAt: t0,
      lastIncomeAt: t0,
    );
  }

  group('contratar', () {
    test('antes del nivel de local requerido no se puede', () {
      final GameStep step = engine.hireWorker(boss(shopLevel: 1), 1, t0);

      expect(step.state.workerLevel, 0);
      expect(
        step.events.whereType<ActionRejected>().first.reason,
        RejectReason.workerLocked,
      );
    });

    test('sin monedas tampoco', () {
      final GameStep step = engine.hireWorker(boss(coins: 0), 1, t0);

      expect(step.state.workerLevel, 0);
      expect(
        step.events.whereType<ActionRejected>().first.reason,
        RejectReason.notEnoughCoins,
      );
    });

    test('cobra y deja el contrato corriendo por las horas del nivel', () {
      final GameState before = boss();
      final GameStep step = engine.hireWorker(before, 2, t0);
      final WorkerTier tier = Workers.byLevel(2);

      expect(step.state.coins, before.coins - tier.hireCost);
      expect(step.state.workerLevel, 2);
      expect(step.state.workerUntil, t0.add(Duration(hours: tier.hours)));
      expect(engine.hasWorkerAt(step.state, t0), isTrue);
      expect(
        engine.hasWorkerAt(step.state, t0.add(Duration(hours: tier.hours + 1))),
        isFalse,
      );
    });

    test('contratar de nuevo extiende, no reemplaza', () {
      // Pagar por horas y perder las que quedaban sería un cobro silencioso.
      final GameStep first = engine.hireWorker(boss(), 1, t0);
      final GameStep second = engine.hireWorker(
        first.state,
        1,
        t0.add(const Duration(minutes: 30)),
      );

      final int hours = Workers.byLevel(1).hours;
      expect(second.state.workerUntil, t0.add(Duration(hours: hours * 2)));
    });

    test('al extender se queda el mejor de los dos niveles', () {
      final GameStep first = engine.hireWorker(boss(), 3, t0);
      final GameStep second = engine.hireWorker(
        first.state,
        1,
        t0.add(const Duration(minutes: 10)),
      );

      expect(
        second.state.workerLevel,
        3,
        reason: 'nadie paga un turno extra para terminar con alguien peor',
      );
    });
  });

  group('trabajar', () {
    test('junta los pares que sabe juntar', () {
      final GameState hired = engine
          .hireWorker(
            boss(
              items: <int, BoardItem>{
                0: const BoardItem(id: 90, chainId: pan, level: 1),
                1: const BoardItem(id: 91, chainId: pan, level: 1),
              },
            ),
            1,
            t0,
          )
          .state;

      final GameStep step = engine.runWorker(
        hired,
        t0.add(const Duration(minutes: 30)),
      );

      expect(step.state.board.occupied, greaterThan(0));
      expect(
        step.state.board.cells.whereType<BoardItem>().any(
          (BoardItem i) => i.level >= 2,
        ),
        isTrue,
      );
      expect(
        step.events.whereType<WorkerWorked>().first.merged,
        greaterThan(0),
      );
    });

    test('no toca lo que está por encima de su nivel', () {
      // Un nivel 1 llega hasta juntar dos de nivel 2. Un par de nivel 3 lo
      // ignora: si juntara todo, contratarlo una vez reemplazaría al jugador.
      final int cap = Workers.byLevel(1).maxMergeLevel;
      final GameState hired = engine
          .hireWorker(
            boss(
              coins: 0,
              items: <int, BoardItem>{
                0: BoardItem(id: 90, chainId: pan, level: cap + 1),
                1: BoardItem(id: 91, chainId: pan, level: cap + 1),
              },
            ).copyWith(coins: Workers.byLevel(1).hireCost),
            1,
            t0,
          )
          .state;

      final GameStep step = engine.runWorker(
        hired,
        t0.add(const Duration(hours: 1)),
      );

      expect(step.state.board.at(0)?.level, cap + 1);
      expect(step.state.board.at(1)?.level, cap + 1);
    });

    test('sin nada que juntar le pide mercadería al proveedor', () {
      final GameState hired = engine.hireWorker(boss(), 1, t0).state;
      final int before = hired.board.occupied;

      final GameStep step = engine.runWorker(
        hired,
        t0.add(const Duration(hours: 1)),
      );

      expect(step.state.board.occupied, greaterThan(before));
      expect(
        step.events.whereType<WorkerWorked>().first.bought,
        greaterThan(0),
      );
    });

    test('no gasta más monedas de las que hay', () {
      final GameState hired = engine
          .hireWorker(boss(coins: Workers.byLevel(1).hireCost + 5), 1, t0)
          .state;

      final GameStep step = engine.runWorker(
        hired,
        t0.add(const Duration(hours: 2)),
      );

      expect(step.state.coins, greaterThanOrEqualTo(0));
      expect(step.state.coins, lessThan(EconomyConfig.defaults.generateCost));
    });

    test('el trabajo se topa a las horas contratadas', () {
      // Volver después de una semana no puede desencadenar un bucle enorme ni
      // regalar el trabajo de días que nadie pagó.
      final GameState hired = engine.hireWorker(boss(), 1, t0).state;
      final WorkerTier tier = Workers.byLevel(1);

      final GameStep step = engine.runWorker(
        hired,
        t0.add(const Duration(days: 7)),
      );

      final WorkerWorked? worked = step.events
          .whereType<WorkerWorked>()
          .firstOrNull;
      final int actions = (worked?.merged ?? 0) + (worked?.bought ?? 0);
      expect(actions, lessThanOrEqualTo(tier.actionsPerHour * tier.hours));
    });

    test('la racha de fusiones sigue siendo del jugador', () {
      final GameState hired = engine
          .hireWorker(
            boss(
              items: <int, BoardItem>{
                0: const BoardItem(id: 90, chainId: pan, level: 1),
                1: const BoardItem(id: 91, chainId: pan, level: 1),
                2: const BoardItem(id: 92, chainId: pan, level: 1),
                3: const BoardItem(id: 93, chainId: pan, level: 1),
              },
            ),
            1,
            t0,
          )
          .state
          .copyWith(mergeStreak: 2, bestMergeStreak: 2);

      final GameStep step = engine.runWorker(
        hired,
        t0.add(const Duration(hours: 1)),
      );

      expect(step.state.mergeStreak, 2);
      expect(
        step.state.bestMergeStreak,
        2,
        reason: 'el logro de fusionar seguido no se gana pagándole a alguien',
      );
    });

    test('al vencer el contrato se despide una sola vez', () {
      final GameState hired = engine.hireWorker(boss(), 1, t0).state;
      final DateTime after = t0.add(
        Duration(hours: Workers.byLevel(1).hours + 1),
      );

      final GameStep first = engine.runWorker(hired, after);
      expect(first.events.whereType<WorkerFinished>(), isNotEmpty);
      expect(first.state.workerLevel, 0);
      expect(engine.hasWorkerAt(first.state, after), isFalse);

      final GameStep second = engine.runWorker(first.state, after);
      expect(
        second.events.whereType<WorkerFinished>(),
        isEmpty,
        reason: 'un empleado que ya se fue no se vuelve a despedir',
      );
    });

    test('sin nadie contratado no pasa nada', () {
      final GameState idle = boss();
      final GameStep step = engine.runWorker(
        idle,
        t0.add(const Duration(hours: 5)),
      );

      expect(step.state, same(idle));
      expect(step.events, isEmpty);
    });
  });

  group('llenar el mesón a tope', () {
    test('pide hasta llenar el mesón', () {
      final GameStep step = engine.generateAll(boss());

      expect(step.state.board.isFull, isTrue);
      expect(
        step.events.whereType<BoardFilled>().first.count,
        step.state.board.occupied,
      );
    });

    test('se detiene cuando se acaban las monedas', () {
      final int cost = EconomyConfig.defaults.generateCost;
      final GameStep step = engine.generateAll(boss(coins: cost * 3));

      expect(step.events.whereType<BoardFilled>().first.count, 3);
      expect(step.state.coins, lessThan(cost));
      expect(step.state.board.isFull, isFalse);
    });

    test('sin monedas para ni una, se rechaza sin cambiar nada', () {
      final GameState broke = boss(coins: 0);
      final GameStep step = engine.generateAll(broke);

      expect(step.state, same(broke));
      expect(
        step.events.whereType<ActionRejected>().first.reason,
        RejectReason.notEnoughCoins,
      );
    });
  });

  group('alimento para mascotas', () {
    test('sin mascota el rubro no existe', () {
      final List<ProductChain> chains = ProductCatalog.unlockedFor(99);

      expect(
        chains.map((ProductChain c) => c.id),
        isNot(contains(ProductCatalog.mascotas)),
      );
    });

    test('con mascota y nivel suficiente aparece', () {
      final List<ProductChain> chains = ProductCatalog.unlockedFor(
        99,
        hasPet: true,
      );

      expect(
        chains.map((ProductChain c) => c.id),
        contains(ProductCatalog.mascotas),
      );
    });

    test('paga más que el resto por la misma cantidad y nivel', () {
      final int normal = engine.economy.lineValue(
        const OrderLine(chainId: pan, level: 2, quantity: 2),
      );
      final int pet = engine.economy.lineValue(
        const OrderLine(
          chainId: ProductCatalog.mascotas,
          level: 2,
          quantity: 2,
        ),
      );

      expect(pet, greaterThan(normal));
    });

    test('comprarlo también cuesta más: no es dinero gratis', () {
      // El margen sube parejo de los dos lados. Si sólo subiera el pago,
      // comprar y entregar sería un bucle infinito de monedas.
      for (int level = 1; level <= 4; level++) {
        final int price = engine.economy.buyPriceOf(
          ProductCatalog.mascotas,
          level,
        );
        final int reward = engine.economy.lineValue(
          OrderLine(
            chainId: ProductCatalog.mascotas,
            level: level,
            quantity: 1,
          ),
        );
        expect(
          price,
          greaterThan(reward),
          reason: 'comprar nunca puede rendir más que entregar (nivel $level)',
        );
      }
    });

    test('el rubro no tiene cinco niveles: es más corto y más caro', () {
      expect(
        ProductCatalog.byId(ProductCatalog.mascotas).maxLevel,
        lessThan(ProductCatalog.byId(pan).maxLevel),
      );
    });
  });

  group('cuándo alcanzará para mejorar', () {
    test('si ya alcanza, no hay hora futura que avisar', () {
      final GameState rich = boss(shopLevel: 1).copyWith(coins: 999999);

      expect(engine.upgradeAffordableAt(rich), isNull);
    });

    test('si la caja sola no llega, tampoco: eso depende de vender', () {
      final GameState poor = boss(shopLevel: 1)
          .copyWith(coins: 0, idleAccrued: 0);

      // El costo del nivel 2 está muy por encima de lo que aguanta la caja del
      // nivel 1, así que no hay nada honesto que prometer.
      expect(
        ShopTiers.next(1)!.upgradeCost,
        greaterThan(engine.tillCapacity(poor)),
      );
      expect(engine.upgradeAffordableAt(poor), isNull);
    });

    test('cuando la caja alcanza, la hora cae dentro de lo razonable', () {
      final ShopTier tier = ShopTiers.byLevel(1);
      final ShopTier target = ShopTiers.next(1)!;
      // Le faltan exactamente dos horas de caja para el siguiente nivel.
      final GameState almost = boss(shopLevel: 1).copyWith(
        coins: target.upgradeCost - tier.coinsPerHour * 2,
        idleAccrued: 0,
      );

      final DateTime? when = engine.upgradeAffordableAt(almost);
      expect(when, isNotNull);
      expect(when, t0.add(const Duration(hours: 2)));
    });

    test('en el último nivel del local ya no hay nada que avisar', () {
      final GameState top = boss(shopLevel: ShopTiers.maxLevel);

      expect(engine.upgradeAffordableAt(top), isNull);
    });
  });

  group('mascota elegida', () {
    test('se guarda dentro del rango y "ninguna" es válido', () {
      const GameSettings none = GameSettings();
      expect(none.petId, 0);

      final GameSettings picked = none.copyWith(petId: GameSettings.petCount);
      expect(picked.petId, GameSettings.petCount);
      expect(
        GameSettings.fromJson(<String, Object?>{'pet': 99}).petId,
        GameSettings.petCount,
        reason: 'un save manoseado no puede pedir una mascota que no existe',
      );
    });
  });
}
