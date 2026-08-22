import 'package:almacen/data/local/save_codec.dart';
import 'package:almacen/data/local/save_store.dart';
import 'package:almacen/data/repositories/game_repository.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/game_events.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime t0 = DateTime.utc(2026, 8, 22, 12);

void main() {
  late GameEngine engine;
  late MemorySaveStore store;
  late GameRepository repository;

  setUp(() {
    engine = GameEngine();
    store = MemorySaveStore();
    repository = GameRepository(
      store,
      engine,
      autosaveDelay: const Duration(milliseconds: 20),
    );
  });

  tearDown(() => repository.dispose());

  test('sin save previo empieza partida nueva', () async {
    final GameStep step = await repository.load(now: t0);

    expect(step.state.coins, engine.config.startingCoins);
    expect(step.state.orders.length, engine.config.visibleOrders);
    expect(step.state.totalOrdersCompleted, 0);
  });

  test('guardar y cargar conserva el progreso', () async {
    final GameState original = engine
        .newGame(now: t0, seed: 5)
        .state
        .copyWith(coins: 777, shopLevel: 2, totalMerges: 9);

    await repository.saveNow(original);
    final GameStep loaded = await repository.load(now: t0);

    expect(loaded.state.coins, 777);
    expect(loaded.state.shopLevel, 2);
    expect(loaded.state.totalMerges, 9);
  });

  test('al cargar se cobra la ganancia acumulada', () async {
    final GameState original = engine
        .newGame(now: t0, seed: 5)
        .state
        .copyWith(coins: 100);
    await repository.saveNow(original);

    final GameStep loaded = await repository.load(
      now: t0.add(const Duration(hours: 3)),
    );

    final int expected = original.shopTier.coinsPerHour * 3;
    expect(loaded.state.coins, 100 + expected);
    expect(loaded.events.whereType<OfflineEarningsClaimed>(), isNotEmpty);
  });

  test('un save corrupto no rompe la app: arranca partida nueva', () async {
    await store.write(<String, dynamic>{'schemaVersion': 1, 'coins': 'malo'});

    final GameStep step = await repository.load(now: t0);

    expect(step.state.coins, engine.config.startingCoins);
  });

  test('el autoguardado colapsa varias acciones en una escritura', () async {
    final GameState state = engine.newGame(now: t0, seed: 5).state;

    repository.scheduleSave(state.copyWith(coins: 1));
    repository.scheduleSave(state.copyWith(coins: 2));
    repository.scheduleSave(state.copyWith(coins: 3));
    expect(store.writeCount, 0, reason: 'todavía no debe haber escrito');

    await repository.flush();

    expect(store.writeCount, 1);
    final GameState? saved = SaveCodec.decode(
      (await store.read())!,
      config: engine.config,
    );
    expect(saved!.coins, 3, reason: 'debe guardar el estado más reciente');
  });

  test('flush sin cambios pendientes no escribe', () async {
    await repository.flush();
    expect(store.writeCount, 0);
  });

  test('deleteSave borra la partida', () async {
    await repository.saveNow(engine.newGame(now: t0, seed: 5).state);
    expect(await store.read(), isNotNull);

    await repository.deleteSave();

    expect(await store.read(), isNull);
  });
}
