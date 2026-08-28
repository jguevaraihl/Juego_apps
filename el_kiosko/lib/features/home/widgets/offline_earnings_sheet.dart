import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';

/// Aviso de lo que juntó la caja mientras la app estuvo cerrada.
///
/// El monto **está en la caja, no en el bolsillo**: el botón lo cobra. Cerrar
/// el aviso sin tocarlo no pierde nada — la plata sigue en la caja y se cobra
/// tocándola en la fachada. Se cobra con la hora del momento del toque, así
/// que el total puede ser un pelo mayor que el que anuncia el botón.
///
/// La opción de duplicar con rewarded ad llega en Fase 3 y será siempre
/// voluntaria (PLAN_FINAL §7.2).
class OfflineEarningsSheet extends StatelessWidget {
  const OfflineEarningsSheet({
    required this.earned,
    required this.total,
    required this.onCollect,
    super.key,
  });

  /// Lo que se juntó durante la ausencia.
  final int earned;

  /// El saldo completo de la caja, que es lo que cobra el botón.
  final int total;
  final VoidCallback onCollect;

  static Future<void> show(
    BuildContext context, {
    required int earned,
    required int total,
    required VoidCallback onCollect,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.palette.paper,
    builder: (BuildContext context) => OfflineEarningsSheet(
      earned: earned,
      total: total,
      onCollect: onCollect,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.storefront, size: 40, color: context.palette.wood),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).offlineTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).offlineBody(earned),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          // Solo cuando el botón cobra más que lo de esta ausencia, para que
          // los dos números no parezcan contradecirse.
          if (total > earned) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).offlineTotal(total),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                onCollect();
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: context.palette.wood,
              ),
              child: Text(AppLocalizations.of(context).tillCollect(total)),
            ),
          ),
        ],
      ),
    );
  }
}
