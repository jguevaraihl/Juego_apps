import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/progression/shop_tiers.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/game_strings.dart';
import 'storefront_painter.dart';

/// Fachada del local, dibujada en código (arte placeholder, PLAN_FINAL §17).
///
/// Es la meta visible de largo plazo: cada nivel agrega toldo, letrero,
/// estantes, clientes e iluminación. Sube de nivel ⇒ se ve distinto.
class Storefront extends StatelessWidget {
  const Storefront({
    required this.tier,
    this.height = 120,
    this.animate = true,
    this.storeName,
    this.awningColor = 0,
    super.key,
  });

  final ShopTier tier;
  final double height;
  final bool animate;

  /// Nombre puesto por el jugador. null = el nombre del nivel, como antes.
  final String? storeName;

  /// Índice en [AppTheme.awningPalette].
  final int awningColor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final String sign = storeName ?? l.shopTierName(tier.level);

    return Semantics(
      label: '$sign. ${l.shopTierTagline(tier.level)}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: animate ? 420 : 0),
            child: CustomPaint(
              // La key incluye letrero y toldo: sin eso, cambiar el nombre o
              // el color no volvería a pintar, porque el nivel no cambió.
              key: ValueKey<String>(
                '${tier.level}|$sign|$awningColor|'
                '${Theme.of(context).brightness.name}',
              ),
              painter: StorefrontPainter(
                tier: tier,
                signText: sign,
                awning: AppTheme.awningAt(awningColor),
                dark: Theme.of(context).brightness == Brightness.dark,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}
