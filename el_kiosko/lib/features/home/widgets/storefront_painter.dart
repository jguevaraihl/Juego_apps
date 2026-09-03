import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../game/progression/shop_tiers.dart';

/// Dibuja la fachada del almacén, nivel por nivel.
///
/// **Por qué está dibujado en código.** No hay assets con licencia pendiente
/// (PLAN_FINAL §17) y cada nivel tiene que verse claramente mejor que el
/// anterior: esa escalera visual es la meta de largo plazo del juego. Un set
/// de ilustraciones encargadas a un artista daría más textura, y la clase está
/// preparada para recibirlas —ver [Storefront], que primero busca una imagen y
/// sólo cae acá si no existe— pero mientras tanto esto tiene que sostener el
/// juego solo.
///
/// **Cómo está armado.** Se pinta de atrás hacia adelante, como un decorado de
/// teatro: cielo, edificios vecinos, muro, letrero, toldo, vitrina, estantes,
/// mesón, vereda y clientes. Cada capa consulta el nivel para decidir si
/// aparece y con cuánto detalle, así que subir de nivel no es "lo mismo pero
/// más grande": entran elementos nuevos.
///
/// Todas las medidas son fracciones del alto y el ancho, así que la misma
/// escena sirve para la miniatura de 96 px de la pantalla principal y para los
/// 190 px de la pantalla del local.
class StorefrontPainter extends CustomPainter {
  const StorefrontPainter({
    required this.tier,
    required this.signText,
    required this.awning,
    required this.dark,
    this.petId = 0,
  });

  final ShopTier tier;

  /// Lo que dice el letrero, ya traducido: el painter no tiene BuildContext.
  final String signText;

  /// Color de la tela del toldo, elegido por el jugador.
  final Color awning;

  /// En modo oscuro la escena pasa a ser de noche: se apaga el cielo y se
  /// encienden las luces. La fachada no se "invierte" —sigue siendo el mismo
  /// almacén— pero deja de ser un recorte a plena luz sobre un fondo negro.
  final bool dark;

  /// Mascota elegida por el jugador. 0 = ninguna, y en ese caso el local
  /// recupera el gato que aparecía solo en el nivel 6.
  final int petId;

  int get level => tier.level;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    _sky(canvas, w, h);
    _neighbours(canvas, w, h);
    _wall(canvas, w, h);
    _sign(canvas, w, h);
    _awning(canvas, w, h);
    _windows(canvas, w, h);
    _shelves(canvas, w, h);
    _counter(canvas, w, h);
    _pavement(canvas, w, h);
    _props(canvas, w, h);
    _customers(canvas, w, h);
    _lighting(canvas, w, h);

    canvas.restore();
  }

  // ------------------------------------------------------------------
  // Capas
  // ------------------------------------------------------------------

  /// Cielo. De día se aclara con el nivel —el barrio mejora con el local—; de
  /// noche es azul profundo con un resplandor sobre el horizonte.
  void _sky(Canvas canvas, double w, double h) {
    final Rect rect = Rect.fromLTWH(0, 0, w, h);
    final List<Color> stops = dark
        ? <Color>[const Color(0xFF141B2E), const Color(0xFF2A3350)]
        : <Color>[
            Color.lerp(
              const Color(0xFF9EC5E8),
              const Color(0xFF6FB1E8),
              _progress,
            )!,
            Color.lerp(
              const Color(0xFFE8DCC0),
              const Color(0xFFFBEBD0),
              _progress,
            )!,
          ];
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, 0), Offset(0, h * 0.62), stops),
    );

    if (dark) {
      // Luna: un detalle chico que fija que es de noche.
      canvas.drawCircle(
        Offset(w * 0.86, h * 0.13),
        h * 0.055,
        Paint()..color = const Color(0xFFF3E6C8).withValues(alpha: 0.85),
      );
    }
  }

  /// Siluetas del barrio detrás. Aparecen a partir del nivel 3: antes el
  /// puesto está solo, y esa soledad es parte de que se vea humilde.
  void _neighbours(Canvas canvas, double w, double h) {
    if (level < 3) return;
    final Paint paint = Paint()
      ..color = dark
          ? const Color(0xFF1D2436)
          : const Color(0xFFB9A88E).withValues(alpha: 0.55);

    final List<({double x, double wd, double ht})> blocks =
        <({double x, double wd, double ht})>[
          (x: -0.04, wd: 0.26, ht: 0.30),
          (x: 0.20, wd: 0.18, ht: 0.22),
          (x: 0.66, wd: 0.22, ht: 0.34),
          (x: 0.86, wd: 0.20, ht: 0.25),
        ];
    for (final ({double x, double wd, double ht}) b in blocks) {
      final Rect r = Rect.fromLTWH(
        w * b.x,
        h * (0.46 - b.ht),
        w * b.wd,
        h * b.ht,
      );
      canvas.drawRect(r, paint);
      // Ventanitas encendidas de noche.
      if (dark) {
        final Paint lit = Paint()..color = const Color(0xFFE8C36A);
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 2; j++) {
            if ((i + j + b.x * 10).round().isEven) continue;
            canvas.drawRect(
              Rect.fromLTWH(
                r.left + r.width * (0.18 + i * 0.26),
                r.top + r.height * (0.22 + j * 0.30),
                r.width * 0.14,
                r.height * 0.14,
              ),
              lit,
            );
          }
        }
      }
    }
  }

  /// Muro del local, con textura y zócalo. La pared se termina y se pinta a
  /// medida que sube el nivel: del ladrillo desnudo al revoque parejo.
  void _wall(Canvas canvas, double w, double h) {
    final Rect wall = Rect.fromLTWH(w * 0.02, h * 0.06, w * 0.96, h * 0.72);
    final Color base = Color.lerp(
      const Color(0xFFB08968),
      const Color(0xFFF2E3C9),
      _progress,
    )!;
    final Paint paint = Paint()
      ..shader = ui.Gradient.linear(wall.topLeft, wall.bottomLeft, <Color>[
        _shade(base, 1.06),
        _shade(base, 0.88),
      ]);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        wall,
        topLeft: Radius.circular(h * 0.05),
        topRight: Radius.circular(h * 0.05),
      ),
      paint,
    );

    // Hiladas de ladrillo: se ven mucho abajo y se pierden al subir de nivel,
    // como si el local se hubiera ido revocando.
    final double brickAlpha = 0.30 * (1 - _progress) + 0.06;
    final Paint mortar = Paint()
      ..color = _shade(base, 0.78).withValues(alpha: brickAlpha)
      ..strokeWidth = math.max(0.6, h * 0.006)
      ..style = PaintingStyle.stroke;
    for (int row = 0; row < 7; row++) {
      final double y = wall.top + wall.height * (0.10 + row * 0.115);
      if (y > wall.bottom) break;
      canvas.drawLine(Offset(wall.left, y), Offset(wall.right, y), mortar);
      for (int c = 0; c < 6; c++) {
        final double x =
            wall.left + wall.width * ((c + (row.isEven ? 0.5 : 0)) / 6);
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + wall.height * 0.115),
          mortar,
        );
      }
    }

    // Zócalo pintado: aparece cuando el local deja de ser un puesto.
    if (level >= 3) {
      canvas.drawRect(
        Rect.fromLTWH(wall.left, h * 0.68, wall.width, h * 0.10),
        Paint()..color = _shade(awning, 0.55).withValues(alpha: 0.85),
      );
    }
  }

  /// Letrero. Crece, se le agrega marco, y desde el nivel 5 lleva luces.
  void _sign(Canvas canvas, double w, double h) {
    if (level < 2) {
      // Nivel 1: un cartón escrito a mano, torcido.
      canvas.save();
      canvas.translate(w * 0.5, h * 0.17);
      canvas.rotate(-0.045);
      final Rect card = Rect.fromCenter(
        center: Offset.zero,
        width: w * 0.52,
        height: h * 0.14,
      );
      canvas.drawRect(card, Paint()..color = const Color(0xFFE8D6AE));
      canvas.drawRect(
        card,
        Paint()
          ..color = const Color(0xFF8A6A40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, h * 0.008),
      );
      _text(
        canvas,
        signText.toUpperCase(),
        Offset.zero,
        fontSize: (h * 0.075).clamp(6.0, 13.0),
        color: const Color(0xFF4A3218),
        bold: true,
        maxWidth: card.width * 0.92,
      );
      canvas.restore();
      return;
    }

    final double top = h * 0.11;
    final double height = h * 0.155;
    final Rect board = Rect.fromLTWH(w * 0.07, top, w * 0.86, height);
    final RRect frame = RRect.fromRectAndRadius(
      board,
      Radius.circular(h * 0.03),
    );

    // Sombra del letrero sobre el muro: lo despega de la pared.
    canvas.drawRRect(
      frame.shift(Offset(0, h * 0.012)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    canvas.drawRRect(
      frame,
      Paint()
        ..shader = ui.Gradient.linear(board.topLeft, board.bottomLeft, <Color>[
          const Color(0xFF6B4423),
          const Color(0xFF3A2413),
        ]),
    );
    canvas.drawRRect(
      frame.deflate(h * 0.012),
      Paint()
        ..color = _shade(awning, 1.15).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, h * 0.008),
    );

    _text(
      canvas,
      signText.toUpperCase(),
      board.center,
      fontSize: (h * 0.085).clamp(7.0, 15.0),
      color: const Color(0xFFFFE9C7),
      bold: true,
      maxWidth: board.width * 0.90,
    );

    // Ampolletas alrededor del letrero, desde el nivel 5.
    if (level >= 5) {
      final Paint bulb = Paint()
        ..color = dark ? const Color(0xFFFFE08A) : const Color(0xFFF6D98A);
      for (int i = 0; i < 9; i++) {
        final double x = board.left + board.width * (0.06 + i * 0.11);
        canvas.drawCircle(Offset(x, board.top), h * 0.011, bulb);
        canvas.drawCircle(Offset(x, board.bottom), h * 0.011, bulb);
      }
    }
  }

  /// Toldo a rayas con borde ondulado. Desde el nivel 4 tiene volumen.
  void _awning(Canvas canvas, double w, double h) {
    if (level < 2) return;

    // Bajo y corto: un toldo alto se come la vitrina, que es donde está lo
    // que el jugador quiere ver.
    final double top = h * 0.295;
    final double height = h * 0.070;
    final double left = w * 0.03;
    final double right = w * 0.97;
    const int stripes = 9;
    final double stripeW = (right - left) / stripes;

    // La onda cuelga poco: media altura del toldo. Más profunda se convierte
    // en una fila de semicírculos que domina la escena.
    final double scallop = height * 0.55;
    for (int i = 0; i < stripes; i++) {
      final Color color = i.isEven ? awning : const Color(0xFFF7EEDD);
      final double x = left + i * stripeW;
      final Paint fill = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, top),
          Offset(0, top + height + scallop),
          <Color>[_shade(color, 1.14), _shade(color, 0.84)],
        );
      // Cuerpo de la franja.
      canvas.drawRect(Rect.fromLTWH(x, top, stripeW, height), fill);
      // Y la onda colgando del borde: es lo que la hace leer como tela de
      // toldo y no como una franja de color.
      canvas.drawArc(
        Rect.fromLTWH(x, top + height - scallop, stripeW, scallop * 2),
        0,
        math.pi,
        true,
        fill,
      );
    }

    // Sombra que el toldo proyecta sobre la vitrina.
    canvas.drawRect(
      Rect.fromLTWH(left, top + height + scallop, right - left, h * 0.035),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );

    // Varillas de sostén, desde el nivel 4.
    if (level >= 4) {
      final Paint rod = Paint()
        ..color = const Color(0xFF5A4632)
        ..strokeWidth = math.max(1, h * 0.010)
        ..strokeCap = StrokeCap.round;
      for (final double x in <double>[
        left + stripeW * 0.6,
        right - stripeW * 0.6,
      ]) {
        canvas.drawLine(Offset(x, top + height), Offset(x, h * 0.50), rod);
      }
    }
  }

  /// Vitrina: marco, vidrio con reflejo y mercadería detrás.
  void _windows(Canvas canvas, double w, double h) {
    if (level < 3) return;

    final int panes = level >= 6 ? 2 : 1;
    final double topY = h * 0.44;
    final double bottomY = h * 0.70;
    final double margin = w * 0.06;
    final double gap = w * 0.04;
    final double totalW = w - margin * 2 - gap * (panes - 1);
    final double paneW = totalW / panes;

    for (int i = 0; i < panes; i++) {
      final Rect glass = Rect.fromLTWH(
        margin + i * (paneW + gap),
        topY,
        paneW,
        bottomY - topY,
      );

      // Marco.
      canvas.drawRect(
        glass.inflate(h * 0.014),
        Paint()..color = const Color(0xFF6B4423),
      );

      // Vidrio: de noche, iluminado desde adentro.
      canvas.drawRect(
        glass,
        Paint()
          ..shader = ui.Gradient.linear(
            glass.topLeft,
            glass.bottomRight,
            dark
                ? <Color>[const Color(0xFFF6D98A), const Color(0xFFC79A4E)]
                : <Color>[const Color(0xFFDCEAF2), const Color(0xFFA9C6D8)],
          ),
      );

      // Reflejo diagonal: es lo que hace que el vidrio parezca vidrio.
      final Path glint = Path()
        ..moveTo(glass.left, glass.bottom)
        ..lineTo(glass.left + glass.width * 0.42, glass.top)
        ..lineTo(glass.left + glass.width * 0.62, glass.top)
        ..lineTo(glass.left + glass.width * 0.20, glass.bottom)
        ..close();
      canvas.save();
      canvas.clipRect(glass);
      canvas.drawPath(
        glint,
        Paint()..color = Colors.white.withValues(alpha: dark ? 0.16 : 0.30),
      );
      canvas.restore();

      // Cruceta del marco, desde el nivel 5.
      if (level >= 5) {
        final Paint bar = Paint()
          ..color = const Color(0xFF6B4423)
          ..strokeWidth = math.max(1, h * 0.010);
        canvas.drawLine(
          Offset(glass.center.dx, glass.top),
          Offset(glass.center.dx, glass.bottom),
          bar,
        );
      }
    }
  }

  /// Estantes con mercadería. La cantidad la fija el nivel del local, así que
  /// mejorar se ve literalmente como más cosas para vender.
  void _shelves(Canvas canvas, double w, double h) {
    final double top = level >= 3 ? h * 0.455 : h * 0.42;
    final double available = (level >= 3 ? h * 0.685 : h * 0.665) - top;
    final int count = tier.shelves.clamp(1, 5);
    final double step = available / count;

    final Paint plank = Paint()..color = const Color(0xFF7A5230);
    // Paleta de la mercadería: los mismos tonos que las cadenas del juego, para
    // que la vitrina se lea como "lo que vendo" y no como decoración.
    const List<Color> goods = <Color>[
      Color(0xFFD97706),
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
      Color(0xFFCA8A04),
      Color(0xFF0891B2),
      Color(0xFFDC2626),
    ];

    for (int s = 0; s < count; s++) {
      final double y = top + step * (s + 0.85);
      canvas.drawRect(Rect.fromLTWH(w * 0.09, y, w * 0.82, h * 0.014), plank);

      // La mercadería alterna tres siluetas —botella, caja y tarro— en vez de
      // ser todo rectángulos. Con una sola forma el estante se leía como un
      // gráfico de barras, que es justo la sensación que hay que evitar.
      final int items = 5 + level ~/ 2;
      final double slot = w * 0.82 / items;
      for (int i = 0; i < items; i++) {
        final double cx = w * 0.09 + slot * (i + 0.5);
        final Color c = goods[(i + s * 2) % goods.length];
        final int shape = (i + s) % 3;
        final double bh = h * (0.034 + (i % 2) * 0.010);
        final double bw = slot * 0.56;

        switch (shape) {
          case 0: // Botella: cuerpo, hombro y cuello.
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(cx - bw * 0.34, y - bh, bw * 0.68, bh),
                Radius.circular(bw * 0.14),
              ),
              Paint()..color = c,
            );
            canvas.drawRect(
              Rect.fromLTWH(
                cx - bw * 0.13,
                y - bh - h * 0.014,
                bw * 0.26,
                h * 0.014,
              ),
              Paint()..color = _shade(c, 0.82),
            );
          case 1: // Caja: rectángulo con una etiqueta clara.
            canvas.drawRect(
              Rect.fromLTWH(cx - bw * 0.46, y - bh, bw * 0.92, bh),
              Paint()..color = c,
            );
            canvas.drawRect(
              Rect.fromLTWH(
                cx - bw * 0.30,
                y - bh * 0.66,
                bw * 0.60,
                bh * 0.26,
              ),
              Paint()..color = Colors.white.withValues(alpha: 0.55),
            );
          default: // Tarro: cilindro con tapa.
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(cx - bw * 0.36, y - bh, bw * 0.72, bh),
                Radius.circular(bw * 0.30),
              ),
              Paint()..color = c,
            );
            canvas.drawOval(
              Rect.fromLTWH(
                cx - bw * 0.36,
                y - bh - h * 0.006,
                bw * 0.72,
                h * 0.014,
              ),
              Paint()..color = _shade(c, 1.25),
            );
        }

        // Brillo vertical: una sola línea clara basta para dar volumen.
        canvas.drawRect(
          Rect.fromLTWH(cx - bw * 0.26, y - bh * 0.92, bw * 0.12, bh * 0.72),
          Paint()..color = Colors.white.withValues(alpha: 0.20),
        );
      }
    }
  }

  /// Mesón y cajones al frente.
  void _counter(Canvas canvas, double w, double h) {
    final Rect counter = Rect.fromLTWH(
      w * 0.05,
      h * 0.705,
      w * 0.90,
      h * 0.075,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(counter, Radius.circular(h * 0.014)),
      Paint()
        ..shader = ui.Gradient.linear(
          counter.topLeft,
          counter.bottomLeft,
          <Color>[const Color(0xFF8B5E34), const Color(0xFF4E3218)],
        ),
    );
    // Canto claro: separa el mesón del muro que tiene detrás.
    canvas.drawRect(
      Rect.fromLTWH(counter.left, counter.top, counter.width, h * 0.012),
      Paint()..color = const Color(0xFFB98A57),
    );

    // Balanza y caja registradora, desde el nivel 4.
    if (level >= 4) {
      final Paint metal = Paint()..color = const Color(0xFFC7CBD1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.10, h * 0.665, w * 0.10, h * 0.042),
          Radius.circular(h * 0.008),
        ),
        metal,
      );
      canvas.drawRect(
        Rect.fromLTWH(w * 0.115, h * 0.652, w * 0.07, h * 0.014),
        Paint()..color = const Color(0xFF8E949C),
      );
    }
  }

  /// Vereda con cordón. Ancla el local en la calle en vez de dejarlo flotando.
  void _pavement(Canvas canvas, double w, double h) {
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.78, w, h * 0.22),
      Paint()..color = dark ? const Color(0xFF2A2A30) : const Color(0xFFC9C2B4),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.78, w, h * 0.014),
      Paint()..color = dark ? const Color(0xFF3A3A44) : const Color(0xFFA9A294),
    );
    // Juntas de las baldosas.
    final Paint joint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..strokeWidth = math.max(0.6, h * 0.005);
    for (int i = 1; i < 5; i++) {
      final double x = w * i / 5;
      canvas.drawLine(Offset(x, h * 0.794), Offset(x, h), joint);
    }
  }

  /// Cajón, pizarra de precios, planta y gato.
  ///
  /// La vereda está repartida en franjas fijas —cajón a la izquierda, pizarra
  /// al lado, gente en el centro, planta a la derecha— porque en la versión
  /// anterior la bicicleta caía justo encima de un cliente. A este alto no hay
  /// espacio para improvisar: cada cosa tiene su tramo.
  void _props(Canvas canvas, double w, double h) {
    // Cajón de fruta: lo primero que tiene un puesto, está desde el nivel 1.
    final Rect crate = Rect.fromLTWH(w * 0.03, h * 0.845, w * 0.135, h * 0.095);
    canvas.drawRect(crate, Paint()..color = const Color(0xFF9A6B3F));
    final Paint slat = Paint()
      ..color = const Color(0xFF6E4826)
      ..strokeWidth = math.max(0.8, h * 0.006);
    for (int i = 1; i < 3; i++) {
      final double y = crate.top + crate.height * i / 3;
      canvas.drawLine(Offset(crate.left, y), Offset(crate.right, y), slat);
    }
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(
          crate.left + crate.width * (0.22 + i * 0.28),
          crate.top - h * 0.012,
        ),
        h * 0.017,
        Paint()..color = const Color(0xFFE0533B),
      );
    }

    // Pizarra de precios en la vereda, desde el nivel 5. Reemplaza a la
    // bicicleta, que quedaba encima de la gente.
    if (level >= 5) {
      final Rect board = Rect.fromLTWH(
        w * 0.195,
        h * 0.815,
        w * 0.11,
        h * 0.105,
      );
      canvas.drawRect(board, Paint()..color = const Color(0xFF6B4423));
      canvas.drawRect(
        board.deflate(h * 0.010),
        Paint()..color = const Color(0xFF27332B),
      );
      final Paint chalk = Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..strokeWidth = math.max(0.7, h * 0.006);
      for (int i = 0; i < 3; i++) {
        final double y = board.top + board.height * (0.28 + i * 0.22);
        canvas.drawLine(
          Offset(board.left + board.width * 0.20, y),
          Offset(board.right - board.width * (i == 2 ? 0.42 : 0.20), y),
          chalk,
        );
      }
      // Patas del caballete.
      final Paint leg = Paint()
        ..color = const Color(0xFF6B4423)
        ..strokeWidth = math.max(1, h * 0.008);
      canvas.drawLine(
        Offset(board.left + board.width * 0.25, board.bottom),
        Offset(board.left + board.width * 0.10, h * 0.955),
        leg,
      );
      canvas.drawLine(
        Offset(board.right - board.width * 0.25, board.bottom),
        Offset(board.right - board.width * 0.10, h * 0.955),
        leg,
      );
    }

    // Planta a la derecha, desde el nivel 4.
    if (level >= 4) {
      final Rect pot = Rect.fromLTWH(
        w * 0.865,
        h * 0.875,
        w * 0.075,
        h * 0.065,
      );
      final Paint leaf = Paint()..color = const Color(0xFF3F7D3A);
      for (int i = 0; i < 5; i++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(pot.center.dx + w * (i - 2) * 0.017, h * 0.845),
            width: w * 0.026,
            height: h * 0.075,
          ),
          leaf,
        );
      }
      canvas.drawRect(pot, Paint()..color = const Color(0xFFB0603A));
      canvas.drawRect(
        Rect.fromLTWH(pot.left, pot.top, pot.width, h * 0.012),
        Paint()..color = const Color(0xFF8E4A2C),
      );
    }

    // La mascota, echada sobre el cajón. Si el jugador eligió una, se ve desde
    // el principio; si no, aparece el gato de la casa recién en el nivel 6.
    final int pet = petId != 0 ? petId : (level >= 6 ? 1 : 0);
    if (pet != 0) {
      _pet(canvas, w, h, crate, pet);
    }
  }

  /// Dibuja la mascota sobre el cajón de fruta.
  ///
  /// Las cuatro comparten el cuerpo echado y cambian cabeza y detalle, que es
  /// lo que a este tamaño alcanza para distinguirlas: orejas puntudas, orejas
  /// caídas, pico, o caparazón.
  void _pet(Canvas canvas, double w, double h, Rect crate, int pet) {
    const List<Color> coats = <Color>[
      Color(0xFF4A3B30), // gato
      Color(0xFFA9713F), // perro
      Color(0xFF17803D), // loro
      Color(0xFF4D7C3A), // tortuga
    ];
    final Paint body = Paint()..color = coats[(pet - 1) % coats.length];
    final double cy = crate.top - h * 0.030;
    final Offset head = Offset(crate.center.dx - w * 0.020, cy - h * 0.008);

    if (pet == 4) {
      // Tortuga: caparazón abombado y cabecita asomando.
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(crate.center.dx + w * 0.010, cy + h * 0.008),
          width: w * 0.095,
          height: h * 0.060,
        ),
        math.pi,
        math.pi,
        true,
        body,
      );
      canvas.drawCircle(head, h * 0.016, body);
      // Placas del caparazón.
      final Paint plate = Paint()
        ..color = const Color(0xFF2F5A22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, h * 0.006);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(crate.center.dx + w * 0.010, cy + h * 0.008),
          width: w * 0.050,
          height: h * 0.032,
        ),
        math.pi,
        math.pi,
        false,
        plate,
      );
      return;
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(crate.center.dx + w * 0.020, cy),
        width: w * 0.085,
        height: h * 0.040,
      ),
      body,
    );
    canvas.drawCircle(head, h * 0.021, body);

    switch (pet) {
      case 2: // Perro: orejas caídas y hocico.
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(head.dx - w * 0.020, head.dy + h * 0.006),
            width: w * 0.018,
            height: h * 0.034,
          ),
          body,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(head.dx + w * 0.020, head.dy + h * 0.006),
            width: w * 0.018,
            height: h * 0.034,
          ),
          body,
        );
        canvas.drawCircle(
          Offset(head.dx - w * 0.012, head.dy + h * 0.010),
          h * 0.010,
          Paint()..color = const Color(0xFF3B2415),
        );
      case 3: // Loro: cresta y pico.
        final Path crest = Path()
          ..moveTo(head.dx - w * 0.006, head.dy - h * 0.018)
          ..lineTo(head.dx + w * 0.004, head.dy - h * 0.042)
          ..lineTo(head.dx + w * 0.012, head.dy - h * 0.016)
          ..close();
        canvas.drawPath(crest, Paint()..color = const Color(0xFFDC2626));
        final Path beak = Path()
          ..moveTo(head.dx - w * 0.018, head.dy)
          ..lineTo(head.dx - w * 0.034, head.dy + h * 0.008)
          ..lineTo(head.dx - w * 0.016, head.dy + h * 0.012)
          ..close();
        canvas.drawPath(beak, Paint()..color = const Color(0xFFF59E0B));
      default: // Gato: orejas puntudas y cola curvada.
        final Path ears = Path()
          ..moveTo(head.dx - w * 0.014, head.dy - h * 0.012)
          ..lineTo(head.dx - w * 0.009, head.dy - h * 0.034)
          ..lineTo(head.dx + w * 0.001, head.dy - h * 0.014)
          ..close()
          ..moveTo(head.dx + w * 0.004, head.dy - h * 0.014)
          ..lineTo(head.dx + w * 0.014, head.dy - h * 0.034)
          ..lineTo(head.dx + w * 0.018, head.dy - h * 0.010)
          ..close();
        canvas.drawPath(ears, body);
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(crate.center.dx + w * 0.062, cy),
            width: w * 0.048,
            height: h * 0.052,
          ),
          -math.pi * 0.6,
          math.pi * 1.2,
          false,
          Paint()
            ..color = coats[0]
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.2, h * 0.011)
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  /// Clientes en la vereda. La cantidad la fija el nivel: un local mejor tiene
  /// más gente, y eso se ve antes de leer ningún número.
  ///
  /// Se dibujan por partes —piernas, torso, brazos, cuello, cabeza, pelo— y no
  /// como una silueta única: a este tamaño una sola figura maciza se lee como
  /// una mancha, y con las partes separadas el ojo reconoce a una persona.
  void _customers(Canvas canvas, double w, double h) {
    const List<Color> shirts = <Color>[
      Color(0xFF2563EB),
      Color(0xFF16A34A),
      Color(0xFFDC2626),
      Color(0xFF7C3AED),
      Color(0xFF0891B2),
      Color(0xFFEA580C),
    ];
    const List<Color> skins = <Color>[
      Color(0xFF8D5524),
      Color(0xFFC68642),
      Color(0xFFE0AC69),
      Color(0xFFA9714B),
    ];
    const List<Color> pants = <Color>[
      Color(0xFF37414F),
      Color(0xFF4A3B2A),
      Color(0xFF2F3A46),
    ];

    final int count = tier.customers.clamp(1, 6);
    // Se reparten en el tramo central de la vereda, que es el único que queda
    // libre entre el cajón de la izquierda y la planta de la derecha.
    final double from = w * 0.36;
    final double to = w * 0.78;
    for (int i = 0; i < count; i++) {
      final double x = count == 1
          ? (from + to) / 2
          : from + (to - from) * i / (count - 1);
      final double feet = h * 0.955;
      final double bodyH = h * 0.135;
      final Color shirt = shirts[i % shirts.length];
      final double headR = h * 0.026;
      final double torsoTop = feet - bodyH * 0.72;
      final double torsoBottom = feet - bodyH * 0.26;
      final double halfW = w * 0.021;

      // Sombra: los apoya en la vereda en vez de dejarlos flotando.
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, feet),
          width: w * 0.062,
          height: h * 0.016,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.22),
      );

      // Piernas.
      final Paint leg = Paint()..color = pants[i % pants.length];
      canvas.drawRect(
        Rect.fromLTWH(
          x - halfW * 0.85,
          torsoBottom,
          halfW * 0.7,
          feet - torsoBottom,
        ),
        leg,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          x + halfW * 0.15,
          torsoBottom,
          halfW * 0.7,
          feet - torsoBottom,
        ),
        leg,
      );

      // Torso.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - halfW, torsoTop, halfW * 2, torsoBottom - torsoTop),
          Radius.circular(halfW * 0.55),
        ),
        Paint()..color = shirt,
      );
      // Brazos, apenas más oscuros que la camisa.
      final Paint arm = Paint()..color = _shade(shirt, 0.82);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - halfW * 1.45,
            torsoTop + (torsoBottom - torsoTop) * 0.12,
            halfW * 0.55,
            (torsoBottom - torsoTop) * 0.78,
          ),
          Radius.circular(halfW * 0.3),
        ),
        arm,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + halfW * 0.9,
            torsoTop + (torsoBottom - torsoTop) * 0.12,
            halfW * 0.55,
            (torsoBottom - torsoTop) * 0.78,
          ),
          Radius.circular(halfW * 0.3),
        ),
        arm,
      );

      // Cuello y cabeza.
      final Color skin = skins[i % skins.length];
      canvas.drawRect(
        Rect.fromLTWH(
          x - halfW * 0.3,
          torsoTop - headR * 0.5,
          halfW * 0.6,
          headR * 0.7,
        ),
        Paint()..color = _shade(skin, 0.9),
      );
      final Offset head = Offset(x, torsoTop - headR * 1.05);
      canvas.drawCircle(head, headR, Paint()..color = skin);
      // Pelo: media luna sobre la cabeza.
      canvas.drawArc(
        Rect.fromCircle(center: head, radius: headR * 1.02),
        math.pi,
        math.pi,
        true,
        Paint()..color = const Color(0xFF2A1C10),
      );

      // Bolsa de compras, desde el nivel 3: la gente sale con algo.
      if (level >= 3 && i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(
            x + halfW * 1.35,
            torsoTop + (torsoBottom - torsoTop) * 0.75,
            halfW * 0.95,
            bodyH * 0.30,
          ),
          Paint()..color = const Color(0xFFE8DCC0),
        );
      }
    }
  }

  /// Luz cálida saliendo del local de noche, y viñeteado de día. Es la capa
  /// que unifica todo lo anterior en una sola escena.
  void _lighting(Canvas canvas, double w, double h) {
    if (dark && level >= 3) {
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.10, h * 0.70)
          ..lineTo(w * 0.90, h * 0.70)
          ..lineTo(w * 1.02, h)
          ..lineTo(w * -0.02, h)
          ..close(),
        Paint()..color = const Color(0xFFF6D98A).withValues(alpha: 0.16),
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(w * 0.5, h * 0.45),
          w * 0.75,
          <Color>[
            Colors.transparent,
            Colors.black.withValues(alpha: dark ? 0.35 : 0.16),
          ],
        ),
    );
  }

  // ------------------------------------------------------------------
  // Utilidades
  // ------------------------------------------------------------------

  /// Cuánto avanzó el local en su escalera, de 0 a 1.
  double get _progress =>
      (level - 1) / math.max(1, ShopTiers.maxLevel - 1).toDouble();

  static Color _shade(Color c, double factor) => Color.fromARGB(
    (c.a * 255).round(),
    (c.r * 255 * factor).clamp(0, 255).round(),
    (c.g * 255 * factor).clamp(0, 255).round(),
    (c.b * 255 * factor).clamp(0, 255).round(),
  );

  void _text(
    Canvas canvas,
    String value,
    Offset center, {
    required double fontSize,
    required Color color,
    bool bold = false,
    double? maxWidth,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? double.infinity);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(StorefrontPainter old) =>
      old.level != level ||
      old.signText != signText ||
      old.awning != awning ||
      old.dark != dark ||
      old.petId != petId;
}
