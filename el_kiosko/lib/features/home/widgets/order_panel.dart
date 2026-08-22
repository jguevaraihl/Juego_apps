import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/board.dart';
import '../../../game/models/order.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/game_strings.dart';
import 'chain_visuals.dart';

/// Los tres pedidos visibles, arriba del tablero.
class OrderPanel extends StatelessWidget {
  const OrderPanel({
    required this.orders,
    required this.board,
    required this.onDeliver,
    required this.onReroll,
    required this.rerollCostOf,
    required this.coins,
    super.key,
  });

  final List<CustomerOrder> orders;
  final Board board;
  final void Function(CustomerOrder order) onDeliver;
  final void Function(CustomerOrder order) onReroll;
  final int Function(CustomerOrder order) rerollCostOf;
  final int coins;

  @override
  Widget build(BuildContext context) {
    // Los tres pedidos tienen que caber en pantalla sin scroll: es un
    // requisito de diseño ("3 pedidos visibles"), y en un teléfono angosto
    // una tarjeta de ancho fijo dejaba la tercera fuera de vista.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 6;
        const double horizontalPadding = 12;
        final int count = orders.length;
        final double available =
            constraints.maxWidth - horizontalPadding * 2 - gap * (count - 1);
        final double cardWidth = count == 0 ? 0 : available / count;

        return SizedBox(
          height: 132,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < count; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: gap),
                  _OrderCard(
                    width: cardWidth,
                    order: orders[i],
                    board: board,
                    onDeliver: () => onDeliver(orders[i]),
                    onReroll: () => onReroll(orders[i]),
                    rerollCost: rerollCostOf(orders[i]),
                    coins: coins,
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
    required this.onReroll,
    required this.rerollCost,
    required this.coins,
  });

  final double width;
  final CustomerOrder order;
  final Board board;
  final VoidCallback onDeliver;
  final VoidCallback onReroll;
  final int rerollCost;
  final int coins;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool ready = order.isSatisfiedBy(board);
    final String customer = l.customerName(order.customerId);

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
          color: AppTheme.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ready
                ? AppTheme.success
                : AppTheme.wood.withValues(alpha: 0.25),
            width: ready ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (order.isSpecial)
                  const Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: Icon(Icons.star, size: 12, color: AppTheme.awning),
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
              ],
            ),
            const SizedBox(height: 4),
            for (final OrderLine line in order.lines)
              _LineRow(line: line, board: board),
            const Spacer(),
            Row(
              children: <Widget>[
                const Icon(Icons.payments, size: 13, color: AppTheme.coin),
                const SizedBox(width: 2),
                Text(
                  '${order.reward}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppTheme.coin,
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
                            ? AppTheme.inkSoft
                            : AppTheme.inkSoft.withValues(alpha: 0.35),
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
                onPressed: ready ? onDeliver : null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 34),
                  backgroundColor: AppTheme.success,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(ready ? l.deliver : l.missing),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.board});

  final OrderLine line;
  final Board board;

  @override
  Widget build(BuildContext context) {
    final ChainVisual visual = ChainVisuals.of(line.chainId);
    final int have = line.quantity == 0
        ? 0
        : board.countOf(line.chainId, line.level);
    final bool complete = have >= line.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: <Widget>[
          Icon(visual.icon, size: 13, color: visual.color),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              AppLocalizations.of(context).lineName(line),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppTheme.ink),
            ),
          ),
          Text(
            '${have.clamp(0, line.quantity)}/${line.quantity}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: complete ? AppTheme.success : AppTheme.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
