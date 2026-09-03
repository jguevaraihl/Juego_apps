import 'dart:convert';

import 'package:almacen/features/home/widgets/storefront.dart';
import 'package:almacen/features/home/widgets/storefront_art.dart';
import 'package:almacen/game/progression/shop_tiers.dart';
import 'package:almacen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// La fachada tiene dos caminos: la ilustración encargada y el dibujo en
/// código. Hoy no hay ninguna ilustración empaquetada, así que el camino del
/// arte no se ejercita solo — y un camino que nadie recorre es un camino roto
/// esperando. Estos tests lo recorren con un asset falso, para que el día que
/// lleguen las imágenes de `ART_PROMPTS.md` el enchufe ya esté probado.

/// Un PNG de 4×2 píxeles, el más chico que Flutter decodifica sin quejarse.
final Uint8List _tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAQAAAACCAIAAADwyuo0AAAAEElEQVR4nGM4UWEDRwzIHACe'
  '2gvhFuP11QAAAABJRU5ErkJggg==',
);

/// Devuelve el PNG de arriba para cualquier ruta que le pidan, salvo las que
/// estén en [missing], donde falla como fallaría un archivo que no se declaró
/// en el pubspec.
class _FakeArtBundle extends CachingAssetBundle {
  _FakeArtBundle({this.missing = const <String>{}});

  final Set<String> missing;

  @override
  Future<ByteData> load(String key) async {
    if (missing.contains(key)) throw FlutterError('asset ausente: $key');
    return ByteData.sublistView(_tinyPng);
  }
}

Future<void> pumpFacade(
  WidgetTester tester, {
  StorefrontArtSpec? art,
  AssetBundle? bundle,
  Brightness brightness = Brightness.light,
  String name = 'Almacén Ñuñoa',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(brightness: brightness),
      home: DefaultAssetBundle(
        bundle: bundle ?? _FakeArtBundle(),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 336,
              height: 96,
              child: Storefront(
                tier: ShopTiers.byLevel(4),
                storeName: name,
                art: art,
                animate: false,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const StorefrontArtSpec full = StorefrontArtSpec(
    day: 'assets/art/storefront/level_4.webp',
    night: 'assets/art/storefront/level_4_night.webp',
    awning: 'assets/art/storefront/level_4_awning.webp',
  );

  testWidgets('sin ilustración se dibuja la fachada en código', (
    WidgetTester tester,
  ) async {
    await pumpFacade(tester);

    expect(find.byType(Image), findsNothing);
    // El nombre lo pinta el painter en el canvas, no hay un Text que buscar:
    // lo que se comprueba es que no se coló ninguna imagen.
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('el registro viene vacío: nadie encargó arte todavía', (
    WidgetTester tester,
  ) async {
    // Si algún día se agrega un nivel al registro sin los archivos, este test
    // avisa antes de que el jugador vea un rectángulo gris.
    expect(StorefrontArt.byLevel, isEmpty);
    expect(StorefrontArt.forLevel(4), isNull);
  });

  testWidgets('con ilustración se pintan la fachada y el toldo aparte', (
    WidgetTester tester,
  ) async {
    await pumpFacade(tester, art: full);

    final Iterable<Image> images = tester.widgetList<Image>(find.byType(Image));
    expect(images.length, 2, reason: 'la pintura y el toldo teñible');

    final AssetImage day = images.first.image as AssetImage;
    expect(day.assetName, full.day);
    // El toldo se tiñe con el color elegido; la pintura nunca.
    expect(images.first.color, isNull);
    expect(images.last.color, isNotNull);
    expect(images.last.colorBlendMode, BlendMode.modulate);
  });

  testWidgets('el nombre del local se escribe encima, no viene pintado', (
    WidgetTester tester,
  ) async {
    await pumpFacade(tester, art: full, name: 'Don Lucho');

    expect(find.text('Don Lucho'), findsOneWidget);
  });

  testWidgets('en modo oscuro se usa la versión de noche', (
    WidgetTester tester,
  ) async {
    await pumpFacade(tester, art: full, brightness: Brightness.dark);

    final AssetImage first =
        tester.widgetList<Image>(find.byType(Image)).first.image as AssetImage;
    expect(first.assetName, full.night);
  });

  testWidgets('sin versión de noche se usa la de día antes que romperse', (
    WidgetTester tester,
  ) async {
    const StorefrontArtSpec dayOnly = StorefrontArtSpec(
      day: 'assets/art/storefront/level_2.webp',
    );
    await pumpFacade(tester, art: dayOnly, brightness: Brightness.dark);

    final Iterable<Image> images = tester.widgetList<Image>(find.byType(Image));
    expect(images.length, 1, reason: 'sin capa de toldo, una sola imagen');
    expect((images.first.image as AssetImage).assetName, dayOnly.day);
  });

  testWidgets('si el archivo falta, cae en la fachada dibujada', (
    WidgetTester tester,
  ) async {
    // El respaldo tiene que aguantar un asset mal declarado en el pubspec: es
    // el error más fácil de cometer al agregar el arte, y no puede dejar un
    // hueco gris donde va el local del jugador.
    await pumpFacade(
      tester,
      art: full,
      bundle: _FakeArtBundle(missing: <String>{full.day}),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  test('las rutas siguen la convención del encargo', () {
    final StorefrontArtSpec spec = StorefrontArt.spec(3);

    expect(spec.day, 'assets/art/storefront/level_3.webp');
    expect(spec.night, 'assets/art/storefront/level_3_night.webp');
    expect(spec.awning, 'assets/art/storefront/level_3_awning.webp');
    expect(spec.tintsAwning, isTrue);

    final StorefrontArtSpec bare = StorefrontArt.spec(
      1,
      hasNight: false,
      hasAwningLayer: false,
    );
    expect(bare.night, isNull);
    expect(bare.awning, isNull);
    expect(bare.tintsAwning, isFalse);
  });
}
