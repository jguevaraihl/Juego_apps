import 'package:almacen/app/providers.dart';
import 'package:almacen/data/local/save_codec.dart';
import 'package:almacen/data/local/save_store.dart';
import 'package:almacen/data/repositories/game_repository.dart';
import 'package:almacen/game/economy/economy.dart';
import 'package:almacen/game/game_controller.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/product.dart';
import 'package:almacen/game/models/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deshacer vive en el controlador, no en el motor: el motor es puro y no
/// tiene historia. Lo que hay que garantizar es que deshacer devuelva
/// exactamente lo perdido, que no sirva para fabricar monedas, y que no
/// rebobine el reloj.
void main() {
  late GameEngine engine;

  setUp(() => engine = GameEngine());

  /// Arranca un contenedor con la partida ya cargada desde un save en memoria,
  /// que es el mismo camino que usa la app de verdad.
  Future<ProviderContainer> boot(GameState state) async {
    final MemorySaveStore store = MemorySaveStore();
    await store.write(SaveCodec.encode(state));

    final ProviderContainer container = ProviderContainer(
      overrides: [
        saveStoreProvider.overrideWithValue(store),
        gameRepositoryProvider.overrideWith(
          (Ref ref) => GameRepository(
            store,
            ref.watch(gameEngineProvider),
            autosaveDelay: const Duration(milliseconds: 1),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(gameControllerProvider);
    // La carga es asíncrona; se espera a que la partida esté lista.
    while (!container.read(gameControllerProvider).isReady) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    return container;
  }

  /// Partida a medida, con el reloj anclado en "ahora" para que no se acredite
  /// ganancia pasiva sola y enturbie las cuentas.
  GameState scenario({
    int coins = 100,
    Map<int, BoardItem> items = const <int, BoardItem>{},
    Set<String>? discovered,
    double idleAccrued = 0,
  }) {
    final GameState base = engine.newGame(now: DateTime.now(), seed: 1).state;
    final List<BoardItem?> cells = base.board.mutableCells();
    items.forEach((int i, BoardItem item) => cells[i] = item);
    final DateTime now = DateTime.now();

    return base.copyWith(
      board: base.board.withCells(cells),
      coins: coins,
      idleAccrued: idleAccrued,
      lastSeenAt: now,
      lastIncomeAt: now,
      discovered: discovered,
      settings: const GameSettings(showIdleHints: false),
    );
  }

  const BoardItem pan1 = BoardItem(
    id: 90,
    chainId: ProductCatalog.panaderia,
    level: 1,
  );
  const BoardItem pan1b = BoardItem(
    id: 91,
    chainId: ProductCatalog.panaderia,
    level: 1,
  );

  test('vender y deshacer devuelve el producto y quita las monedas', () async {
    final ProviderContainer c = await boot(
      scenario(items: <int, BoardItem>{0: pan1}),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);

    controller.sell(0);
    expect(c.read(gameControllerProvider).state!.board.at(0), isNull);
    expect(c.read(gameControllerProvider).state!.coins, greaterThan(100));
    expect(c.read(gameControllerProvider).undo?.action, UndoableAction.sell);

    controller.undo();
    expect(c.read(gameControllerProvider).state!.coins, 100);
    expect(c.read(gameControllerProvider).state!.board.at(0)?.level, 1);
    // Una sola vez: deshacer no se encadena.
    expect(c.read(gameControllerProvider).undo, isNull);
  });

  test('deshacer no es una máquina de monedas', () async {
    final ProviderContainer c = await boot(
      scenario(items: <int, BoardItem>{0: pan1}),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);

    for (int i = 0; i < 20; i++) {
      controller.sell(0);
      controller.undo();
    }

    expect(c.read(gameControllerProvider).state!.coins, 100);
    expect(c.read(gameControllerProvider).state!.board.at(0), isNotNull);
  });

  test('deshacer no rebobina la caja', () async {
    final ProviderContainer c = await boot(
      scenario(items: <int, BoardItem>{0: pan1}, idleAccrued: 10),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);

    controller.sell(0);
    final double before = c.read(gameControllerProvider).state!.idleAccrued;

    controller.undo();
    expect(
      c.read(gameControllerProvider).state!.idleAccrued,
      greaterThanOrEqualTo(before),
      reason: 'la caja no puede volver atrás al deshacer una venta',
    );
  });

  test('la jugada siguiente cierra la ventana', () async {
    final ProviderContainer c = await boot(
      scenario(items: <int, BoardItem>{0: pan1}),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);

    controller.sell(0);
    expect(c.read(gameControllerProvider).undo, isNotNull);

    controller.generate();
    expect(
      c.read(gameControllerProvider).undo,
      isNull,
      reason: 'generar no es deshacible y cierra la ventana',
    );
  });

  test('el latido de la ganancia NO cierra la ventana', () async {
    // Regresión: el contador corre una vez por segundo. Si contara como
    // jugada, deshacer duraría menos de un segundo y sería inútil.
    final ProviderContainer c = await boot(
      scenario(items: <int, BoardItem>{0: pan1}),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);

    controller.sell(0);
    controller.tickIncome();
    controller.tickIncome();

    expect(c.read(gameControllerProvider).undo?.action, UndoableAction.sell);
  });

  test('una acción rechazada no cierra la ventana', () async {
    // Con monedas de sobra: sin ellas saltaría el rescate del proveedor al
    // vender la única ficha, y ese caso ya no ofrece deshacer a propósito.
    final ProviderContainer c = await boot(
      scenario(items: <int, BoardItem>{0: pan1}, discovered: const <String>{}),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);

    controller.sell(0);
    expect(c.read(gameControllerProvider).undo, isNotNull);

    // Comprar algo nunca descubierto: la acción se rechaza y no cambia nada.
    controller.buyProduct(ProductCatalog.aseo, 4);
    expect(c.read(gameControllerProvider).undo?.action, UndoableAction.sell);
  });

  test('si tuvo que saltar el rescate, no se ofrece deshacer', () async {
    // Deshacer devolvería al jugador al estado sin salida, y el rescate
    // saltaría de nuevo en la jugada siguiente: un bucle raro y sin sentido.
    final ProviderContainer c = await boot(
      scenario(coins: 0, items: <int, BoardItem>{0: pan1}),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);

    controller.sell(0);
    expect(c.read(gameControllerProvider).undo, isNull);
  });

  test('fusionar se puede deshacer', () async {
    final ProviderContainer c = await boot(
      scenario(items: <int, BoardItem>{0: pan1, 1: pan1b}),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);

    controller.drop(0, 1);
    expect(c.read(gameControllerProvider).state!.board.at(1)?.level, 2);
    expect(c.read(gameControllerProvider).state!.board.at(0), isNull);

    controller.undo();
    expect(c.read(gameControllerProvider).state!.board.at(0)?.level, 1);
    expect(c.read(gameControllerProvider).state!.board.at(1)?.level, 1);
  });

  test('deshacer sin nada que deshacer no hace nada', () async {
    final ProviderContainer c = await boot(
      scenario(items: <int, BoardItem>{0: pan1}),
    );
    c.read(gameControllerProvider.notifier).undo();
    expect(c.read(gameControllerProvider).state!.coins, 100);
  });

  test('el álbum no retrocede al deshacer', () async {
    final ProviderContainer c = await boot(
      scenario(
        items: <int, BoardItem>{0: pan1, 1: pan1b},
        discovered: const <String>{},
      ),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);

    controller.drop(0, 1);
    final Set<String> afterMerge = c
        .read(gameControllerProvider)
        .state!
        .discovered;
    expect(afterMerge, isNotEmpty);

    controller.undo();
    expect(
      c.read(gameControllerProvider).state!.discovered,
      afterMerge,
      reason: 'descubrir no es un recurso: arrepentirse no despuebla el álbum',
    );
  });

  test('deshacer una compra devuelve las monedas', () async {
    final ProviderContainer c = await boot(
      scenario(
        coins: 5000,
        discovered: <String>{'${ProductCatalog.panaderia}:1'},
      ),
    );
    final GameController controller = c.read(gameControllerProvider.notifier);
    final Economy economy = c.read(economyProvider);

    final int price = economy.buyPrice(1);
    controller.buyProduct(ProductCatalog.panaderia, 1);
    expect(c.read(gameControllerProvider).state!.coins, 5000 - price);
    expect(c.read(gameControllerProvider).undo?.action, UndoableAction.buy);

    controller.undo();
    expect(c.read(gameControllerProvider).state!.coins, 5000);
  });
}
