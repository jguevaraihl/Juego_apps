/// Preferencias del jugador. Todas se guardan en el save local; ninguna sale
/// del dispositivo.
///
/// La personalización vive acá y no en [GameState] a propósito: no cambia
/// ninguna regla del juego, y `fromJson` rellena lo que falte, así que una
/// partida vieja se lee sin migrar nada.
library;

/// Cómo se ve el juego. `system` sigue al teléfono, que es lo que espera la
/// mayoría; las otras dos son para quien lo quiere fijo.
enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode fromName(String? name) => switch (name) {
    'light' => AppThemeMode.light,
    'dark' => AppThemeMode.dark,
    _ => AppThemeMode.system,
  };
}

class GameSettings {
  const GameSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.showIdleHints = true,
    this.notificationsEnabled = false,
    this.languageCode,
    this.storeName,
    this.awningColor = 0,
    this.themeMode = AppThemeMode.system,
    this.textScale = 1.0,
  });

  /// Nombre del local, elegido por el jugador. null = usar el nombre del nivel
  /// ("Almacén chico"), que es lo que se mostraba antes.
  ///
  /// Se guarda tal cual lo escribe el jugador y nunca sale del teléfono: no
  /// hay servidor ni ranking donde pudiera verlo otra persona.
  final String? storeName;

  /// Índice dentro de [awningPalette]. Se guarda el índice y no el color para
  /// que retocar la paleta no deje saves apuntando a un color que ya no existe.
  final int awningColor;

  final AppThemeMode themeMode;

  /// Multiplicador de texto **sobre** el del sistema. Existe además del ajuste
  /// de Android porque mucha gente no sabe que ese ajuste existe, y porque
  /// aquí se puede acotar para que el tablero siga cabiendo.
  final double textScale;

  final bool soundEnabled;
  final bool hapticsEnabled;

  /// Acorta o elimina animaciones. Ayuda en gama baja y en accesibilidad.
  final bool reducedMotion;

  final bool showIdleHints;

  /// Aviso local cuando la caja se llena.
  ///
  /// Arranca **apagado**: las notificaciones son opt-in, nunca algo que el
  /// jugador tenga que ir a desactivar (PLAN_FINAL §4).
  final bool notificationsEnabled;

  /// Código de idioma elegido a mano ('es', 'en'). null = seguir al sistema.
  final String? languageCode;

  /// Cuántos colores de toldo hay. Vive acá y no en el tema porque el modelo
  /// no puede depender de la capa de UI, y es lo que acota el valor guardado.
  /// `AppTheme.awningPalette` tiene que tener exactamente esta cantidad, y hay
  /// un test que lo comprueba.
  static const int awningColorCount = 8;

  /// Largo máximo del nombre del local. Corto a propósito: tiene que caber en
  /// el letrero de la fachada sin achicarse hasta ser ilegible.
  static const int maxStoreNameLength = 18;

  /// Topes del multiplicador de texto. Más de 1,3 y el tablero de 6 columnas
  /// empieza a expulsar las etiquetas de los pedidos.
  static const double minTextScale = 0.9;
  static const double maxTextScale = 1.3;

  /// Limpia lo que el jugador escribió: sin espacios sobrantes y acotado.
  static String? sanitizeStoreName(String? raw) {
    final String trimmed = (raw ?? '').trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length <= maxStoreNameLength
        ? trimmed
        : trimmed.substring(0, maxStoreNameLength);
  }

  /// [clearLanguage] y [clearStoreName] permiten volver al valor "automático",
  /// que copyWith por sí solo no podría expresar (pasar null significa "no
  /// cambiar").
  GameSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? showIdleHints,
    bool? notificationsEnabled,
    String? languageCode,
    bool clearLanguage = false,
    String? storeName,
    bool clearStoreName = false,
    int? awningColor,
    AppThemeMode? themeMode,
    double? textScale,
  }) => GameSettings(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    showIdleHints: showIdleHints ?? this.showIdleHints,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
    storeName: clearStoreName ? null : (storeName ?? this.storeName),
    awningColor: awningColor ?? this.awningColor,
    themeMode: themeMode ?? this.themeMode,
    textScale: textScale ?? this.textScale,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'sound': soundEnabled,
    'haptics': hapticsEnabled,
    'reducedMotion': reducedMotion,
    'idleHints': showIdleHints,
    'notifications': notificationsEnabled,
    'language': languageCode,
    'storeName': storeName,
    'awningColor': awningColor,
    'themeMode': themeMode.name,
    'textScale': textScale,
  };

  static GameSettings fromJson(Map<String, dynamic> json) => GameSettings(
    soundEnabled: (json['sound'] as bool?) ?? true,
    hapticsEnabled: (json['haptics'] as bool?) ?? true,
    reducedMotion: (json['reducedMotion'] as bool?) ?? false,
    showIdleHints: (json['idleHints'] as bool?) ?? true,
    notificationsEnabled: (json['notifications'] as bool?) ?? false,
    languageCode: json['language'] as String?,
    storeName: sanitizeStoreName(json['storeName'] as String?),
    // Un save escrito por una versión con más colores no puede dejar el
    // toldo apuntando fuera de la paleta.
    awningColor: ((json['awningColor'] as int?) ?? 0).clamp(
      0,
      awningColorCount - 1,
    ),
    themeMode: AppThemeMode.fromName(json['themeMode'] as String?),
    textScale: ((json['textScale'] as num?)?.toDouble() ?? 1.0).clamp(
      minTextScale,
      maxTextScale,
    ),
  );
}
