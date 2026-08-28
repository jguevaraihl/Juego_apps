import 'package:almacen/app/theme.dart';
import 'package:almacen/game/models/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nombre del local', () {
    test('recorta espacios y descarta el vacío', () {
      expect(GameSettings.sanitizeStoreName('  El Rincón  '), 'El Rincón');
      expect(GameSettings.sanitizeStoreName('   '), isNull);
      expect(GameSettings.sanitizeStoreName(''), isNull);
      expect(GameSettings.sanitizeStoreName(null), isNull);
    });

    test('acota el largo para que quepa en el letrero', () {
      final String long = 'a' * 100;
      expect(
        GameSettings.sanitizeStoreName(long)!.length,
        GameSettings.maxStoreNameLength,
      );
    });

    test('un nombre de largo justo pasa entero', () {
      final String exact = 'b' * GameSettings.maxStoreNameLength;
      expect(GameSettings.sanitizeStoreName(exact), exact);
    });
  });

  group('paleta del toldo', () {
    test('el tema tiene exactamente los colores que el modelo declara', () {
      // Si alguien agrega un color al tema y no sube el tope del modelo, los
      // saves nuevos quedarían acotados a la paleta vieja.
      expect(
        AppTheme.awningPalette.length,
        GameSettings.awningColorCount,
        reason:
            'AppTheme.awningPalette y awningColorCount tienen que coincidir',
      );
    });

    test('todos los colores son distintos entre sí', () {
      expect(
        AppTheme.awningPalette.toSet().length,
        AppTheme.awningPalette.length,
      );
    });

    test('un índice fuera de rango no revienta', () {
      expect(AppTheme.awningAt(-5), AppTheme.awningPalette.first);
      expect(AppTheme.awningAt(999), AppTheme.awningPalette.last);
    });

    test('el índice 0 es el toldo de siempre', () {
      // Quien no elija nada tiene que ver el juego igual que antes.
      expect(AppTheme.awningAt(0), AppTheme.brandAwning);
    });
  });

  group('persistencia de las preferencias', () {
    test('ida y vuelta por JSON conserva todo', () {
      const GameSettings original = GameSettings(
        soundEnabled: false,
        hapticsEnabled: false,
        reducedMotion: true,
        showIdleHints: false,
        notificationsEnabled: true,
        languageCode: 'en',
        storeName: 'Donde la Tere',
        awningColor: 5,
        themeMode: AppThemeMode.dark,
        textScale: 1.2,
      );

      final GameSettings back = GameSettings.fromJson(original.toJson());

      expect(back.soundEnabled, false);
      expect(back.hapticsEnabled, false);
      expect(back.reducedMotion, true);
      expect(back.showIdleHints, false);
      expect(back.notificationsEnabled, true);
      expect(back.languageCode, 'en');
      expect(back.storeName, 'Donde la Tere');
      expect(back.awningColor, 5);
      expect(back.themeMode, AppThemeMode.dark);
      expect(back.textScale, 1.2);
    });

    test('un save viejo, sin las claves nuevas, se lee con los valores por '
        'defecto', () {
      // Esto es lo que hace que no haga falta migrar el esquema: las
      // preferencias nuevas se rellenan solas.
      final GameSettings old = GameSettings.fromJson(<String, dynamic>{
        'sound': true,
        'haptics': true,
        'language': 'es',
      });

      expect(old.storeName, isNull);
      expect(old.awningColor, 0);
      expect(old.themeMode, AppThemeMode.system);
      expect(old.textScale, 1.0);
      expect(old.languageCode, 'es');
    });

    test('un color de toldo de una versión futura se acota', () {
      final GameSettings s = GameSettings.fromJson(<String, dynamic>{
        'awningColor': 99,
      });
      expect(s.awningColor, GameSettings.awningColorCount - 1);
    });

    test('una escala de texto absurda se acota', () {
      expect(
        GameSettings.fromJson(<String, dynamic>{'textScale': 9.0}).textScale,
        GameSettings.maxTextScale,
      );
      expect(
        GameSettings.fromJson(<String, dynamic>{'textScale': 0.1}).textScale,
        GameSettings.minTextScale,
      );
    });

    test('un tema desconocido cae en "según el teléfono"', () {
      expect(
        GameSettings.fromJson(<String, dynamic>{'themeMode': 'neon'}).themeMode,
        AppThemeMode.system,
      );
    });

    test('el nombre guardado también se limpia al leerlo', () {
      // Un save escrito a mano, o por una versión con otro tope, no puede
      // meter un nombre que desborde el letrero.
      final GameSettings s = GameSettings.fromJson(<String, dynamic>{
        'storeName': '   ${'x' * 80}   ',
      });
      expect(s.storeName!.length, GameSettings.maxStoreNameLength);
    });

    test('clearStoreName vuelve al nombre del nivel', () {
      const GameSettings s = GameSettings(storeName: 'El Rincón');
      expect(s.copyWith(clearStoreName: true).storeName, isNull);
      // Sin la bandera, pasar null no borra: significa "no cambiar".
      expect(s.copyWith().storeName, 'El Rincón');
    });
  });

  group('temas claro y oscuro', () {
    test('los dos definen todos los colores, y distintos', () {
      // Un color idéntico en ambos temas casi siempre es un olvido: el fondo
      // claro y el oscuro no pueden ser el mismo.
      expect(KioskoPalette.light.cream, isNot(KioskoPalette.dark.cream));
      expect(KioskoPalette.light.paper, isNot(KioskoPalette.dark.paper));
      expect(KioskoPalette.light.ink, isNot(KioskoPalette.dark.ink));
      expect(KioskoPalette.light.wood, isNot(KioskoPalette.dark.wood));
    });

    test('el tema oscuro es de verdad oscuro y el claro, claro', () {
      expect(KioskoPalette.dark.cream.computeLuminance(), lessThan(0.1));
      expect(KioskoPalette.light.cream.computeLuminance(), greaterThan(0.7));
      // Y el texto contrasta con su fondo en los dos.
      expect(KioskoPalette.dark.ink.computeLuminance(), greaterThan(0.6));
      expect(KioskoPalette.light.ink.computeLuminance(), lessThan(0.1));
    });

    test('el texto sobre el fondo cumple el contraste mínimo de WCAG AA', () {
      double ratio(double a, double b) {
        final double hi = a > b ? a : b;
        final double lo = a > b ? b : a;
        return (hi + 0.05) / (lo + 0.05);
      }

      for (final KioskoPalette p in <KioskoPalette>[
        KioskoPalette.light,
        KioskoPalette.dark,
      ]) {
        expect(
          ratio(p.ink.computeLuminance(), p.cream.computeLuminance()),
          greaterThanOrEqualTo(4.5),
          reason: 'texto principal sobre el fondo',
        );
        expect(
          ratio(p.inkSoft.computeLuminance(), p.cream.computeLuminance()),
          greaterThanOrEqualTo(4.5),
          reason: 'texto secundario sobre el fondo',
        );
        expect(
          ratio(p.wood.computeLuminance(), p.cream.computeLuminance()),
          greaterThanOrEqualTo(3.0),
          reason: 'acento sobre el fondo (mínimo de texto grande / iconos)',
        );
      }
    });

    test('lerp entre temas no revienta', () {
      final KioskoPalette mid = KioskoPalette.light.lerp(
        KioskoPalette.dark,
        0.5,
      );
      expect(mid.cream, isNot(KioskoPalette.light.cream));
    });
  });
}
