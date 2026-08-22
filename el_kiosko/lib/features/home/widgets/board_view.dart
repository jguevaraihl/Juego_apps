import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/board.dart';
import '../../../game/models/board_item.dart';
import 'item_tile.dart';

/// El tablero. Arrastrar y soltar sobre cualquier casilla; no hay adyacencia.
///
/// El tamaño de celda se calcula para que el tablero completo quepa siempre en
/// pantalla: en un teléfono angosto se encoge en vez de hacer scroll, así el
/// jugador nunca pierde de vista los pedidos ni el botón del proveedor.
class BoardView extends StatelessWidget {
  const BoardView({
    required this.board,
    required this.onDrop,
    required this.onTapItem,
    this.onPickUp,
    this.hint,
    this.sellMode = false,
    this.sellValueOf,
    super.key,
  });

  final Board board;

  /// (origen, destino) en índices de casilla.
  final void Function(int from, int to) onDrop;
  final void Function(int index) onTapItem;

  /// Se llama al empezar a arrastrar una ficha.
  final VoidCallback? onPickUp;

  /// Par sugerido cuando el jugador lleva rato sin jugar.
  final (int, int)? hint;

  final bool sellMode;
  final int Function(BoardItem item)? sellValueOf;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 4;
        final double cellFromWidth =
            (constraints.maxWidth - gap * (board.columns - 1)) / board.columns;
        final double cellFromHeight =
            (constraints.maxHeight - gap * (board.rows - 1)) / board.rows;
        final double cell = cellFromWidth < cellFromHeight
            ? cellFromWidth
            : cellFromHeight;
        final double boardWidth =
            cell * board.columns + gap * (board.columns - 1);

        return Center(
          child: SizedBox(
            width: boardWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int row = 0; row < board.rows; row++) ...<Widget>[
                  if (row > 0) const SizedBox(height: gap),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int col = 0; col < board.columns; col++) ...<Widget>[
                        if (col > 0) const SizedBox(width: gap),
                        _Cell(
                          index: board.indexOf(col, row),
                          board: board,
                          size: cell,
                          onDrop: onDrop,
                          onTapItem: onTapItem,
                          onPickUp: onPickUp,
                          hint: hint,
                          sellMode: sellMode,
                          sellValueOf: sellValueOf,
                        ),
                      ],
                    ],
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

class _Cell extends StatelessWidget {
  const _Cell({
    required this.index,
    required this.board,
    required this.size,
    required this.onDrop,
    required this.onTapItem,
    required this.onPickUp,
    required this.hint,
    required this.sellMode,
    required this.sellValueOf,
  });

  final int index;
  final Board board;
  final double size;
  final void Function(int from, int to) onDrop;
  final void Function(int index) onTapItem;

  /// Se llama al empezar a arrastrar una ficha.
  final VoidCallback? onPickUp;
  final (int, int)? hint;
  final bool sellMode;
  final int Function(BoardItem item)? sellValueOf;

  @override
  Widget build(BuildContext context) {
    final BoardItem? item = board.at(index);
    final bool hinted =
        hint != null && (hint!.$1 == index || hint!.$2 == index);

    return DragTarget<int>(
      onWillAcceptWithDetails: (DragTargetDetails<int> details) =>
          details.data != index,
      onAcceptWithDetails: (DragTargetDetails<int> details) =>
          onDrop(details.data, index),
      builder:
          (
            BuildContext context,
            List<int?> candidates,
            List<dynamic> rejected,
          ) {
            final bool hovered = candidates.isNotEmpty;
            final Widget slot = _Slot(
              size: size,
              hovered: hovered,
              child: item == null
                  ? null
                  : ItemTile(
                      item: item,
                      size: size,
                      highlighted: hinted,
                      sellValue: sellMode ? sellValueOf?.call(item) : null,
                    ),
            );

            if (item == null) return slot;

            return GestureDetector(
              onTap: () => onTapItem(index),
              child: Draggable<int>(
                data: index,
                onDragStarted: onPickUp,
                // En gama baja el feedback flotante se mantiene simple.
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: 1.12,
                    child: ItemTile(item: item, size: size),
                  ),
                ),
                childWhenDragging: _Slot(size: size, hovered: false),
                child: slot,
              ),
            );
          },
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.size, required this.hovered, this.child});

  final double size;
  final bool hovered;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hovered
            ? AppTheme.awning.withValues(alpha: 0.18)
            : AppTheme.wood.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: hovered
              ? AppTheme.awning
              : AppTheme.wood.withValues(alpha: 0.16),
          width: hovered ? 2 : 1,
        ),
      ),
      child: child,
    );
  }
}
