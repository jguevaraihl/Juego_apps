import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';

/// Barra inferior: la caja del proveedor y el botón de vender excedente.
///
/// Va abajo a propósito: es el control que más se usa y tiene que quedar al
/// alcance del pulgar con una sola mano (PLAN_FINAL §6).
class GeneratorBar extends StatelessWidget {
  const GeneratorBar({
    required this.cost,
    required this.canAfford,
    required this.boardFull,
    required this.onGenerate,
    required this.sellMode,
    required this.onToggleSell,
    super.key,
  });

  final int cost;
  final bool canAfford;
  final bool boardFull;
  final VoidCallback onGenerate;
  final bool sellMode;
  final VoidCallback onToggleSell;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool enabled = canAfford && !boardFull && !sellMode;
    final String hint = boardFull
        ? l.boardFull
        : (!canAfford ? l.notEnoughCoinsShort : l.supplierCost(cost));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              button: true,
              label: l.supplierSemantics(hint),
              child: SizedBox(
                height: 60,
                child: FilledButton.icon(
                  onPressed: enabled ? onGenerate : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.wood,
                    disabledBackgroundColor: AppTheme.wood.withValues(
                      alpha: 0.30,
                    ),
                  ),
                  icon: const Icon(Icons.inventory_2, size: 26),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(l.supplierBox),
                      Text(
                        hint,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 60,
            width: 88,
            child: OutlinedButton(
              onPressed: onToggleSell,
              style: OutlinedButton.styleFrom(
                backgroundColor: sellMode
                    ? AppTheme.success.withValues(alpha: 0.15)
                    : null,
                side: BorderSide(
                  color: sellMode ? AppTheme.success : AppTheme.wood,
                  width: sellMode ? 2 : 1.5,
                ),
                padding: EdgeInsets.zero,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    sellMode ? Icons.sell : Icons.sell_outlined,
                    color: sellMode ? AppTheme.success : AppTheme.woodDark,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sellMode ? l.sellDone : l.sell,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sellMode ? AppTheme.success : AppTheme.woodDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
