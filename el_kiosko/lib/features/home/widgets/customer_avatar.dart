import 'dart:math' as math;

import 'package:flutter/material.dart';

/// La cara del cliente, dibujada en código a partir de su id.
///
/// El juego tenía nombres de clientes pero ninguna cara, así que un pedido era
/// una fila de texto con números: se parecía más a una planilla que a un
/// almacén. Con una cara, "Don Chofer" deja de ser una etiqueta y pasa a ser
/// alguien esperando en el mesón.
///
/// El aspecto se deriva del id, así que **el mismo cliente se ve siempre
/// igual**: si cambiara en cada pedido no sería nadie. No hay assets con
/// licencia pendiente (PLAN_FINAL §17).
class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({required this.customerId, this.size = 28, super.key});

  final int customerId;
  final double size;

  /// Tonos de piel. Que sean varios no es decorativo: los clientes de un
  /// almacén de barrio son el barrio.
  static const List<Color> _skins = <Color>[
    Color(0xFF8D5524),
    Color(0xFFC68642),
    Color(0xFFE0AC69),
    Color(0xFFF1C27D),
    Color(0xFF5C3317),
    Color(0xFFA9714B),
  ];

  static const List<Color> _shirts = <Color>[
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFDC2626),
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFFEA580C),
    Color(0xFF4B5563),
    Color(0xFFDB2777),
    Color(0xFF65A30D),
    Color(0xFF9333EA),
    Color(0xFF0F766E),
    Color(0xFFB45309),
  ];

  static const List<Color> _hairs = <Color>[
    Color(0xFF1F1108),
    Color(0xFF3B2314),
    Color(0xFF6B4423),
    Color(0xFF9CA3AF),
    Color(0xFF111827),
    Color(0xFF7C2D12),
  ];

  @override
  Widget build(BuildContext context) {
    final int id = customerId.abs();
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CustomerPainter(
          skin: _skins[id % _skins.length],
          shirt: _shirts[id % _shirts.length],
          hair: _hairs[(id ~/ 2) % _hairs.length],
          // Seis peinados/sombreros, desfasados respecto del color para que
          // dos clientes seguidos no salgan casi iguales.
          style: (id ~/ 3) % 6,
        ),
      ),
    );
  }
}

class _CustomerPainter extends CustomPainter {
  const _CustomerPainter({
    required this.skin,
    required this.shirt,
    required this.hair,
    required this.style,
  });

  final Color skin;
  final Color shirt;
  final Color hair;
  final int style;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint paint = Paint()..isAntiAlias = true;

    // Hombros: un arco ancho abajo, que se lee como torso a cualquier tamaño.
    paint.color = shirt;
    canvas.drawArc(
      Rect.fromLTWH(w * 0.06, h * 0.60, w * 0.88, h * 0.75),
      math.pi,
      math.pi,
      true,
      paint,
    );

    // Cabeza.
    paint.color = skin;
    final Offset head = Offset(w * 0.5, h * 0.42);
    final double r = w * 0.27;
    canvas.drawCircle(head, r, paint);

    // Orejas: dos puntos que dan lectura de cara incluso a 20 px.
    canvas.drawCircle(Offset(head.dx - r * 0.98, head.dy), r * 0.20, paint);
    canvas.drawCircle(Offset(head.dx + r * 0.98, head.dy), r * 0.20, paint);

    _paintHead(canvas, paint, head, r, w, h);

    // Ojos.
    paint.color = const Color(0xFF1B1206);
    canvas.drawCircle(
      Offset(head.dx - r * 0.35, head.dy + r * 0.05),
      r * 0.13,
      paint,
    );
    canvas.drawCircle(
      Offset(head.dx + r * 0.35, head.dy + r * 0.05),
      r * 0.13,
      paint,
    );

    // Sonrisa. Todos los clientes llegan de buenas: el juego no castiga.
    paint
      ..color = const Color(0xFF7A3B22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, r * 0.13)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(head.dx, head.dy + r * 0.22),
        radius: r * 0.45,
      ),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      paint,
    );
    paint.style = PaintingStyle.fill;
  }

  /// Pelo o sombrero, según [style].
  void _paintHead(
    Canvas canvas,
    Paint paint,
    Offset head,
    double r,
    double w,
    double h,
  ) {
    paint.color = hair;
    switch (style) {
      case 0: // Pelo corto.
        canvas.drawArc(
          Rect.fromCircle(center: head, radius: r),
          math.pi,
          math.pi,
          true,
          paint,
        );
      case 1: // Gorro de lana, con vuelta.
        canvas.drawArc(
          Rect.fromCircle(center: head, radius: r * 1.05),
          math.pi,
          math.pi,
          true,
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(head.dx, head.dy - r * 0.82),
              width: r * 2.2,
              height: r * 0.36,
            ),
            Radius.circular(r * 0.18),
          ),
          paint,
        );
      case 2: // Jockey, con visera.
        canvas.drawArc(
          Rect.fromCircle(center: head, radius: r * 1.02),
          math.pi,
          math.pi,
          true,
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              head.dx - r * 0.1,
              head.dy - r * 0.95,
              r * 1.5,
              r * 0.3,
            ),
            Radius.circular(r * 0.15),
          ),
          paint,
        );
      case 3: // Moño.
        canvas.drawArc(
          Rect.fromCircle(center: head, radius: r),
          math.pi,
          math.pi,
          true,
          paint,
        );
        canvas.drawCircle(Offset(head.dx, head.dy - r * 1.15), r * 0.30, paint);
      case 4: // Pelo largo, cae por los lados.
        canvas.drawArc(
          Rect.fromCircle(center: head, radius: r * 1.04),
          math.pi,
          math.pi,
          true,
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(head.dx - r * 0.95, head.dy + r * 0.35),
            width: r * 0.5,
            height: r * 1.3,
          ),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(head.dx + r * 0.95, head.dy + r * 0.35),
            width: r * 0.5,
            height: r * 1.3,
          ),
          paint,
        );
      default: // Calvo con bigote: sin pelo arriba, pero con carácter.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(head.dx, head.dy + r * 0.42),
              width: r * 0.9,
              height: r * 0.2,
            ),
            Radius.circular(r * 0.1),
          ),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_CustomerPainter old) =>
      old.skin != skin ||
      old.shirt != shirt ||
      old.hair != hair ||
      old.style != style;
}
