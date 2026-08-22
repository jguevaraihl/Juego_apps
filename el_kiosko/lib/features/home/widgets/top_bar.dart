import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';

/// Barra superior: monedas, nivel del jugador y accesos. Todos los objetivos
/// táctiles cumplen el mínimo de 48dp.
class TopBar extends StatelessWidget {
  const TopBar({
    required this.coins,
    required this.displayCoins,
    required this.playerLevel,
    required this.levelProgress,
    required this.onOpenShop,
    required this.onOpenCollection,
    required this.onOpenSettings,
    required this.upgradeAvailable,
    super.key,
  });

  final int coins;

  /// Monedas con la fracción de ganancia pasiva incluida. Se muestra con dos
  /// decimales chicos, para que el contador se vea subir de forma continua.
  final double displayCoins;

  final int playerLevel;
  final double levelProgress;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenCollection;
  final VoidCallback onOpenSettings;

  /// Hay monedas suficientes para el siguiente nivel del local.
  final bool upgradeAvailable;

  /// Los dos decimales, con el separador que corresponde al idioma: en
  /// español es coma y en inglés punto, así que no puede ir hardcodeado.
  static String _fraction(BuildContext context, double value) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final String separator = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    ).format(0).substring(1, 2);
    final int hundredths = ((value - value.floor()) * 100).floor().clamp(0, 99);
    return '$separator${hundredths.toString().padLeft(2, '0')}';
  }

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
                    '${displayCoins.floor()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.coin,
                    ),
                  ),
                  // Los decimales van más chicos y apagados: de un vistazo se
                  // lee el entero, pero se nota que la caja sigue trabajando.
                  Text(
                    _fraction(context, displayCoins),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppTheme.coin.withValues(alpha: 0.55),
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
            tooltip: l.tooltipCollection,
          ),
          IconButton(
            onPressed: onOpenShop,
            // Un punto discreto avisa que ya alcanza para mejorar, sin
            // interrumpir con un aviso modal.
            icon: upgradeAvailable
                ? const Badge(
                    backgroundColor: AppTheme.success,
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
