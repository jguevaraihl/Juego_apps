import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/game_state.dart';
import '../../../l10n/app_localizations.dart';

/// Onboarding de 3 acciones, siempre saltable (PLAN_FINAL §6).
///
/// No bloquea la pantalla: es una banda inferior que explica el siguiente
/// paso, para que el jugador aprenda jugando en vez de leyendo.
class OnboardingBanner extends StatelessWidget {
  const OnboardingBanner({required this.step, required this.onSkip, super.key});

  final TutorialStep step;
  final VoidCallback onSkip;

  /// Número de paso e ícono por etapa. El texto sale de lib/l10n.
  static const Map<TutorialStep, (int, IconData)> _steps =
      <TutorialStep, (int, IconData)>{
        TutorialStep.merge: (1, Icons.swipe),
        TutorialStep.completeOrder: (2, Icons.receipt_long),
        TutorialStep.upgrade: (3, Icons.storefront),
      };

  @override
  Widget build(BuildContext context) {
    final (int, IconData)? entry = _steps[step];
    if (entry == null) return const SizedBox.shrink();

    final AppLocalizations l = AppLocalizations.of(context);
    final String message = switch (step) {
      TutorialStep.merge => l.tutorialMerge,
      TutorialStep.completeOrder => l.tutorialOrder,
      TutorialStep.upgrade => l.tutorialUpgrade,
      TutorialStep.done => '',
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: AppTheme.woodDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Icon(entry.$2, color: const Color(0xFFFFE9C7), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l.tutorialStepOf(entry.$1),
                  style: const TextStyle(
                    color: Color(0xFFE7C89B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  message,
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
            child: Text(l.skip),
          ),
        ],
      ),
    );
  }
}
