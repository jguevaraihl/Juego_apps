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

        // **Sin alto fijo.** Antes eran 146 px escritos a mano, y un pedido de
        // dos líneas necesitaba 155: se desbordaba nueve píxeles y empujaba el
        // botón de entregar fuera de su sitio, justo el que hay que apretar.
        // Con el tamaño de texto subido en Ajustes era peor. `IntrinsicHeight`
        // le da a las tres tarjetas el alto de la más alta y crece si hace
        // falta, así que el desborde no puede volver.
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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

    final Widget card = Semantics(
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
            // **El nombre del cliente ya no se escribe.** La cara dice que hay
            // alguien esperando, que es lo que se quería —un pedido no es una
            // fila de una planilla—, pero el nombre no se podía usar para
            // nada: no cambiaba ninguna decisión y ocupaba la fila entera. Se
            // conserva en la etiqueta de accesibilidad, donde sí sirve.
            Row(
              children: <Widget>[
                CustomerAvatar(customerId: order.customerId, size: 24),
                // Todo lo demás de esta fila va dentro de un FittedBox: la
                // tarjeta mide poco más de cien píxeles en un teléfono
                // angosto, y con el tamaño de texto subido en Ajustes el
                // cronómetro y la recompensa juntos no caben. Encogerse es
                // preferible a desbordarse, que es lo que pasaba antes.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (order.isSpecial)
                          Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Icon(
                              Icons.star,
                              size: 13,
                              color: context.palette.awning,
                            ),
                          ),
                        // Mientras corre la ventana se muestra cuánto queda.
                        // El pedido NO caduca: pasado el tiempo sólo
                        // desaparece el contador.
                        if (bonusLeft != null) ...<Widget>[
                          Icon(
                            Icons.bolt,
                            size: 12,
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
                          const SizedBox(width: 6),
                        ],
                        Icon(
                          Icons.payments,
                          size: 13,
                          color: context.palette.coin,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${order.reward}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: context.palette.coin,
                          ),
                        ),
                        // Hueco para el botón de cambiar, que flota encima.
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Lo que pide, en grande y sin nombres escritos. La ficha ya dice
            // qué es —mismo color, mismo ícono, mismo número que en el
            // tablero— y el nombre al lado era la línea de texto que más
            // ocupaba y menos aportaba: había que leerla y traducirla a una
            // casilla, que es justo el trabajo que la ficha evita.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final OrderLine line in order.lines)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _LineChip(line: line, board: board),
                    ),
                ],
              ),
            ),
            const Spacer(),
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

    // Cambiar el pedido cuesta monedas: es una decisión, no un botón gratis
    // de saltar contenido. Va flotando en la esquina para no gastar una fila
    // entera de una tarjeta de ~110 px.
    return Stack(
      children: <Widget>[
        card,
        Positioned(
          top: 2,
          right: 2,
          child: Tooltip(
            message: l.rerollTooltip(rerollCost),
            child: InkWell(
              onTap: coins >= rerollCost ? onReroll : null,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.autorenew,
                  size: 15,
                  color: coins >= rerollCost
                      ? context.palette.inkSoft.withValues(alpha: 0.75)
                      : context.palette.inkSoft.withValues(alpha: 0.28),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _mmss(Duration d) {
  final int minutes = d.inMinutes;
  final int seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Una de las cosas que pide el pedido: la ficha grande, con cuánto llevas.
///
/// El contador va **encima de la ficha** y no en una columna aparte, para que
/// se lea como una sola cosa —"de estas necesito 3 y tengo 2"— en vez de como
/// dos datos que hay que juntar con la vista.
class _LineChip extends StatelessWidget {
  const _LineChip({required this.line, required this.board});

  final OrderLine line;
  final Board board;

  @override
  Widget build(BuildContext context) {
    final int have = line.quantity == 0
        ? 0
        : board.countOf(line.chainId, line.level);
    final bool complete = have >= line.quantity;
    final Color badge = complete
        ? context.palette.success
        : context.palette.wood;

    return Semantics(
      label:
          '${AppLocalizations.of(context).lineName(line)} '
          '${have.clamp(0, line.quantity)} de ${line.quantity}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MiniItem(
            chainId: line.chainId,
            level: line.level,
            size: 40,
            faded: !complete,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: badge,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '${have.clamp(0, line.quantity)}/${line.quantity}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
