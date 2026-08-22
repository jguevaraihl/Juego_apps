import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/game_state.dart';

/// Onboarding de 3 acciones, siempre saltable (PLAN_FINAL §6).
///
/// No bloquea la pantalla: es una banda inferior que explica el siguiente
/// paso, para que el jugador aprenda jugando en vez de leyendo.
class OnboardingBanner extends StatelessWidget {
  const OnboardingBanner({required this.step, required this.onSkip, super.key});

  final TutorialStep step;
  final VoidCallback onSkip;

  static const Map<TutorialStep, (String, String, IconData)> _copy =
      <TutorialStep, (String, String, IconData)>{
        TutorialStep.merge: (
          'Paso 1 de 3',
          'Arrastra dos productos iguales para juntarlos.',
          Icons.swipe,
        ),
        TutorialStep.completeOrder: (
          'Paso 2 de 3',
          'Ahora completa un pedido y cobra.',
          Icons.receipt_long,
        ),
        TutorialStep.upgrade: (
          'Paso 3 de 3',
          'Usa tus monedas para mejorar el local.',
          Icons.storefront,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final (String, String, IconData)? copy = _copy[step];
    if (copy == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: AppTheme.woodDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Icon(copy.$3, color: const Color(0xFFFFE9C7), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  copy.$1,
                  style: const TextStyle(
                    color: Color(0xFFE7C89B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  copy.$2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE7C89B),
              minimumSize: const Size(
                AppTheme.minTouchTarget,
                AppTheme.minTouchTarget,
              ),
            ),
            child: const Text('Saltar'),
          ),
        ],
      ),
    );
  }
}
