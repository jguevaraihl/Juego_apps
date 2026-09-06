import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../game/progression/shop_tiers.dart';
import '../../game/progression/workers.dart';
import '../../l10n/app_localizations.dart';

/// Las reglas, escritas, y disponibles siempre.
///
/// **Por qué existe además del tutorial.** El tutorial se ve una vez, en la
/// primera sesión, cuando el jugador todavía no tiene con qué relacionar lo
/// que lee. Todo lo que aprenda ahí y se le olvide —cómo funciona el tope de
/// la caja, qué significan las estrellas del nombre, si los pedidos caducan—
/// no tenía dónde volver a consultarse. Ese vacío es exactamente el que
/// produce la sensación de "no entiendo bien qué se supone que haga".
///
/// Está escrita en el mismo tono que el resto del juego: frases cortas, sin
/// jerga, y contando también lo que **no** pasa —los pedidos no caducan, no
/// cumplir las misiones no quita nada—, porque en este género la gente
/// asume lo peor por experiencia con otros juegos.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);

    final List<(IconData, String, String)> sections =
        <(IconData, String, String)>[
          (Icons.sync_alt, l.helpLoopTitle, l.helpLoopBody),
          (Icons.swipe, l.helpMergeTitle, l.helpMergeBody),
          (Icons.receipt_long, l.helpOrdersTitle, l.helpOrdersBody),
          (Icons.savings, l.helpTillTitle, l.helpTillBody),
          (
            Icons.storefront,
            l.helpShopTitle,
            l.helpShopBody(ShopTiers.maxLevel),
          ),
          (Icons.emoji_events, l.helpGoalsTitle, l.helpGoalsBody),
          (
            Icons.support_agent,
            l.helpHelpersTitle,
            l.helpHelpersBody(Workers.unlockShopLevel),
          ),
        ];

    return Scaffold(
      appBar: AppBar(title: Text(l.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          for (final (IconData icon, String title, String body) s in sections)
            _Section(icon: s.$1, title: s.$2, body: s.$3),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 20, color: context.palette.wood),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ],
    ),
  );
}
