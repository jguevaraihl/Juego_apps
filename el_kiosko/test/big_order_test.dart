import 'package:almacen/game/economy/economy_config.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/game_events.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/order.dart';
import 'package:flutter_test/flutter_test.dart';

extension on GameStep {
  bool hasEvent<T extends GameEvent>() => events.whereType<T>().isNotEmpty;
  T event<T extends GameEvent>() => events.whereType<T>().first;
}

/// El pedido mayorista es el único que caduca. Lo que hay que garantizar es
/// que **no castigue**: perderlo no le quita nada al jugador, y que no se
/// pueda convertir en una fuente infinita de plata apareciendo todo el rato.
void main() {
  final GameEngine engine = GameEngine();
  final EconomyConfig config = EconomyConfig.defaults;
  final DateTime t0 = DateTime.utc(2026, 9, 1, 12);

  /// Partida con nivel suficiente para que el mayorista esté desbloqueado.
  GameState ready({DateTime? nextBigOrderAt}) {
    final GameState base = engine.newGame(now: t0, seed: 11).state;
    return base.copyWith(xp: 5000, coins: 500, nextBigOrderAt: nextBigOrderAt);
  }

  CustomerOrder? bigOf(GameState s) =>
      s.orders.where((CustomerOrder o) => o.isBig).firstOrNull;

  test('no aparece antes del nivel mínimo', () {
    final GameState novice = engine
        .newGame(now: t0, seed: 3)
        .state
        .copyWith(nextBigOrderAt: t0.subtract(const Duration(days: 1)));
    expect(
      novice.playerLevel(engine.economy),
      lessThan(config.bigOrderUnlockPlayerLevel),
    );

    final GameStep step = engine.refreshBigOrder(novice, t0);
    expect(bigOf(step.state), isNull);
  });

  test('la primera vez sólo agenda, no dispara', () {
    // Que el primer mayorista caiga en el instante en que se cumple el nivel
    // sería desconcertante: el jugador no sabría de dónde salió.
    final GameStep step = engine.refreshBigOrder(ready(), t0);
    expect(bigOf(step.state), isNull);
    expect(step.state.nextBigOrderAt, isNotNull);
    expect(step.state.nextBigOrderAt!.isAfter(t0), isTrue);
  });

  test('aparece cuando llega su hora, y avisa', () {
    final GameStep step = engine.refreshBigOrder(
      ready(nextBigOrderAt: t0.subtract(const Duration(minutes: 1))),
      t0,
    );

    final CustomerOrder? big = bigOf(step.state);
    expect(big, isNotNull);
    expect(big!.isBig, isTrue);
    expect(step.hasEvent<BigOrderArrived>(), isTrue);
    expect(
      big.expiresAt,
      t0.add(Duration(minutes: config.bigOrderWindowMinutes)),
    );
  });

  test('no ocupa uno de los tres cupos normales', () {
    final GameStep step = engine.refreshBigOrder(
      ready(nextBigOrderAt: t0.subtract(const Duration(minutes: 1))),
      t0,
    );
    expect(
      step.state.orders.where((CustomerOrder o) => !o.isBig).length,
      config.visibleOrders,
    );
    expect(step.state.orders.length, config.visibleOrders + 1);
  });

  test('paga más que el mismo contenido en pedidos normales', () {
    final GameStep step = engine.refreshBigOrder(
      ready(nextBigOrderAt: t0.subtract(const Duration(minutes: 1))),
      t0,
    );
    final CustomerOrder big = bigOf(step.state)!;

    final int plain = engine.economy.orderReward(
      big.lines.fold(
        0,
        (int sum, OrderLine l) =>
            sum + engine.economy.itemValue(l.level) * l.quantity,
      ),
    );
    expect(big.reward, greaterThan(plain));
  });

  test('caduca solo, y no se lleva nada del jugador', () {
    GameStep step = engine.refreshBigOrder(
      ready(nextBigOrderAt: t0.subtract(const Duration(minutes: 1))),
      t0,
    );
    final int coinsBefore = step.state.coins;
    final int itemsBefore = step.state.board.occupied;

    step = engine.refreshBigOrder(
      step.state,
      t0.add(Duration(minutes: config.bigOrderWindowMinutes + 1)),
    );

    expect(bigOf(step.state), isNull);
    expect(step.hasEvent<BigOrderExpired>(), isTrue);
    expect(step.state.coins, coinsBefore, reason: 'perderlo no cuesta monedas');
    expect(step.state.board.occupied, itemsBefore);
    // Y los tres normales siguen ahí.
    expect(step.state.orders.length, config.visibleOrders);
  });

  test('tras vencer, el siguiente respeta el descanso completo', () {
    GameStep step = engine.refreshBigOrder(
      ready(nextBigOrderAt: t0.subtract(const Duration(minutes: 1))),
      t0,
    );
    final DateTime expired = t0.add(
      Duration(minutes: config.bigOrderWindowMinutes + 1),
    );
    step = engine.refreshBigOrder(step.state, expired);

    // Justo después no vuelve.
    final GameStep soon = engine.refreshBigOrder(
      step.state,
      expired.add(const Duration(minutes: 5)),
    );
    expect(bigOf(soon.state), isNull);

    // Pasado el descanso, sí.
    final GameStep later = engine.refreshBigOrder(
      step.state,
      expired.add(Duration(minutes: config.bigOrderCooldownMinutes + 1)),
    );
    expect(bigOf(later.state), isNotNull);
  });

  test('mientras está vivo no aparece un segundo', () {
    GameStep step = engine.refreshBigOrder(
      ready(nextBigOrderAt: t0.subtract(const Duration(minutes: 1))),
      t0,
    );
    for (int i = 0; i < 10; i++) {
      step = engine.refreshBigOrder(
        step.state,
        t0.add(Duration(seconds: 30 * i)),
      );
    }
    expect(step.state.orders.where((CustomerOrder o) => o.isBig).length, 1);
  });

  test('no se puede cambiar por otro', () {
    final GameStep step = engine.refreshBigOrder(
      ready(nextBigOrderAt: t0.subtract(const Duration(minutes: 1))),
      t0,
    );
    final CustomerOrder big = bigOf(step.state)!;

    final GameStep rerolled = engine.rerollOrder(step.state, big.id, now: t0);
    expect(
      rerolled.event<ActionRejected>().reason,
      RejectReason.cannotRerollBig,
    );
    expect(bigOf(rerolled.state)?.id, big.id);
  });

  test('al entregarlo se retira y no lo reemplaza otro', () {
    GameStep step = engine.refreshBigOrder(
      ready(nextBigOrderAt: t0.subtract(const Duration(minutes: 1))),
      t0,
    );
    final CustomerOrder big = bigOf(step.state)!;

    // Se le pone al jugador exactamente lo que el mayorista pide.
    GameState stocked = step.state;
    int nextId = stocked.nextItemId;
    for (final OrderLine line in big.lines) {
      for (int i = 0; i < line.quantity; i++) {
        final List<BoardItem?> cells = stocked.board.mutableCells();
        final int slot = stocked.board.freeIndexes().first;
        cells[slot] = BoardItem(
          id: nextId++,
          chainId: line.chainId,
          level: line.level,
        );
        stocked = stocked.copyWith(board: stocked.board.withCells(cells));
      }
    }
    stocked = stocked.copyWith(nextItemId: nextId);

    final int before = stocked.coins;
    step = engine.completeOrder(stocked, big.id, now: t0);

    expect(bigOf(step.state), isNull);
    expect(step.state.coins, before + big.reward);
    expect(
      step.state.orders.length,
      config.visibleOrders,
      reason: 'el mayorista es un evento, no un cupo que se repone',
    );
  });
}
