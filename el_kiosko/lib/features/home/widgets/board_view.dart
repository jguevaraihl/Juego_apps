import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/board.dart';
import '../../../game/models/board_item.dart';
import '../../../l10n/app_localizations.dart';
import 'item_tile.dart';

/// El tablero. Arrastrar y soltar sobre cualquier casilla; no hay adyacencia.
///
/// El tamaño de celda se calcula para que el tablero completo quepa siempre en
/// pantalla: en un teléfono angosto se encoge en vez de hacer scroll, así el
/// jugador nunca pierde de vista los pedidos ni el botón del proveedor.
///
/// **El destino se decide por dónde está la ficha, no por dónde está el dedo.**
/// La ficha levantada se dibuja por encima del dedo —si no, la tapa la mano y
/// el jugador no ve qué está moviendo—, pero Flutter enruta el soltar según la
/// posición del puntero. Eso hacía que lo que se veía y lo que ocurría fueran
/// dos cosas distintas: quien apunta mirando la ficha soltaba una fila más
/// abajo. Por eso el tablero entero es **un solo** `DragTarget` que calcula la
/// casilla desde la posición corregida, en vez de un `DragTarget` por casilla.
///
/// Como efecto secundario, soltar en el espacio entre dos casillas ya no se
/// pierde: se toma la más cercana.
class BoardView extends StatefulWidget {
  const BoardView({
    required this.board,
    required this.onDrop,
    required this.onTapItem,
    required this.onTapLocked,
    this.onPickUp,
    this.hint,
    this.sellMode = false,
    this.sellValueOf,
    super.key,
  });

  final Board board;

  /// (origen, destino) en índices de casilla.
  final void Function(int from, int to) onDrop;

  /// Toque simple sobre una ficha.
  ///
  /// Es un toque y no un long press a propósito: mantener presionado compite
  /// con el arrastre —quien duda un momento antes de arrastrar terminaría
  /// abriendo un menú— y además es mucho menos descubrible. El toque sólo se
  /// confunde con el arrastre si el gesto es más corto que el umbral del
  /// sistema, y con celdas de ~50 px eso no pasa.
  final void Function(int index) onTapItem;

  /// Se llama al empezar a arrastrar una ficha.
  final VoidCallback? onPickUp;

  /// Se llama al tocar una casilla de una fila todavía bloqueada.
  final VoidCallback onTapLocked;

  /// Par sugerido cuando el jugador lleva rato sin jugar.
  final (int, int)? hint;

  final bool sellMode;
  final int Function(BoardItem item)? sellValueOf;

  /// Cuánto se levanta la ficha por encima del dedo, en fracción de celda.
  ///
  /// Es la misma constante para el dibujo y para la corrección del destino:
  /// si se separaran, volvería el problema que este archivo viene a resolver.
  static const double liftFraction = 0.42;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  /// Casilla sobre la que caería la ficha ahora mismo, o null si no hay
  /// arrastre en curso.
  int? _hovered;

  /// Para convertir la posición global del arrastre en coordenadas de grilla.
  final GlobalKey _gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final Board board = widget.board;
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

        final double boardHeight = cell * board.rows + gap * (board.rows - 1);

        /// De la posición global del dedo a la casilla que el jugador está
        /// mirando: se sube [BoardView.liftFraction] de celda —lo mismo que
        /// se levanta el dibujo— y se toma la casilla más cercana.
        int? cellAt(Offset globalPosition) {
          final RenderBox? box =
              _gridKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return null;
          final Offset local = box.globalToLocal(globalPosition);
          final double corrected = local.dy - cell * BoardView.liftFraction;

          // round() en vez de floor(): el espacio entre dos casillas cae en la
          // más cercana en vez de perderse.
          final int col = ((local.dx - cell / 2) / (cell + gap)).round().clamp(
            0,
            board.columns - 1,
          );
          final int row = ((corrected - cell / 2) / (cell + gap)).round().clamp(
            0,
            board.rows - 1,
          );
          final int index = board.indexOf(col, row);
          return board.isLocked(index) ? null : index;
        }

        void updateHover(Offset globalPosition) {
          final int? next = cellAt(globalPosition);
          if (next != _hovered) setState(() => _hovered = next);
        }

        return Center(
          child: DragTarget<int>(
            onWillAcceptWithDetails: (DragTargetDetails<int> details) {
              updateHover(details.offset + Offset(cell / 2, cell / 2));
              return true;
            },
            onMove: (DragTargetDetails<int> details) =>
                updateHover(details.offset + Offset(cell / 2, cell / 2)),
            onLeave: (int? data) {
              if (_hovered != null) setState(() => _hovered = null);
            },
            onAcceptWithDetails: (DragTargetDetails<int> details) {
              final int? target = cellAt(
                details.offset + Offset(cell / 2, cell / 2),
              );
              setState(() => _hovered = null);
              if (target != null && target != details.data) {
                widget.onDrop(details.data, target);
              }
            },
            builder:
                (
                  BuildContext context,
                  List<int?> candidates,
                  List<dynamic> rejected,
                ) {
                  final int? dragged = candidates.isEmpty
                      ? null
                      : candidates.first;
                  return SizedBox(
                    key: _gridKey,
                    width: boardWidth,
                    height: boardHeight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (int row = 0; row < board.rows; row++) ...<Widget>[
                          if (row > 0) const SizedBox(height: gap),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              for (
                                int col = 0;
                                col < board.columns;
                                col++
                              ) ...<Widget>[
                                if (col > 0) const SizedBox(width: gap),
                                _Cell(
                                  index: board.indexOf(col, row),
                                  board: board,
                                  size: cell,
                                  draggedFrom: dragged,
                                  hovered: _hovered == board.indexOf(col, row),
                                  onTapItem: widget.onTapItem,
                                  onPickUp: widget.onPickUp,
                                  onTapLocked: widget.onTapLocked,
                                  hint: widget.hint,
                                  sellMode: widget.sellMode,
                                  sellValueOf: widget.sellValueOf,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
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
    required this.draggedFrom,
    required this.hovered,
    required this.onTapItem,
    required this.onPickUp,
    required this.onTapLocked,
    required this.hint,
    required this.sellMode,
    required this.sellValueOf,
  });

  final int index;
  final Board board;
  final double size;

  /// Desde qué casilla se está arrastrando, o null si no hay arrastre.
  final int? draggedFrom;

  /// Si la ficha caería acá. Lo decide el tablero, no la casilla: el destino
  /// se calcula desde dónde se ve la ficha y no desde dónde está el dedo.
  final bool hovered;

  /// Toque simple sobre una ficha.
  ///
  /// Es un toque y no un long press a propósito: mantener presionado compite
  /// con el arrastre —quien duda un momento antes de arrastrar terminaría
  /// abriendo un menú— y además es mucho menos descubrible. El toque sólo se
  /// confunde con el arrastre si el gesto es más corto que el umbral del
  /// sistema, y con celdas de ~50 px eso no pasa.
  final void Function(int index) onTapItem;

  /// Se llama al empezar a arrastrar una ficha.
  final VoidCallback? onPickUp;

  /// Se llama al tocar una casilla de una fila todavía bloqueada.
  final VoidCallback onTapLocked;
  final (int, int)? hint;
  final bool sellMode;
  final int Function(BoardItem item)? sellValueOf;

  @override
  Widget build(BuildContext context) {
    // Las filas todavía no compradas se muestran atenuadas y con candado:
    // el jugador ve hasta dónde puede crecer el mesón.
    if (board.isLocked(index)) {
      return Semantics(
        button: true,
        label: AppLocalizations.of(context).lockedRow,
        child: GestureDetector(
          onTap: onTapLocked,
          child: _Slot(size: size, hovered: false, locked: true),
        ),
      );
    }

    final BoardItem? item = board.at(index);
    final bool hinted =
        hint != null && (hint!.$1 == index || hint!.$2 == index);

    // Qué pasaría si soltara acá. Saberlo ANTES de soltar es lo que convierte
    // el arrastre en una jugada y no en una apuesta.
    final DropOutcome outcome =
        (!hovered || draggedFrom == null || draggedFrom == index)
        ? DropOutcome.none
        : _outcomeForItems(board.at(draggedFrom!), item);

    final Widget slot = _Slot(
      size: size,
      hovered: hovered && draggedFrom != index,
      outcome: outcome,
      child: item == null
          ? null
          : ItemTile(
              item: item,
              size: size,
              highlighted: hinted,
              dimmed: outcome == DropOutcome.swap,
              sellValue: sellMode ? sellValueOf?.call(item) : null,
            ),
    );

    final Widget cell = outcome == DropOutcome.none
        ? slot
        : Stack(
            alignment: Alignment.center,
            children: <Widget>[
              slot,
              // El símbolo acompaña al color: sin él, "verde o rojo" no le
              // dice nada a quien no los distingue.
              Icon(
                outcome == DropOutcome.merge
                    ? Icons.check_circle
                    : Icons.swap_horiz,
                size: size * 0.46,
                color: outcome == DropOutcome.merge
                    ? context.palette.success
                    : const Color(0xFFDC2626),
                shadows: const <Shadow>[
                  Shadow(color: Colors.white70, blurRadius: 4),
                ],
              ),
            ],
          );

    if (item == null) return cell;

    return GestureDetector(
      onTap: () => onTapItem(index),
      child: Draggable<int>(
        data: index,
        onDragStarted: onPickUp,
        // La ficha levantada crece y se corre hacia arriba para asomar por
        // encima del dedo. El tablero corrige el destino con la misma
        // fracción, así que lo que se ve es lo que ocurre.
        feedback: Material(
          color: Colors.transparent,
          child: Transform.translate(
            offset: Offset(0, -size * BoardView.liftFraction),
            child: Transform.scale(
              scale: 1.35,
              child: ItemTile(item: item, size: size),
            ),
          ),
        ),
        childWhenDragging: _Slot(size: size, hovered: false),
        child: cell,
      ),
    );
  }
}

/// Qué pasaría si el jugador soltara la ficha acá.
enum DropOutcome {
  /// No hay nada encima.
  none,

  /// Las dos piezas se fusionan: la jugada que el jugador busca.
  merge,

  /// Las piezas se intercambian de lugar. No se pierde nada, pero tampoco es
  /// lo que se quería: por eso se marca distinto y no como error.
  swap,
}

/// Qué pasaría al soltar la ficha de [fromIndex] sobre [target].
///
/// Se decide con la misma regla que aplica el motor —iguales y no tope se
/// fusionan, el resto se intercambia—, para que lo que se ve prometido sea
/// exactamente lo que ocurre.
DropOutcome _outcomeForItems(BoardItem? dragged, BoardItem? target) {
  if (dragged == null) return DropOutcome.none;
  if (target == null) return DropOutcome.merge;
  final bool merges =
      dragged.chainId == target.chainId &&
      dragged.level == target.level &&
      !target.isMaxLevel;
  return merges ? DropOutcome.merge : DropOutcome.swap;
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.size,
    required this.hovered,
    this.outcome = DropOutcome.none,
    this.locked = false,
    this.child,
  });

  final double size;
  final bool hovered;

  /// Sólo importa mientras hay una ficha encima.
  final DropOutcome outcome;

  final bool locked;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: locked
            ? context.palette.wood.withValues(alpha: 0.03)
            : (hovered
                  ? _accent(context).withValues(alpha: 0.20)
                  : context.palette.wood.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: locked
              ? context.palette.wood.withValues(alpha: 0.10)
              : (hovered
                    ? _accent(context)
                    : context.palette.wood.withValues(alpha: 0.16)),
          width: hovered ? 3 : 1,
        ),
      ),
      child: locked
          ? Center(
              child: Icon(
                Icons.lock_outline,
                size: size * 0.34,
                color: context.palette.wood.withValues(alpha: 0.28),
              ),
            )
          : child,
    );
  }

  /// Verde si se fusiona, rojo si sólo se intercambia.
  ///
  /// El color no viaja solo: la casilla que fusiona además muestra un visto y
  /// la que intercambia, dos flechas. Quien no distingue verde de rojo lee el
  /// símbolo, que es la misma regla que rige el resto del juego.
  Color _accent(BuildContext context) => switch (outcome) {
    DropOutcome.merge => context.palette.success,
    DropOutcome.swap => const Color(0xFFDC2626),
    DropOutcome.none => context.palette.awning,
  };
}
