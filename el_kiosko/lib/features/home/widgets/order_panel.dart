import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/board.dart';
import '../../../game/models/order.dart';
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
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: orders.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int i) {
          final CustomerOrder order = orders[i];
          return _OrderCard(
            order: order,
            board: board,
            onDeliver: () => onDeliver(order),
            onReroll: () => onReroll(order),
            rerollCost: rerollCostOf(order),
            coins: coins,
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.board,
    required this.onDeliver,
    required this.onReroll,
    required this.rerollCost,
    required this.coins,
  });

  final CustomerOrder order;
  final Board board;
  final VoidCallback onDeliver;
  final VoidCallback onReroll;
  final int rerollCost;
  final int coins;

  @override
  Widget build(BuildContext context) {
    final bool ready = order.isSatisfiedBy(board);

    return Semantics(
      label:
          'Pedido de ${order.customerName}. '
          '${ready ? 'Listo para entregar' : 'Faltan productos'}. '
          'Paga ${order.reward} pesos.',
      button: true,
      child: Container(
        width: 176,
        padding: const EdgeInsets.all(10),
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
                    padding: EdgeInsets.only(right: 3),
                    child: Icon(Icons.star, size: 14, color: AppTheme.awning),
                  ),
                Expanded(
                  child: Text(
                    order.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
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
                const Icon(Icons.payments, size: 14, color: AppTheme.coin),
                const SizedBox(width: 3),
                Text(
                  '${order.reward}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.coin,
                  ),
                ),
                const Spacer(),
                // Cambiar el pedido cuesta monedas: es una decisión, no un
                // botón gratis de saltar contenido.
                Tooltip(
                  message: 'Cambiar pedido por $rerollCost',
                  child: InkWell(
                    onTap: coins >= rerollCost ? onReroll : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.autorenew,
                        size: 18,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(ready ? 'Entregar' : 'Falta'),
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
          Icon(visual.icon, size: 15, color: visual.color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              line.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppTheme.ink),
            ),
          ),
          Text(
            '${have.clamp(0, line.quantity)}/${line.quantity}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: complete ? AppTheme.success : AppTheme.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
