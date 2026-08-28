import 'package:almacen/app/app.dart';
import 'package:almacen/app/providers.dart';
import 'package:almacen/data/local/save_codec.dart';
import 'package:almacen/data/local/save_store.dart';
import 'package:almacen/data/repositories/game_repository.dart';
import 'package:almacen/features/home/widgets/board_view.dart';
import 'package:almacen/features/home/widgets/coin_burst.dart';
import 'package:almacen/features/home/widgets/item_tile.dart';
import 'package:almacen/features/home/widgets/till_chip.dart';
import 'package:almacen/features/home/widgets/top_bar.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/order.dart';
import 'package:almacen/game/models/product.dart';
import 'package:almacen/game/models/settings.dart';
import 'package:almacen/services/audio/sound_service.dart';
import 'package:almacen/services/notifications/notification_service.dart';
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

  // El reloj se ancla en "ahora": con una fecha fija, según la hora real a la
  // que corriera el test, se acreditaba ganancia pasiva al cargar y se abría
  // la hoja de "el almacén siguió vendiendo", que tapaba la pantalla y hacía
  // fallar tests que no tienen nada que ver. Los tests no pueden depender de
  // la hora a la que se ejecutan.
  final DateTime now = DateTime.now();

  return state = state.copyWith(
    board: state.board.withCells(cells),
    orders: orders ?? state.orders,
    coins: coins,
    tutorialStep: tutorialStep,
    lastSeenAt: now,
    lastIncomeAt: now,
    // Sin sugerencias: evita dejar un Timer vivo al terminar el test.
    settings: const GameSettings(showIdleHints: false),
  );
}

/// El contador de monedas de la barra superior. Buscar el número suelto
/// chocaría con las recompensas de los pedidos y las insignias de nivel.
Finder coinCounter(int coins) =>
    find.descendant(of: find.byType(TopBar), matching: find.text('$coins'));

/// Tamaño de un teléfono real en vertical.
///
/// La ventana por defecto de flutter_test es 800x600, casi apaisada: ahí el
/// tablero de 6x8 queda con celdas de 18 px, por debajo del mínimo táctil que
/// la app promete y con arrastres tan cortos que compiten con el toque. Los
/// tests tienen que correr en la forma en que el juego se usa de verdad.
const Size phoneSize = Size(393, 851);

Future<void> pumpGame(WidgetTester tester, GameState state) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final MemorySaveStore store = MemorySaveStore();
  await store.write(SaveCodec.encode(state));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        saveStoreProvider.overrideWithValue(store),
        // Sin audio real: los tests no deben tocar el canal nativo.
        soundPlayerProvider.overrideWithValue(const NoopSoundPlayer()),
        // Sin avisos reales: los tests no deben tocar el canal nativo.
        notificationServiceProvider.overrideWithValue(
          const NoopNotificationService(),
        ),
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
    expect(find.text("Supplier's box"), findsOneWidget);
    // Tres pedidos visibles.
    expect(find.text('Missing'), findsNWidgets(3));
  });

  testWidgets('la caja del proveedor agrega un producto y cobra', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine, coins: 60));

    expect(find.byType(ItemTile), findsNothing);
    expect(coinCounter(60), findsOneWidget);

    await tester.tap(find.text("Supplier's box"));
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

    expect(find.text('Not enough coins'), findsOneWidget);
    final FilledButton button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text("Supplier's box"),
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
    // Gesto explícito en vez de timedDrag: el arrastre temporizado avanza el
    // reloj de test lo suficiente como para que otros reconocedores de gestos
    // entren en juego, y el test dejaría de medir lo que dice medir.
    final TestGesture gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 16));
    for (int i = 1; i <= 6; i++) {
      await gesture.moveTo(Offset.lerp(from, to, i / 6)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
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
      customerId: 0,
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

    expect(find.text('The Bus Driver'), findsOneWidget);

    // Al cargar la partida se repone hasta 3 pedidos, así que puede haber más
    // de uno entregable: se entrega el de Don Chofer.
    await tester.tap(
      find.descendant(
        of: find
            .ancestor(
              of: find.text('The Bus Driver'),
              matching: find.byType(Column),
            )
            .first,
        matching: find.text('Deliver'),
      ),
    );
    await tester.pumpAndSettle();

    expect(coinCounter(35), findsOneWidget, reason: '10 + 25 de recompensa');
    expect(find.byType(ItemTile), findsNothing);
    expect(find.text('The Bus Driver'), findsNothing);
  });

  testWidgets('el onboarding se muestra y se puede saltar', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine, tutorialStep: TutorialStep.merge));

    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(find.textContaining('Drag two matching products'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 3'), findsNothing);
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

    await tester.tap(find.text('Sell'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.byType(ItemTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(ItemTile), findsNothing);
    expect(coinCounter(engine.economy.sellValue(4)), findsOneWidget);
  });

  testWidgets('se puede llegar a mejorar el local desde el tablero', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine, coins: 200));

    // Con monedas suficientes, el ícono del local avisa con un punto y el
    // tooltip cambia.
    expect(find.byType(Badge), findsOneWidget);
    await tester.tap(find.byTooltip('You can upgrade your store'));
    await tester.pumpAndSettle();

    expect(find.text('Your store'), findsOneWidget);
    expect(find.text('Next: Kiosk'), findsOneWidget);

    await tester.tap(find.text('Upgrade for 150'));
    await tester.pumpAndSettle();

    // Vuelve al tablero con el local mejorado y las monedas descontadas.
    expect(find.byType(BoardView), findsOneWidget);
    expect(coinCounter(50), findsOneWidget);
  });

  testWidgets('sin monedas suficientes no se avisa que se puede mejorar', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine, coins: 10));

    expect(find.byType(Badge), findsNothing);
    expect(find.byTooltip('Upgrade your store'), findsOneWidget);
  });

  testWidgets('cobrar un pedido muestra el "+N" sobre las monedas', (
    WidgetTester tester,
  ) async {
    const CustomerOrder order = CustomerOrder(
      id: 1,
      customerId: 0,
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

    expect(find.byType(CoinBurst), findsNothing);

    await tester.tap(
      find.descendant(
        of: find
            .ancestor(
              of: find.text('The Bus Driver'),
              matching: find.byType(Column),
            )
            .first,
        matching: find.text('Deliver'),
      ),
    );
    await tester.pump();

    expect(find.byType(CoinBurst), findsOneWidget);
    expect(find.text('+25'), findsOneWidget);

    // Se va solo, sin dejar nada en pantalla.
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(CoinBurst), findsNothing);
  });

  testWidgets('los ajustes permiten apagar sonido y vibración', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Sound'), findsOneWidget);
    final SwitchListTile sound = tester.widget<SwitchListTile>(
      find.ancestor(
        of: find.text('Sound'),
        matching: find.byType(SwitchListTile),
      ),
    );
    expect(sound.value, isTrue);

    await tester.tap(find.text('Sound'));
    await tester.pumpAndSettle();

    final SwitchListTile after = tester.widget<SwitchListTile>(
      find.ancestor(
        of: find.text('Sound'),
        matching: find.byType(SwitchListTile),
      ),
    );
    expect(after.value, isFalse);
  });

  testWidgets('al volver tras un rato se avisa la ganancia acumulada', (
    WidgetTester tester,
  ) async {
    // El save queda fechado 3 horas atrás para que haya ganancia que cobrar.
    // (El resto de los tests ancla el reloj en "ahora" y no genera ganancia.)
    final DateTime threeHoursAgo = DateTime.now().subtract(
      const Duration(hours: 3),
    );
    // Con 0 monedas y el tablero vacío saltaría el rescate del proveedor y
    // enturbiaría la cuenta; se parte con algo suelto en el bolsillo.
    final GameState state = scenario(
      engine,
      coins: 10,
    ).copyWith(lastSeenAt: threeHoursAgo, lastIncomeAt: threeHoursAgo);
    await pumpGame(tester, state);

    expect(find.text('Your store kept selling'), findsOneWidget);
    // El mesón improvisado rinde 12 por hora; 3 horas esperando en la caja.
    final int expected = state.shopTier.coinsPerHour * 3;
    expect(find.textContaining('$expected coins'), findsOneWidget);
    // Todavía NO está en las monedas: hay que cobrarlo.
    expect(coinCounter(10), findsOneWidget);

    await tester.tap(find.text('Collect $expected'));
    await tester.pumpAndSettle();

    expect(find.text('Your store kept selling'), findsNothing);
    expect(find.byType(BoardView), findsOneWidget);
    // Recién ahora sí.
    expect(coinCounter(10 + expected), findsOneWidget);
  });

  testWidgets('el aviso de vuelta separa lo nuevo del saldo sin cobrar', (
    WidgetTester tester,
  ) async {
    final DateTime twoHoursAgo = DateTime.now().subtract(
      const Duration(hours: 2),
    );
    // Deja 10 sin cobrar de la sesión anterior: el aviso tiene que hablar de
    // las 2 horas nuevas, y el botón cobrar todo. El mesón rinde 12 por hora y
    // la caja aguanta 48, así que 10 + 24 no toca el tope.
    const int leftover = 10;
    final GameState state = scenario(engine, coins: 10).copyWith(
      lastSeenAt: twoHoursAgo,
      lastIncomeAt: twoHoursAgo,
      idleAccrued: leftover.toDouble(),
    );
    await pumpGame(tester, state);

    final int earned = state.shopTier.coinsPerHour * 2;
    expect(find.textContaining('$earned coins'), findsOneWidget);
    expect(
      find.textContaining('adds up to ${earned + leftover}'),
      findsOneWidget,
    );
    expect(find.text('Collect ${earned + leftover}'), findsOneWidget);
  });

  testWidgets('volver al instante no inventa una ganancia que no hubo', (
    WidgetTester tester,
  ) async {
    // Regresión: el aviso se disparaba con el saldo de la caja, así que quien
    // cerraba el juego sin cobrar veía "mientras no estabas se juntaron N" en
    // cada apertura, aunque volviera enseguida.
    final GameState state = scenario(
      engine,
      coins: 10,
    ).copyWith(idleAccrued: 40);
    await pumpGame(tester, state);

    expect(find.text('Your store kept selling'), findsNothing);
    expect(find.byType(BoardView), findsOneWidget);
  });

  testWidgets('cambiar el idioma en Ajustes traduce el juego', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine));

    // Por defecto los tests corren en inglés.
    expect(find.text("Supplier's box"), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    // Ajustes ya no cabe en una pantalla: hay que bajar hasta el idioma.
    await tester.scrollUntilVisible(find.text('Language'), 120);
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    // La pantalla de ajustes ya está en español. El título está siempre a la
    // vista; "Sonido" quedó arriba, fuera de pantalla tras el scroll, así que
    // se comprueba una etiqueta de la parte visible.
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);

    // pageBack() busca el tooltip "Back", que ahora dice "Atrás": se usa un
    // finder independiente del idioma.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Y el tablero también, incluidos los nombres de producto y cliente.
    expect(find.text('Caja del proveedor'), findsOneWidget);
    expect(find.text("Supplier's box"), findsNothing);
  });

  testWidgets('el idioma elegido sobrevive al guardado', (
    WidgetTester tester,
  ) async {
    final GameState state = scenario(engine)
        .copyWith(settings: const GameSettings(languageCode: 'es'));
    await pumpGame(tester, state);

    expect(find.text('Caja del proveedor'), findsOneWidget);
    expect(find.text('Vender'), findsOneWidget);
  });

  testWidgets('la caja se puede cobrar desde la fachada', (
    WidgetTester tester,
  ) async {
    final DateTime twoHoursAgo = DateTime.now().subtract(
      const Duration(hours: 2),
    );
    final GameState state = scenario(
      engine,
      coins: 10,
    ).copyWith(lastSeenAt: twoHoursAgo, lastIncomeAt: twoHoursAgo);
    await pumpGame(tester, state);

    // Se cierra el aviso de bienvenida sin cobrar, para probar el chip.
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();

    expect(find.byType(TillChip), findsOneWidget);
    final int expected = state.shopTier.coinsPerHour * 2;

    await tester.tap(find.byType(TillChip));
    await tester.pumpAndSettle();

    expect(coinCounter(10 + expected), findsOneWidget);
  });

  testWidgets('los avisos vienen apagados y se pueden encender', (
    WidgetTester tester,
  ) async {
    await pumpGame(tester, scenario(engine));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    // Opt-in: nunca algo que el jugador tenga que ir a desactivar.
    final SwitchListTile toggle = tester.widget<SwitchListTile>(
      find.ancestor(
        of: find.text('Notifications'),
        matching: find.byType(SwitchListTile),
      ),
    );
    expect(toggle.value, isFalse);
  });

  testWidgets('el álbum marca lo descubierto y oculta el resto', (
    WidgetTester tester,
  ) async {
    GameState state = scenario(engine);
    state = state.copyWith(discovered: <String>{'$pan:1'});
    await pumpGame(tester, state);

    await tester.tap(find.byTooltip('Product album'));
    await tester.pumpAndSettle();

    expect(
      find.text('Discovered 1 of ${ProductCatalog.totalProducts}'),
      findsOneWidget,
    );
    expect(find.text('Bread Roll'), findsOneWidget);
    // La lista es scrolleable, así que sólo se construye lo visible: basta con
    // comprobar que lo no descubierto se oculta.
    expect(find.text('???'), findsWidgets);
    expect(find.text('Bag of Bread'), findsNothing);
  });
}
