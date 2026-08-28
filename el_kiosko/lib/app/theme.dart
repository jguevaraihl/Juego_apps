import 'package:flutter/material.dart';

/// Paleta cálida de almacén de barrio: madera, papel y toldo.
///
/// Requisitos de accesibilidad (PLAN_FINAL §6): contraste alto, tipografía
/// legible, y objetivos táctiles grandes. El color nunca es el único canal de
/// información: cada cadena de productos tiene además silueta y etiqueta.
///
/// **Dos familias de color, a propósito.**
///
/// Las constantes `brand*` son el color de lo que está *dibujado* —la fachada
/// del local, las siluetas de los productos— y no cambian con el tema: un
/// dibujo no se invierte porque el teléfono esté en modo oscuro, igual que la
/// foto de un producto no cambia de color de noche.
///
/// Todo lo demás —fondos, textos, tarjetas, bordes— sale de [KioskoPalette],
/// que sí tiene versión clara y oscura. Los widgets la leen con
/// `context.palette`.
class AppTheme {
  const AppTheme._();

  // ------------------------------------------------------------------
  // Constantes de marca (no cambian con el tema)
  // ------------------------------------------------------------------

  static const Color brandCream = Color(0xFFFBF3E4);
  static const Color brandWood = Color(0xFF7A4A25);
  static const Color brandWoodDark = Color(0xFF4A2B14);
  static const Color brandAwning = Color(0xFFC2410C);

  /// Verde de marca. Se usa como **fondo** con texto blanco encima; por eso no
  /// se aclara en modo oscuro, donde el blanco dejaría de leerse.
  static const Color brandSuccess = Color(0xFF15803D);

  /// Tamaño mínimo de objetivo táctil. Pensado para dedos imprecisos en micro.
  static const double minTouchTarget = 48;

  /// Alto de la barra inferior (caja del proveedor + vender), incluidos sus
  /// paddings. Los avisos se levantan por encima de esto.
  static const double bottomBarHeight = 92;

  /// Telas de toldo que el jugador puede elegir para su local.
  ///
  /// La lista alterna claros y oscuros a propósito: quien no distingue matices
  /// igual ve la diferencia por luminosidad, y en la grilla de elección la
  /// opción activa lleva además un visto bueno, para no depender sólo del
  /// color (guía de accesibilidad: ninguna información esencial en un color y
  /// nada más).
  ///
  /// El índice 0 es el de siempre: quien no elija nada ve el juego igual que
  /// antes. El largo tiene que coincidir con `GameSettings.awningColorCount`.
  static const List<Color> awningPalette = <Color>[
    Color(0xFFC2410C), // teja
    Color(0xFF15803D), // verde
    Color(0xFF1D4ED8), // azul
    Color(0xFF7E22CE), // morado
    Color(0xFFB91C1C), // rojo
    Color(0xFF0F766E), // verde azulado
    Color(0xFFA16207), // mostaza
    Color(0xFF334155), // pizarra
  ];

  /// El color de toldo guardado, acotado por si el save viene de otra versión.
  static Color awningAt(int index) =>
      awningPalette[index.clamp(0, awningPalette.length - 1)];

  // ------------------------------------------------------------------
  // Temas
  // ------------------------------------------------------------------

  static ThemeData light() => _build(KioskoPalette.light, Brightness.light);

  static ThemeData dark() => _build(KioskoPalette.dark, Brightness.dark);

  static ThemeData _build(KioskoPalette p, Brightness brightness) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: brandWood,
          brightness: brightness,
        ).copyWith(
          surface: p.cream,
          surfaceContainerHighest: p.paper,
          primary: p.wood,
          secondary: p.awning,
          onSurface: p.ink,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[p],
      scaffoldBackgroundColor: p.cream,
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w800,
          color: p.ink,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: p.ink),
        titleSmall: TextStyle(fontWeight: FontWeight.w700, color: p.ink),
        bodyMedium: TextStyle(color: p.ink, height: 1.35),
        bodySmall: TextStyle(color: p.inkSoft, height: 1.3),
        labelLarge: const TextStyle(fontWeight: FontWeight.w700),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: p.wood, width: 1.5),
          foregroundColor: p.woodDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.wood.withValues(alpha: 0.22)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.cream,
        foregroundColor: p.ink,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        // Los avisos flotan por encima de la barra inferior; sin este margen
        // tapan la caja del proveedor y el botón de vender justo cuando el
        // jugador los está usando.
        insetPadding: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: bottomBarHeight,
        ),
        backgroundColor: p.toast,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        iconColor: p.wood,
      ),
      dividerTheme: DividerThemeData(
        color: p.wood.withValues(alpha: 0.18),
        space: 1,
      ),
    );
  }
}

/// Los colores de la interfaz, en versión clara y oscura.
///
/// Va como `ThemeExtension` y no como constantes sueltas para que un widget no
/// pueda quedarse con un color fijo por descuido: se lee siempre del tema, y
/// el tema sabe en qué modo está.
@immutable
class KioskoPalette extends ThemeExtension<KioskoPalette> {
  const KioskoPalette({
    required this.cream,
    required this.paper,
    required this.wood,
    required this.woodDark,
    required this.awning,
    required this.ink,
    required this.inkSoft,
    required this.coin,
    required this.success,
    required this.toast,
  });

  /// Fondo de las pantallas.
  final Color cream;

  /// Tarjetas y hojas, un escalón por encima del fondo.
  final Color paper;

  /// Acento principal: bordes, íconos, botones.
  final Color wood;

  /// Acento de más énfasis, para texto que tiene que destacar.
  final Color woodDark;

  final Color awning;
  final Color ink;
  final Color inkSoft;
  final Color coin;
  final Color success;

  /// Fondo de los avisos flotantes; su texto siempre es blanco.
  final Color toast;

  static const KioskoPalette light = KioskoPalette(
    cream: Color(0xFFFBF3E4),
    paper: Color(0xFFFFFDF8),
    wood: Color(0xFF7A4A25),
    woodDark: Color(0xFF4A2B14),
    awning: Color(0xFFC2410C),
    ink: Color(0xFF1F1912),
    inkSoft: Color(0xFF5B4B3A),
    coin: Color(0xFFB45309),
    success: Color(0xFF15803D),
    toast: Color(0xFF4A2B14),
  );

  /// Oscuro cálido, no gris: el juego pasa dentro de un almacén de madera, y
  /// un gris azulado lo convertiría en otra cosa. Los acentos se aclaran
  /// respecto del tema claro porque el mismo marrón sobre fondo oscuro queda
  /// por debajo del contraste mínimo.
  static const KioskoPalette dark = KioskoPalette(
    cream: Color(0xFF17120C),
    paper: Color(0xFF241C13),
    wood: Color(0xFFD9A066),
    woodDark: Color(0xFFEFDCC0),
    awning: Color(0xFFF97316),
    ink: Color(0xFFF3E7D4),
    inkSoft: Color(0xFFB9A88F),
    coin: Color(0xFFF0B441),
    success: Color(0xFF4ADE80),
    toast: Color(0xFF3A2A18),
  );

  @override
  KioskoPalette copyWith({
    Color? cream,
    Color? paper,
    Color? wood,
    Color? woodDark,
    Color? awning,
    Color? ink,
    Color? inkSoft,
    Color? coin,
    Color? success,
    Color? toast,
  }) => KioskoPalette(
    cream: cream ?? this.cream,
    paper: paper ?? this.paper,
    wood: wood ?? this.wood,
    woodDark: woodDark ?? this.woodDark,
    awning: awning ?? this.awning,
    ink: ink ?? this.ink,
    inkSoft: inkSoft ?? this.inkSoft,
    coin: coin ?? this.coin,
    success: success ?? this.success,
    toast: toast ?? this.toast,
  );

  @override
  KioskoPalette lerp(ThemeExtension<KioskoPalette>? other, double t) {
    if (other is! KioskoPalette) return this;
    return KioskoPalette(
      cream: Color.lerp(cream, other.cream, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      wood: Color.lerp(wood, other.wood, t)!,
      woodDark: Color.lerp(woodDark, other.woodDark, t)!,
      awning: Color.lerp(awning, other.awning, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      coin: Color.lerp(coin, other.coin, t)!,
      success: Color.lerp(success, other.success, t)!,
      toast: Color.lerp(toast, other.toast, t)!,
    );
  }
}

extension PaletteOf on BuildContext {
  /// Los colores del tema activo. Falla ruidosamente si alguien monta un
  /// widget fuera del tema de la app, que es mejor que pintarlo mal en
  /// silencio.
  KioskoPalette get palette => Theme.of(this).extension<KioskoPalette>()!;
}
