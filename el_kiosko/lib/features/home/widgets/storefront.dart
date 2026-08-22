import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/progression/shop_tiers.dart';

/// Fachada del local, dibujada en código (arte placeholder, PLAN_FINAL §17).
///
/// Es la meta visible de largo plazo: cada nivel agrega toldo, letrero,
/// estantes, clientes e iluminación. Sube de nivel ⇒ se ve distinto.
class Storefront extends StatelessWidget {
  const Storefront({
    required this.tier,
    this.height = 120,
    this.animate = true,
    super.key,
  });

  final ShopTier tier;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tu local: ${tier.name}. ${tier.tagline}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: animate ? 420 : 0),
            child: CustomPaint(
              key: ValueKey<int>(tier.level),
              painter: _StorefrontPainter(tier),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

class _StorefrontPainter extends CustomPainter {
  const _StorefrontPainter(this.tier);

  final ShopTier tier;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..isAntiAlias = true;
    final double w = size.width;
    final double h = size.height;

    // Pared: se aclara y se "termina" a medida que sube el nivel.
    final double polish = (tier.level - 1) / (ShopTiers.maxLevel - 1);
    paint.color = Color.lerp(
      const Color(0xFFB89778),
      const Color(0xFFF1E2CC),
      polish,
    )!;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    // Vereda.
    paint.color = const Color(0xFF9A8B78);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.82, w, h * 0.18), paint);

    // Luz cálida del local a partir del minimarket.
    if (tier.level >= 5) {
      paint.color = const Color(0xFFFFD79A).withValues(alpha: 0.35);
      canvas.drawCircle(Offset(w * 0.5, h * 0.35), h * 0.55, paint);
    }

    // Toldo a rayas desde el kiosko.
    if (tier.level >= 2) {
      final double awningH = h * 0.17;
      const int stripes = 9;
      for (int i = 0; i < stripes; i++) {
        paint.color = i.isEven ? AppTheme.awning : const Color(0xFFFBF3E4);
        canvas.drawRect(
          Rect.fromLTWH(w * i / stripes, 0, w / stripes, awningH),
          paint,
        );
      }
    }

    // Letrero con el nombre del nivel.
    if (tier.level >= 2) {
      final RRect sign = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.20, w * 0.84, h * 0.15),
        const Radius.circular(4),
      );
      paint.color = AppTheme.woodDark;
      canvas.drawRRect(sign, paint);
      _text(
        canvas,
        tier.name.toUpperCase(),
        Offset(w * 0.5, h * 0.275),
        fontSize: (h * 0.085).clamp(7.0, 13.0),
        color: const Color(0xFFFFE9C7),
        bold: true,
      );
    }

    // Estantes con productos.
    final double shelfTop = h * (tier.level >= 2 ? 0.40 : 0.24);
    final double shelfArea = h * 0.82 - shelfTop;
    final double shelfGap = shelfArea / (tier.shelves + 0.6);
    for (int s = 0; s < tier.shelves; s++) {
      final double y = shelfTop + shelfGap * s;
      paint.color = AppTheme.wood;
      canvas.drawRect(
        Rect.fromLTWH(w * 0.06, y + shelfGap * 0.55, w * 0.56, 2.5),
        paint,
      );
      // Mercadería sobre el estante.
      for (int p = 0; p < 5; p++) {
        paint.color = <Color>[
          const Color(0xFFD97706),
          const Color(0xFF0369A1),
          const Color(0xFF9333EA),
        ][(s + p) % 3];
        final double bh = shelfGap * 0.42;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * (0.08 + p * 0.105),
              y + shelfGap * 0.55 - bh,
              w * 0.062,
              bh,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
    }

    // Mesón.
    paint.color = AppTheme.woodDark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, h * 0.74, w * 0.62, h * 0.09),
        const Radius.circular(3),
      ),
      paint,
    );

    // Clientes: siluetas simples, sin caricaturas.
    for (int c = 0; c < tier.customers; c++) {
      final double x = w * (0.70 + (c % 4) * 0.075);
      final double baseY = h * (0.82 - (c >= 4 ? 0.10 : 0));
      paint.color = <Color>[
        const Color(0xFF3F3F46),
        const Color(0xFF57534E),
        const Color(0xFF44403C),
      ][c % 3];
      canvas.drawCircle(Offset(x, baseY - h * 0.20), h * 0.045, paint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - w * 0.024, baseY - h * 0.155, w * 0.048, h * 0.155),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  void _text(
    Canvas canvas,
    String value,
    Offset center, {
    required double fontSize,
    required Color color,
    bool bold = false,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_StorefrontPainter oldDelegate) =>
      oldDelegate.tier.level != tier.level;
}
