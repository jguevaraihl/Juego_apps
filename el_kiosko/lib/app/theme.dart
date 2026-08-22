import 'package:flutter/material.dart';

/// Paleta cálida de almacén de barrio: madera, papel y toldo.
///
/// Requisitos de accesibilidad (PLAN_FINAL §6): contraste alto, tipografía
/// legible, y objetivos táctiles grandes. El color nunca es el único canal de
/// información: cada cadena de productos tiene además silueta y etiqueta.
class AppTheme {
  const AppTheme._();

  static const Color cream = Color(0xFFFBF3E4);
  static const Color paper = Color(0xFFFFFDF8);
  static const Color wood = Color(0xFF7A4A25);
  static const Color woodDark = Color(0xFF4A2B14);
  static const Color awning = Color(0xFFC2410C);
  static const Color ink = Color(0xFF1F1912);
  static const Color inkSoft = Color(0xFF5B4B3A);
  static const Color coin = Color(0xFFB45309);
  static const Color success = Color(0xFF15803D);

  /// Tamaño mínimo de objetivo táctil. Pensado para dedos imprecisos en micro.
  static const double minTouchTarget = 48;

  static ThemeData light() {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: wood,
          brightness: Brightness.light,
        ).copyWith(
          surface: cream,
          primary: wood,
          secondary: awning,
          onSurface: ink,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
        titleSmall: TextStyle(fontWeight: FontWeight.w700, color: ink),
        bodyMedium: TextStyle(color: ink, height: 1.35),
        bodySmall: TextStyle(color: inkSoft, height: 1.3),
        labelLarge: TextStyle(fontWeight: FontWeight.w700),
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
          side: const BorderSide(color: wood, width: 1.5),
          foregroundColor: woodDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: wood.withValues(alpha: 0.22)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: woodDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        iconColor: wood,
      ),
      dividerTheme: DividerThemeData(
        color: wood.withValues(alpha: 0.18),
        space: 1,
      ),
    );
  }
}
