import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Un "+N" que sube y se desvanece junto al contador de monedas.
///
/// Deliberadamente pequeño y corto: el objetivo es que el jugador *sienta* la
/// ganancia sin que el aviso le tape el tablero ni le corte el ritmo. Si el
/// jugador activó "reducir animaciones", sólo hace un fundido, sin movimiento.
class CoinBurst extends StatelessWidget {
  const CoinBurst({
    required this.amount,
    required this.reducedMotion,
    required this.onDone,
    super.key,
  });

  final int amount;
  final bool reducedMotion;
  final VoidCallback onDone;

  static const Duration duration = Duration(milliseconds: 900);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      onEnd: onDone,
      builder: (BuildContext context, double t, Widget? child) {
        // Entra rápido, se queda un momento a plena opacidad para que el
        // número alcance a leerse, y recién ahí se desvanece.
        final double opacity = switch (t) {
          < 0.12 => t / 0.12,
          < 0.5 => 1,
          _ => 1 - (t - 0.5) / 0.5,
        };
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, reducedMotion ? 0 : -22 * t),
            child: child,
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.success,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          child: Text(
            '+$amount',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
