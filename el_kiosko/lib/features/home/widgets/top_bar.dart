import 'package:flutter/material.dart';

import '../../../app/theme.dart';

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
    super.key,
  });

  final int coins;
  final int playerLevel;
  final double levelProgress;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenCollection;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      child: Row(
        children: <Widget>[
          Semantics(
            label: '$coins pesos',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.paper,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.coin.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.payments, size: 18, color: AppTheme.coin),
                  const SizedBox(width: 6),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.coin,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: 'Nivel $playerLevel',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Nivel $playerLevel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      minHeight: 6,
                      backgroundColor: AppTheme.wood.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.awning,
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
            tooltip: 'Álbum de productos',
          ),
          IconButton(
            onPressed: onOpenShop,
            icon: const Icon(Icons.storefront),
            tooltip: 'Mejorar el local',
          ),
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
