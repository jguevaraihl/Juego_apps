import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Aviso de ganancia acumulada mientras la app estuvo cerrada.
///
/// El monto ya está cobrado cuando se muestra esto: no hay que hacer nada ni
/// ver nada para recibirlo. La opción de duplicar con rewarded ad llega en
/// Fase 3 y será siempre voluntaria (PLAN_FINAL §7.2).
class OfflineEarningsSheet extends StatelessWidget {
  const OfflineEarningsSheet({required this.amount, super.key});

  final int amount;

  static Future<void> show(BuildContext context, int amount) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        backgroundColor: AppTheme.paper,
        builder: (BuildContext context) => OfflineEarningsSheet(amount: amount),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.storefront, size: 40, color: AppTheme.wood),
          const SizedBox(height: 10),
          Text(
            'El almacén siguió vendiendo',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Mientras no estabas se juntaron $amount pesos en la caja.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.wood),
              child: const Text('Seguir atendiendo'),
            ),
          ),
        ],
      ),
    );
  }
}
