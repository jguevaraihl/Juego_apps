import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';

/// Barra superior: monedas, nivel del jugador y accesos. Todos los objetivos
/// táctiles cumplen el mínimo de 48dp.
class TopBar extends StatelessWidget {
  const TopBar({
    required this.coins,
    required this.playerLevel,
    required this.levelProgress,
    required this.onOpenShop,
    required this.onOpenCollection,
    required this.onOpenSettings,
    required this.upgradeAvailable,
    super.key,
  });

  final int coins;
  final int playerLevel;
  final double levelProgress;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenCollection;
  final VoidCallback onOpenSettings;

  /// Hay monedas suficientes para el siguiente nivel del local.
  final bool upgradeAvailable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      child: Row(
        children: <Widget>[
          Semantics(
            label: l.coinsLabel(coins),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.palette.paper,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.palette.coin.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.payments, size: 18, color: context.palette.coin),
                  const SizedBox(width: 6),
                  Text(
                    '$coins',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: context.palette.coin,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: l.playerLevel(playerLevel),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l.playerLevel(playerLevel),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: context.palette.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      minHeight: 6,
                      backgroundColor: context.palette.wood.withValues(
                        alpha: 0.15,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.palette.awning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onOpenCollection,
            icon: const Icon(Icons.menu_book),
            tooltip: l.tooltipCollection,
          ),
          IconButton(
            onPressed: onOpenShop,
            // Un punto discreto avisa que ya alcanza para mejorar, sin
            // interrumpir con un aviso modal.
            icon: upgradeAvailable
                ? Badge(
                    backgroundColor: context.palette.success,
                    smallSize: 9,
                    child: Icon(Icons.storefront),
                  )
                : const Icon(Icons.storefront),
            tooltip: upgradeAvailable ? l.shopUpgradeReady : l.tooltipShop,
          ),
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings),
            tooltip: l.tooltipSettings,
          ),
        ],
      ),
    );
  }
}
