import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import 'customer_avatar.dart';
import 'mini_item.dart';

/// El momento de entregar: el cliente se acerca al mesón, recibe lo suyo y da
/// las gracias.
///
/// Es el remate del bucle. Antes, entregar un pedido era un número que subía y
/// una tarjeta que se reemplazaba: correcto, y completamente frío. Acá se ve a
/// quién le vendiste y qué se llevó, que es lo que convierte una operación
/// aritmética en atender el almacén.
///
/// Dura poco y no bloquea: aparece encima, no interrumpe, y el jugador puede
/// seguir jugando por debajo.
class DeliveryCheer extends StatelessWidget {
  const DeliveryCheer({
    required this.customerId,
    required this.reward,
    required this.items,
    required this.onDone,
    this.animate = true,
    super.key,
  });

  final int customerId;
  final int reward;

  /// Lo que se llevó, para mostrarlo en la bolsa.
  final List<({String chainId, int level})> items;

  final VoidCallback onDone;
  final bool animate;

  static const Duration duration = Duration(milliseconds: 1500);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: animate ? duration : const Duration(milliseconds: 1),
        curve: Curves.easeOut,
        onEnd: onDone,
        builder: (BuildContext context, double t, Widget? child) {
          // Entra desde el costado —el cliente llega al mesón—, se queda a
          // plena vista, y se va.
          final double appear = (t / 0.18).clamp(0.0, 1.0);
          final double leave = ((t - 0.75) / 0.25).clamp(0.0, 1.0);
          final double slide = animate ? (1 - appear) * 40 - leave * 24 : 0;

          return Opacity(
            opacity: (appear * (1 - leave)).clamp(0.0, 1.0),
            child: Transform.translate(offset: Offset(slide, 0), child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
          decoration: BoxDecoration(
            color: context.palette.paper,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.palette.success, width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomerAvatar(customerId: customerId, size: 42),
              const SizedBox(width: 9),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l.deliveryThanks,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: context.palette.woodDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // La bolsa: lo que se llevó, hasta tres piezas.
                      for (final ({String chainId, int level}) item
                          in items.take(3))
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: MiniItem(
                            chainId: item.chainId,
                            level: item.level,
                            size: 22,
                          ),
                        ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.payments,
                        size: 15,
                        color: context.palette.coin,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '+$reward',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: context.palette.coin,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
