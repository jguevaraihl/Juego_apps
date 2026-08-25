/// Preferencias del jugador. Todas se guardan en el save local; ninguna sale
/// del dispositivo.
class GameSettings {
  const GameSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.showIdleHints = true,
    this.notificationsEnabled = false,
    this.languageCode,
  });

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

  /// [clearLanguage] permite volver a "idioma del sistema", que copyWith por
  /// sí solo no podría expresar (pasar null significa "no cambiar").
  GameSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? showIdleHints,
    bool? notificationsEnabled,
    String? languageCode,
    bool clearLanguage = false,
  }) => GameSettings(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    showIdleHints: showIdleHints ?? this.showIdleHints,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'sound': soundEnabled,
    'haptics': hapticsEnabled,
    'reducedMotion': reducedMotion,
    'idleHints': showIdleHints,
    'notifications': notificationsEnabled,
    'language': languageCode,
  };

  static GameSettings fromJson(Map<String, dynamic> json) => GameSettings(
    soundEnabled: (json['sound'] as bool?) ?? true,
    hapticsEnabled: (json['haptics'] as bool?) ?? true,
    reducedMotion: (json['reducedMotion'] as bool?) ?? false,
    showIdleHints: (json['idleHints'] as bool?) ?? true,
    notificationsEnabled: (json['notifications'] as bool?) ?? false,
    languageCode: json['language'] as String?,
  );
}
