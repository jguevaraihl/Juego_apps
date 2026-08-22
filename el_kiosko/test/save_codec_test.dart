import 'dart:convert';

import 'package:almacen/data/local/save_codec.dart';
import 'package:almacen/game/economy/economy_config.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/order.dart';
import 'package:almacen/game/models/product.dart';
import 'package:almacen/game/models/settings.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime t0 = DateTime.utc(2026, 8, 22, 12);
const EconomyConfig config = EconomyConfig.defaults;

/// Pasa por JSON de verdad, para detectar tipos que no sobreviven el disco.
Map<String, dynamic> roundTrip(Map<String, dynamic> data) =>
    Map<String, dynamic>.from(jsonDecode(jsonEncode(data)) as Map);

void main() {
  final GameEngine engine = GameEngine();

  GameState sampleState() {
    GameState state = engine.newGame(now: t0, seed: 11).state;
    final List<BoardItem?> cells = state.board.mutableCells();
    cells[0] = const BoardItem(
      id: 1,
      chainId: ProductCatalog.panaderia,
      level: 3,
    );
    cells[7] = const BoardItem(
      id: 2,
      chainId: ProductCatalog.bebidas,
      level: 1,
    );
    return state = state.copyWith(
      board: state.board.withCells(cells),
      coins: 1234,
      xp: 456,
      shopLevel: 3,
      nextItemId: 88,
      nextOrderId: 99,
      tutorialStep: TutorialStep.upgrade,
      discovered: <String>{'panaderia:1', 'panaderia:2', 'bebidas:1'},
      totalMerges: 42,
      totalOrdersCompleted: 17,
      settings: const GameSettings(
        soundEnabled: false,
        hapticsEnabled: true,
        reducedMotion: true,
        showIdleHints: false,
      ),
    );
  }

  group('serialización', () {
    test('ida y vuelta conserva todo el progreso', () {
      final GameState original = sampleState();
      final GameState? restored = SaveCodec.decode(
        roundTrip(SaveCodec.encode(original)),
        config: config,
      );

      expect(restored, isNotNull);
      expect(restored!.coins, original.coins);
      expect(restored.xp, original.xp);
      expect(restored.shopLevel, original.shopLevel);
      expect(restored.nextItemId, original.nextItemId);
      expect(restored.nextOrderId, original.nextOrderId);
      expect(restored.rngSeed, original.rngSeed);
      expect(restored.tutorialStep, original.tutorialStep);
      expect(restored.discovered, original.discovered);
      expect(restored.totalMerges, original.totalMerges);
      expect(restored.totalOrdersCompleted, original.totalOrdersCompleted);
      expect(restored.lastSeenAt.toUtc(), original.lastSeenAt.toUtc());
    });

    test('conserva el tablero casilla por casilla', () {
      final GameState original = sampleState();
      final GameState restored = SaveCodec.decode(
        roundTrip(SaveCodec.encode(original)),
        config: config,
      )!;

      expect(restored.board.columns, original.board.columns);
      expect(restored.board.rows, original.board.rows);
      for (int i = 0; i < original.board.capacity; i++) {
        expect(
          restored.board.at(i),
          original.board.at(i),
          reason: 'casilla $i',
        );
      }
    });

    test('conserva los pedidos con su recompensa congelada', () {
      final GameState original = sampleState();
      final GameState restored = SaveCodec.decode(
        roundTrip(SaveCodec.encode(original)),
        config: config,
      )!;

      expect(restored.orders.length, original.orders.length);
      for (int i = 0; i < original.orders.length; i++) {
        final CustomerOrder a = original.orders[i];
        final CustomerOrder b = restored.orders[i];
        expect(b.id, a.id);
        expect(b.customerId, a.customerId);
        expect(b.reward, a.reward);
        expect(b.xp, a.xp);
        expect(b.isSpecial, a.isSpecial);
        expect(b.lines, a.lines);
      }
    });

    test('conserva los ajustes', () {
      final GameState original = sampleState();
      final GameState restored = SaveCodec.decode(
        roundTrip(SaveCodec.encode(original)),
        config: config,
      )!;

      expect(restored.settings.soundEnabled, isFalse);
      expect(restored.settings.hapticsEnabled, isTrue);
      expect(restored.settings.reducedMotion, isTrue);
      expect(restored.settings.showIdleHints, isFalse);
    });
  });

  group('migración de esquema', () {
    test('un save v0 (sin schemaVersion) se migra con valores por defecto', () {
      final Map<String, dynamic> v1 = roundTrip(
        SaveCodec.encode(sampleState()),
      );
      // Se simula un save antiguo: sin versión ni los campos agregados después.
      final Map<String, dynamic> legacy = Map<String, dynamic>.from(v1)
        ..remove('schemaVersion')
        ..remove('discovered')
        ..remove('totalMerges')
        ..remove('totalOrdersCompleted')
        ..remove('economyVersion');

      final GameState? restored = SaveCodec.decode(legacy, config: config);

      expect(restored, isNotNull, reason: 'un save viejo no debe perderse');
      // El progreso que sí existía se conserva.
      expect(restored!.coins, 1234);
      expect(restored.shopLevel, 3);
      // Y los campos nuevos toman valores seguros.
      expect(restored.discovered, isEmpty);
      expect(restored.totalMerges, 0);
      expect(restored.totalOrdersCompleted, 0);
      expect(restored.economyVersion, 1);
    });

    test('un save v1 convierte el nombre del cliente en un índice', () {
      // v1 guardaba el nombre ya traducido al español. Al internacionalizar,
      // el pedido pasa a guardar un índice que la UI resuelve por idioma.
      final Map<String, dynamic> v1 = roundTrip(SaveCodec.encode(sampleState()))
        ..['schemaVersion'] = 1;
      final List<dynamic> orders = v1['orders'] as List<dynamic>;
      for (final dynamic raw in orders) {
        final Map<String, dynamic> order = raw as Map<String, dynamic>;
        order.remove('customerId');
        order['customer'] = 'Don Chofer';
      }

      final GameState? restored = SaveCodec.decode(v1, config: config);

      expect(restored, isNotNull, reason: 'no se puede perder la partida');
      expect(
        restored!.orders.length,
        (v1['orders'] as List<dynamic>).length,
        reason: 'los pedidos en pantalla no se descartan',
      );
      for (final CustomerOrder order in restored.orders) {
        expect(order.customerId, inInclusiveRange(0, 11));
      }
      // El resto del progreso queda intacto.
      expect(restored.coins, 1234);
      expect(restored.shopLevel, 3);
    });

    test('la migración v1 -> v2 es determinista', () {
      Map<String, dynamic> legacy() {
        final Map<String, dynamic> v1 = roundTrip(
          SaveCodec.encode(sampleState()),
        )..['schemaVersion'] = 1;
        for (final dynamic raw in v1['orders'] as List<dynamic>) {
          (raw as Map<String, dynamic>)
            ..remove('customerId')
            ..['customer'] = 'La vecina del 3';
        }
        return v1;
      }

      final GameState a = SaveCodec.decode(legacy(), config: config)!;
      final GameState b = SaveCodec.decode(legacy(), config: config)!;

      expect(
        a.orders.map((CustomerOrder o) => o.customerId),
        b.orders.map((CustomerOrder o) => o.customerId),
      );
    });

    test('migrate deja el save en la versión actual', () {
      final Map<String, dynamic> legacy = roundTrip(
        SaveCodec.encode(sampleState()),
      )..remove('schemaVersion');

      final Map<String, dynamic> migrated = SaveCodec.migrate(legacy);
      expect(migrated['schemaVersion'], SaveCodec.currentSchemaVersion);
    });

    test('un save v2 conserva el tablero completo del jugador', () {
      // El tablero chico es el punto de partida de las partidas NUEVAS. A
      // quien ya venía jugando con las 8 filas no se le puede quitar espacio
      // en una actualización: sería quitarle progreso ya conseguido.
      final Map<String, dynamic> v2 = roundTrip(SaveCodec.encode(sampleState()))
        ..['schemaVersion'] = 2
        ..remove('idleAccrued')
        ..remove('lastIncomeAt');
      (v2['board'] as Map<String, dynamic>).remove('unlockedRows');

      final GameState? restored = SaveCodec.decode(v2, config: config);

      expect(restored, isNotNull);
      expect(
        restored!.board.unlockedRows,
        restored.board.rows,
        reason: 'el jugador conserva las filas que ya tenía',
      );
      expect(restored.board.canExpand, isFalse);
      expect(restored.idleAccrued, 0);
      expect(restored.coins, 1234);
    });

    test('un save v2 ancla la ganancia pasiva al último guardado', () {
      final Map<String, dynamic> v2 = roundTrip(SaveCodec.encode(sampleState()))
        ..['schemaVersion'] = 2
        ..remove('lastIncomeAt');

      final GameState restored = SaveCodec.decode(v2, config: config)!;

      // Sin marca previa se usa lastSeenAt: es el mismo instante que ya usaba
      // el cobro al volver, así que no se regala ni se pierde tiempo.
      expect(restored.lastIncomeAt.toUtc(), restored.lastSeenAt.toUtc());
    });

    test('un save de una versión futura no se adivina', () {
      final Map<String, dynamic> future = roundTrip(
        SaveCodec.encode(sampleState()),
      )..['schemaVersion'] = SaveCodec.currentSchemaVersion + 5;

      // decode devuelve null y el juego arranca partida nueva en vez de
      // corromper el progreso o crashear.
      expect(SaveCodec.decode(future, config: config), isNull);
      expect(() => SaveCodec.migrate(future), throwsStateError);
    });
  });

  group('robustez', () {
    test('un save corrupto devuelve null en vez de crashear', () {
      expect(
        SaveCodec.decode(<String, dynamic>{'basura': true}, config: config),
        isNull,
      );
      expect(
        SaveCodec.decode(<String, dynamic>{
          'schemaVersion': 1,
          'coins': 'no es un número',
        }, config: config),
        isNull,
      );
    });

    test('un tablero truncado se completa con casillas vacías', () {
      final Map<String, dynamic> save = roundTrip(
        SaveCodec.encode(sampleState()),
      );
      (save['board'] as Map<String, dynamic>)['cells'] = <dynamic>[null, null];

      final GameState? restored = SaveCodec.decode(save, config: config);

      expect(restored, isNotNull);
      expect(restored!.board.capacity, config.boardCapacity);
      expect(restored.board.isEmpty, isTrue);
    });
  });
}
