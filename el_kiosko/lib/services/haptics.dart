import 'package:flutter/services.dart';

/// Feedback táctil y sonoro. Ambos se pueden desactivar en Ajustes.
///
/// En Fase 1 no se empaquetan archivos de audio: se usa el click del sistema,
/// que no requiere assets ni licencias. Los SFX propios entran cuando existan
/// con licencia registrada en ASSET_LICENSES.md.
class GameFeedback {
  const GameFeedback({required this.haptics, required this.sound});

  final bool haptics;
  final bool sound;

  void light() {
    if (haptics) HapticFeedback.lightImpact();
  }

  void selection() {
    if (haptics) HapticFeedback.selectionClick();
  }

  void success() {
    if (haptics) HapticFeedback.mediumImpact();
    if (sound) SystemSound.play(SystemSoundType.click);
  }

  void heavy() {
    if (haptics) HapticFeedback.heavyImpact();
    if (sound) SystemSound.play(SystemSoundType.click);
  }
}
