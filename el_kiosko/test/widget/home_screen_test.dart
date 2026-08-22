import 'package:almacen/app/app.dart';
import 'package:almacen/app/providers.dart';
import 'package:almacen/data/local/save_codec.dart';
import 'package:almacen/data/local/save_store.dart';
import 'package:almacen/data/repositories/game_repository.dart';
import 'package:almacen/features/home/widgets/board_view.dart';
import 'package:almacen/features/home/widgets/item_tile.dart';
import 'package:almacen/features/home/widgets/top_bar.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/order.dart';
import 'package:almacen/game/models/product.dart';
import 'package:almacen/game/models/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime t0 = DateTime.utc(2026, 8, 22, 12);
const String pan = ProductCatalog.panaderia;

/// Estado de partida controlado, para que los tests de UI no dependan del azar.
GameState scenario(
  GameEngine engine, {
  Map<int, BoardItem> items = const <int, BoardItem>{},
  List<CustomerOrder>? orders,
  int? coins,
  TutorialStep tutorialStep = TutorialStep.done,
}) {
  GameState state = engine.newGame(now: t0, seed: 1).state;
  final List<BoardItem?> cells = state.board.mutableCells();
  items.forEach((int index, BoardItem item) => cells[index] = item);

  return state = state.copyWith(
    board: state.board.withCells(cells),
    orders: orders ?? state.orders,
    coins: coins,
    tutorialStep: tutorialStep,
    // Sin sugerencias: evita dejar un Timer vivo al terminar el test.
    settings: const GameSettings(showIdleHints: false),
  );
}

/// El contador de monedas de la barra superior. Buscar el número suelto
/// chocaría con las recompensas de los pedidos y las insignias de nivel.
Finder coinCounter(int coins) =>
    find.descendant(of: find.byType(TopBar), matching: find.text('$coins'));

Future<void> pumpGame(WidgetTester tester, GameState state) async {
  final MemorySaveStore store = MemorySaveStore();
  await store.write(SaveCodec.encode(state));

  await tester.pumpWidget(
    ProviderScope(
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
      child: const AlmacenApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late GameEngine engine;

  setUp(() => engine = GameEngine());

  testWidgets('muestra tablero, pedidos y la caja del proveedor', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine));

    expect(find.byType(BoardView), findsOneWidget);
    expect(find.text('Caja del proveedor'), findsOneWidget);
    // Tres pedidos visibles.
    expect(find.text('Falta'), findsNWidgets(3));
  });

  testWidgets('la caja del proveedor agrega un producto y cobra', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine, coins: 60));

    expect(find.byType(ItemTile), findsNothing);
    expect(coinCounter(60), findsOneWidget);

    await tester.tap(find.text('Caja del proveedor'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemTile), findsOneWidget);
    expect(coinCounter(60 - engine.config.generateCost), findsOneWidget);
  });

  testWidgets('sin monedas la caja del proveedor queda deshabilitada', (
    WidgetTester tester,
  ) async {
    // Con una pieza en el tablero para que no se dispare el rescate.
    await pumpGame(
      tester,
      scenario(
        engine,
        coins: 0,
        items: <int, BoardItem>{
          0: const BoardItem(id: 1, chainId: pan, level: 1),
        },
      ),
    );

    expect(find.text('Te faltan monedas'), findsOneWidget);
    final FilledButton button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Caja del proveedor'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('arrastrar dos iguales los fusiona en pantalla', (
    WidgetTester tester,
  ) async {
    await pumpGame(
      tester,
      scenario(
        engine,
        tutorialStep: TutorialStep.merge,
        items: <int, BoardItem>{
          0: const BoardItem(id: 1, chainId: pan, level: 1),
          1: const BoardItem(id: 2, chainId: pan, level: 1),
        },
      ),
    );

    expect(find.byType(ItemTile), findsNWidgets(2));
    expect(find.text('1'), findsNWidgets(2));

    final Offset from = tester.getCenter(find.byType(ItemTile).first);
    final Offset to = tester.getCenter(find.byType(ItemTile).last);
    await tester.timedDrag(
      find.byType(ItemTile).first,
      to - from,
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    // Dos objetos de nivel 1 entran, uno de nivel 2 sale.
    expect(find.byType(ItemTile), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('un pedido listo se puede entregar y paga', (
    WidgetTester tester,
  ) async {
    const CustomerOrder order = CustomerOrder(
      id: 1,
      customerName: 'Don Chofer',
      lines: <OrderLine>[OrderLine(chainId: pan, level: 1, quantity: 1)],
      reward: 25,
      xp: 3,
    );

    await pumpGame(
      tester,
      scenario(
        engine,
        coins: 10,
        orders: const <CustomerOrder>[order],
        items: <int, BoardItem>{
          0: const BoardItem(id: 1, chainId: pan, level: 1),
        },
      ),
    );

    expect(find.text('Don Chofer'), findsOneWidget);

    // Al cargar la partida se repone hasta 3 pedidos, así que puede haber más
    // de uno entregable: se entrega el de Don Chofer.
    await tester.tap(
      find.descendant(
        of: find
            .ancestor(
              of: find.text('Don Chofer'),
              matching: find.byType(Column),
            )
            .first,
        matching: find.text('Entregar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(coinCounter(35), findsOneWidget, reason: '10 + 25 de recompensa');
    expect(find.byType(ItemTile), findsNothing);
    expect(find.text('Don Chofer'), findsNothing);
  });

  testWidgets('el onboarding se muestra y se puede saltar', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine, tutorialStep: TutorialStep.merge));

    expect(find.text('Paso 1 de 3'), findsOneWidget);
    expect(
      find.textContaining('Arrastra dos productos iguales'),
      findsOneWidget,
    );

    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    expect(find.text('Paso 1 de 3'), findsNothing);
  });

  testWidgets('el modo vender saca un producto y paga', (
    WidgetTester tester,
  ) async {
    await pumpGame(
      tester,
      scenario(
        engine,
        coins: 0,
        items: <int, BoardItem>{
          0: const BoardItem(id: 1, chainId: pan, level: 4),
        },
      ),
    );

    await tester.tap(find.text('Vender'));
    await tester.pumpAndSettle();
    expect(find.text('Listo'), findsOneWidget);

    await tester.tap(find.byType(ItemTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(ItemTile), findsNothing);
    expect(coinCounter(engine.economy.sellValue(4)), findsOneWidget);
  });

  testWidgets('se puede llegar a mejorar el local desde el tablero', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine, coins: 200));

    await tester.tap(find.byTooltip('Mejorar el local'));
    await tester.pumpAndSettle();

    expect(find.text('Tu local'), findsOneWidget);
    expect(find.text('Siguiente: Kiosko'), findsOneWidget);

    await tester.tap(find.text('Mejorar por 150'));
    await tester.pumpAndSettle();

    // Vuelve al tablero con el local mejorado y las monedas descontadas.
    expect(find.byType(BoardView), findsOneWidget);
    expect(coinCounter(50), findsOneWidget);
  });

  testWidgets('los ajustes permiten apagar sonido y vibración', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine));

    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();

    expect(find.text('Sonido'), findsOneWidget);
    final SwitchListTile sound = tester.widget<SwitchListTile>(
      find.ancestor(
        of: find.text('Sonido'),
        matching: find.byType(SwitchListTile),
      ),
    );
    expect(sound.value, isTrue);

    await tester.tap(find.text('Sonido'));
    await tester.pumpAndSettle();

    final SwitchListTile after = tester.widget<SwitchListTile>(
      find.ancestor(
        of: find.text('Sonido'),
        matching: find.byType(SwitchListTile),
      ),
    );
    expect(after.value, isFalse);
  });

  testWidgets('al volver tras un rato se avisa la ganancia acumulada', (
    WidgetTester tester,
  ) async {
    // El save queda fechado 3 horas atrás para que haya ganancia que cobrar.
    // (El resto de los tests usa t0, que no produce ganancia.)
    final GameState state = scenario(
      engine,
      coins: 0,
    ).copyWith(lastSeenAt: DateTime.now().subtract(const Duration(hours: 3)));
    await pumpGame(tester, state);

    expect(find.text('El almacén siguió vendiendo'), findsOneWidget);
    // El mesón improvisado rinde 12 por hora; 3 horas ya cobradas al abrir.
    final int expected = state.shopTier.coinsPerHour * 3;
    expect(find.textContaining('$expected pesos'), findsOneWidget);
    expect(coinCounter(expected), findsOneWidget);

    await tester.tap(find.text('Seguir atendiendo'));
    await tester.pumpAndSettle();

    expect(find.text('El almacén siguió vendiendo'), findsNothing);
    expect(find.byType(BoardView), findsOneWidget);
  });

  testWidgets('el álbum marca lo descubierto y oculta el resto', (
    WidgetTester tester,
  ) async {
    GameState state = scenario(engine);
    state = state.copyWith(discovered: <String>{'$pan:1'});
    await pumpGame(tester, state);

    await tester.tap(find.byTooltip('Álbum de productos'));
    await tester.pumpAndSettle();

    expect(find.text('Descubiertos 1 de 15'), findsOneWidget);
    expect(find.text('Marraqueta'), findsOneWidget);
    // La lista es scrolleable, así que sólo se construye lo visible: basta con
    // comprobar que lo no descubierto se oculta.
    expect(find.text('???'), findsWidgets);
    expect(find.text('Bolsa de pan'), findsNothing);
  });
}
