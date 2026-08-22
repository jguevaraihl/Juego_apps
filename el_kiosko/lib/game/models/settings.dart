/// Preferencias del jugador. Todas se guardan en el save local; ninguna sale
/// del dispositivo.
class GameSettings {
  const GameSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.showIdleHints = true,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;

  /// Acorta o elimina animaciones. Ayuda en gama baja y en accesibilidad.
  final bool reducedMotion;

  final bool showIdleHints;

  GameSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? showIdleHints,
  }) => GameSettings(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    showIdleHints: showIdleHints ?? this.showIdleHints,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'sound': soundEnabled,
    'haptics': hapticsEnabled,
    'reducedMotion': reducedMotion,
    'idleHints': showIdleHints,
  };

  static GameSettings fromJson(Map<String, dynamic> json) => GameSettings(
    soundEnabled: (json['sound'] as bool?) ?? true,
    hapticsEnabled: (json['haptics'] as bool?) ?? true,
    reducedMotion: (json['reducedMotion'] as bool?) ?? false,
    showIdleHints: (json['idleHints'] as bool?) ?? true,
  );
}
