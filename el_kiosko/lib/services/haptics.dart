import 'package:flutter/services.dart';

/// Respuesta táctil. Se puede desactivar en Ajustes, por separado del sonido.
class GameFeedback {
  const GameFeedback({required this.haptics});

  final bool haptics;

  void light() {
    if (haptics) HapticFeedback.lightImpact();
  }

  void selection() {
    if (haptics) HapticFeedback.selectionClick();
  }

  void success() {
    if (haptics) HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (haptics) HapticFeedback.heavyImpact();
  }
}
