import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/board.dart';
import '../../../game/models/order.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/game_strings.dart';
import 'customer_avatar.dart';
import 'mini_item.dart';

/// Los tres pedidos visibles, arriba del tablero.
class OrderPanel extends StatelessWidget {
  const OrderPanel({
    required this.orders,
    required this.board,
    required this.onDeliver,
    required this.onDeliverPartial,
    required this.onReroll,
    required this.partialUnlocked,
    required this.rerollCostOf,
    required this.coins,
    required this.now,
    super.key,
  });

  final List<CustomerOrder> orders;
  final Board board;
  final void Function(CustomerOrder order) onDeliver;
  final void Function(CustomerOrder order) onDeliverPartial;
  final void Function(CustomerOrder order) onReroll;

  /// La entrega parcial se desbloquea recién en niveles altos.
  final bool partialUnlocked;
  final int Function(CustomerOrder order) rerollCostOf;
  final int coins;

  /// Hora actual, para el contador de la bonificación por rapidez. Entra desde
  /// fuera para que el widget siga siendo puro y testeable.
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    // Los tres pedidos tienen que caber en pantalla sin scroll: es un
    // requisito de diseño ("3 pedidos visibles"), y en un teléfono angosto
    // una tarjeta de ancho fijo dejaba la tercera fuera de vista.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 6;
        const double horizontalPadding = 12;
        // El mayorista no entra en la fila: tiene su propia banda arriba. Si
        // compartiera el espacio, las cuatro tarjetas quedarían tan angostas
        // que no se leería ninguna.
        final List<CustomerOrder> normal = orders
            .where((CustomerOrder o) => !o.isBig)
            .toList(growable: false);
        final int count = normal.length;
        final double available =
            constraints.maxWidth - horizontalPadding * 2 - gap * (count - 1);
        final double cardWidth = count == 0 ? 0 : available / count;

        return SizedBox(
          // Subió con la ficha en miniatura de cada línea: mostrar el producto
          // que hay que juntar vale los pocos píxeles que cuesta.
          height: 146,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < count; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: gap),
                  _OrderCard(
                    width: cardWidth,
                    order: normal[i],
                    board: board,
                    onDeliver: () => onDeliver(normal[i]),
                    onDeliverPartial: () => onDeliverPartial(normal[i]),
                    partialUnlocked: partialUnlocked,
                    onReroll: () => onReroll(normal[i]),
                    rerollCost: rerollCostOf(normal[i]),
                    coins: coins,
                    now: now,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.width,
    required this.order,
    required this.board,
    required this.onDeliver,
    required this.onDeliverPartial,
    required this.partialUnlocked,
    required this.onReroll,
    required this.rerollCost,
    required this.coins,
    required this.now,
  });

  final double width;
  final CustomerOrder order;
  final Board board;
  final VoidCallback onDeliver;
  final VoidCallback onDeliverPartial;
  final bool partialUnlocked;
  final VoidCallback onReroll;
  final int rerollCost;
  final int coins;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool ready = order.isSatisfiedBy(board);
    final String customer = l.customerName(order.customerId);
    final Duration? bonusLeft = order.bonusRemainingAt(now);
    // Con el pedido a medias, el botón cambia de significado en vez de sumar
    // otro control: en una tarjeta de ~118 px no cabe un segundo botón.
    final double coverage = order.coverageIn(board);
    final bool canPartial = !ready && partialUnlocked && coverage > 0;

    return Semantics(
      label: l.orderSemantics(
        customer,
        ready ? l.orderReady : l.orderNotReady,
        order.reward,
      ),
      button: true,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: context.palette.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ready
                ? context.palette.success
                : context.palette.wood.withValues(alpha: 0.25),
            width: ready ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                // La cara del cliente: un pedido es alguien esperando en el
                // mesón, no una fila de una planilla.
                CustomerAvatar(customerId: order.customerId, size: 24),
                const SizedBox(width: 4),
                if (order.isSpecial)
                  Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: Icon(
                      Icons.star,
                      size: 12,
                      color: context.palette.awning,
                    ),
                  ),
                Expanded(
                  child: Text(
                    customer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontSize: 12),
                  ),
                ),
                // Mientras corre la ventana se muestra cuánto queda. El pedido
                // NO caduca: pasado el tiempo sólo desaparece el contador.
                if (bonusLeft != null)
                  Tooltip(
                    message: l.timeBonusTooltip(_mmss(bonusLeft)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.bolt,
                          size: 11,
                          color: context.palette.awning,
                        ),
                        Text(
                          _mmss(bonusLeft),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: context.palette.awning,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (final OrderLine line in order.lines)
              _LineRow(line: line, board: board),
            const Spacer(),
            Row(
              children: <Widget>[
                Icon(Icons.payments, size: 13, color: context.palette.coin),
                const SizedBox(width: 2),
                Text(
                  '${order.reward}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: context.palette.coin,
                  ),
                ),
                const Spacer(),
                // Cambiar el pedido cuesta monedas: es una decisión, no un
                // botón gratis de saltar contenido.
                Tooltip(
                  message: l.rerollTooltip(rerollCost),
                  child: InkWell(
                    onTap: coins >= rerollCost ? onReroll : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        Icons.autorenew,
                        size: 17,
                        color: coins >= rerollCost
                            ? context.palette.inkSoft
                            : context.palette.inkSoft.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: FilledButton(
                onPressed: ready
                    ? onDeliver
                    : (canPartial ? onDeliverPartial : null),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 34),
                  backgroundColor: ready
                      ? context.palette.success
                      : context.palette.awning,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(
                  ready
                      ? l.deliver
                      : (canPartial ? l.deliverPartial : l.missing),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _mmss(Duration d) {
  final int minutes = d.inMinutes;
  final int seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.board});

  final OrderLine line;
  final Board board;

  @override
  Widget build(BuildContext context) {
    final int have = line.quantity == 0
        ? 0
        : board.countOf(line.chainId, line.level);
    final bool complete = have >= line.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: <Widget>[
          // La misma ficha que hay que juntar, en chico: color, ícono y nivel.
          // Reconocerla de un vistazo es lo que evita tener que leer el pedido
          // y traducirlo mentalmente a una casilla del tablero.
          MiniItem(
            chainId: line.chainId,
            level: line.level,
            size: 26,
            faded: !complete,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              AppLocalizations.of(context).lineName(line),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.15,
                color: context.palette.ink,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '${have.clamp(0, line.quantity)}/${line.quantity}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: complete
                  ? context.palette.success
                  : context.palette.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
