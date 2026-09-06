import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/game_state.dart';
import '../../../l10n/app_localizations.dart';

/// Onboarding de seis acciones, siempre saltable (PLAN_FINAL §6).
///
/// No bloquea la pantalla: es una banda inferior que explica el siguiente
/// paso, para que el jugador aprenda jugando en vez de leyendo.
class OnboardingBanner extends StatelessWidget {
  const OnboardingBanner({
    required this.step,
    required this.onSkip,
    required this.onNext,
    super.key,
  });

  final TutorialStep step;
  final VoidCallback onSkip;

  /// Pasar al siguiente paso sin hacer la acción. El tutorial avanza solo
  /// cuando el jugador la hace, pero quien ya entendió tiene que poder
  /// seguir de largo.
  final VoidCallback onNext;

  /// Ícono de cada etapa. El número sale del propio enum y el texto de
  /// lib/l10n, así que agregar un paso es agregar una fila acá y una cadena.
  static const Map<TutorialStep, IconData> _icons = <TutorialStep, IconData>{
    TutorialStep.supply: Icons.inventory_2,
    TutorialStep.merge: Icons.swipe,
    TutorialStep.readOrder: Icons.receipt_long,
    TutorialStep.completeOrder: Icons.local_shipping,
    TutorialStep.till: Icons.savings,
    TutorialStep.upgrade: Icons.storefront,
  };

  @override
  Widget build(BuildContext context) {
    final IconData? icon = _icons[step];
    if (icon == null) return const SizedBox.shrink();

    final AppLocalizations l = AppLocalizations.of(context);
    final String message = switch (step) {
      TutorialStep.supply => l.tutorialSupply,
      TutorialStep.merge => l.tutorialMerge,
      TutorialStep.readOrder => l.tutorialReadOrder,
      TutorialStep.completeOrder => l.tutorialOrder,
      TutorialStep.till => l.tutorialTill,
      TutorialStep.upgrade => l.tutorialUpgrade,
      TutorialStep.done => '',
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: AppTheme.brandWoodDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: const Color(0xFFFFE9C7), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l.tutorialStepOf(step.number, TutorialStep.count),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextButton(
                onPressed: onNext,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l.next,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE7C89B),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l.skip, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
