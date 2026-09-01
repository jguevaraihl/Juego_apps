import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/board.dart';
import '../../../game/models/order.dart';
import '../../../l10n/app_localizations.dart';
import 'customer_avatar.dart';
import 'mini_item.dart';

/// El pedido mayorista, en una banda propia sobre los tres pedidos normales.
///
/// Tiene su propio espacio y no un cupo de la fila porque es un evento: si
/// fuera una cuarta tarjeta angosta se leería como "un pedido más", que es
/// justo lo contrario de lo que es. La banda ocupa el ancho completo, lleva
/// cuenta regresiva y se pinta con el color de urgencia del juego.
///
/// **Es el único pedido que caduca**, y perderlo no quita nada: el jugador
/// sigue con lo que tenía. Es una oportunidad extra, nunca un castigo por no
/// haber estado mirando.
class BigOrderBanner extends StatelessWidget {
  const BigOrderBanner({
    required this.order,
    required this.board,
    required this.now,
    required this.onDeliver,
    super.key,
  });

  final CustomerOrder order;
  final Board board;
  final DateTime now;
  final VoidCallback onDeliver;

  static String _mmss(Duration d) {
    final int m = d.inMinutes;
    final int s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool ready = order.isSatisfiedBy(board);
    final Duration? left = order.lifeRemainingAt(now);
    // Bajo el minuto la cuenta se pone roja: es el único momento del juego en
    // que el tiempo importa de verdad.
    final bool urgent = left != null && left.inSeconds <= 60;
    final Color accent = urgent
        ? const Color(0xFFDC2626)
        : context.palette.awning;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.fromLTRB(8, 7, 10, 7),
      decoration: BoxDecoration(
        color: context.palette.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          CustomerAvatar(customerId: order.customerId, size: 38),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        l.bigOrderBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (left != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.timer_outlined, size: 13, color: accent),
                          const SizedBox(width: 2),
                          Text(
                            _mmss(left),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    const Spacer(),
                    Icon(Icons.payments, size: 14, color: context.palette.coin),
                    const SizedBox(width: 2),
                    Text(
                      '${order.reward}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: context.palette.coin,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Todo lo que pide, en una fila: es mucho, y verlo junto es
                // parte de entender por qué paga tanto.
                Row(
                  children: <Widget>[
                    for (final OrderLine line in order.lines)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            MiniItem(
                              chainId: line.chainId,
                              level: line.level,
                              size: 24,
                              faded:
                                  board.countOf(line.chainId, line.level) <
                                  line.quantity,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${order.progressFor(line, board)}'
                              '/${line.quantity}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color:
                                    board.countOf(line.chainId, line.level) >=
                                        line.quantity
                                    ? context.palette.success
                                    : context.palette.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            height: AppTheme.minTouchTarget,
            child: FilledButton(
              onPressed: ready ? onDeliver : null,
              style: FilledButton.styleFrom(
                backgroundColor: context.palette.success,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Text(ready ? l.deliver : l.missing),
            ),
          ),
        ],
      ),
    );
  }
}
