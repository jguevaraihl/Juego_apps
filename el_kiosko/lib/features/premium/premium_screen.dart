import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

/// Vitrina del producto pagado. En Fase 1 es informativa: no hay billing
/// integrado y por lo tanto no se muestra ningún precio.
///
/// Los precios nunca se hardcodean: cuando entre Google Play Billing (Fase 3)
/// se leen desde la tienda, que además los localiza (PLAN_FINAL §8).
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.premiumTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: <Widget>[
          Icon(Icons.workspace_premium, size: 44, color: context.palette.wood),
          const SizedBox(height: 12),
          Text(
            l.premiumNotAvailable,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(l.premiumBody, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 20),
          Text(
            l.premiumEvaluating,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _Bullet(l.premiumBullet1),
          _Bullet(l.premiumBullet2),
          _Bullet(l.premiumBullet3),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 3, right: 10),
            child: Icon(
              Icons.check_circle_outline,
              size: 18,
              color: context.palette.wood,
            ),
          ),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
