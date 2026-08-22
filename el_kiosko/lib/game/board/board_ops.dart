import '../models/board.dart';
import '../models/board_item.dart';
import '../models/order.dart';

/// Qué ocurrió al soltar una pieza sobre otra casilla.
enum DropKind {
  /// Se fusionaron dos objetos iguales.
  merge,

  /// Se movió a una casilla vacía.
  move,

  /// Se intercambiaron dos objetos que no se podían fusionar.
  swap,

  /// No pasó nada (misma casilla, índices inválidos, origen vacío).
  none,
}

class DropResult {
  const DropResult({
    required this.kind,
    required this.board,
    required this.nextItemId,
    this.mergedItem,
  });

  final DropKind kind;
  final Board board;
  final int nextItemId;

  /// El objeto resultante cuando [kind] es [DropKind.merge].
  final BoardItem? mergedItem;

  bool get changed => kind != DropKind.none;
}

/// Operaciones puras sobre el tablero. Sin estado, sin Flutter, sin azar.
class BoardOps {
  const BoardOps._();

  /// Suelta la pieza de [from] sobre [to].
  ///
  /// Reglas (PLAN_FINAL §3.2):
  /// - casilla vacía  → mover;
  /// - mismo producto y mismo nivel, no máximo → fusionar;
  /// - cualquier otro caso → intercambiar, para que el jugador pueda ordenar
  ///   el tablero y nunca se "pierda" un arrastre.
  static DropResult drop({
    required Board board,
    required int from,
    required int to,
    required int nextItemId,
  }) {
    if (from == to || !board.inBounds(from) || !board.inBounds(to)) {
      return DropResult(
        kind: DropKind.none,
        board: board,
        nextItemId: nextItemId,
      );
    }

    final BoardItem? source = board.at(from);
    if (source == null) {
      return DropResult(
        kind: DropKind.none,
        board: board,
        nextItemId: nextItemId,
      );
    }

    final BoardItem? target = board.at(to);
    final List<BoardItem?> cells = board.mutableCells();

    if (target == null) {
      cells[to] = source;
      cells[from] = null;
      return DropResult(
        kind: DropKind.move,
        board: board.withCells(cells),
        nextItemId: nextItemId,
      );
    }

    if (source.canMergeWith(target)) {
      final BoardItem merged = target.levelUp(newId: nextItemId);
      cells[to] = merged;
      cells[from] = null;
      return DropResult(
        kind: DropKind.merge,
        board: board.withCells(cells),
        nextItemId: nextItemId + 1,
        mergedItem: merged,
      );
    }

    cells[to] = source;
    cells[from] = target;
    return DropResult(
      kind: DropKind.swap,
      board: board.withCells(cells),
      nextItemId: nextItemId,
    );
  }

  /// Coloca un objeto en la primera casilla libre. Devuelve null si no cabe.
  static Board? placeInFirstFree(Board board, BoardItem item) {
    for (int i = 0; i < board.cells.length; i++) {
      if (board.cells[i] == null) {
        final List<BoardItem?> cells = board.mutableCells();
        cells[i] = item;
        return board.withCells(cells);
      }
    }
    return null;
  }

  /// Coloca un objeto en una casilla libre elegida por [pickIndex] sobre la
  /// lista de índices libres. Devuelve null si el tablero está lleno.
  static Board? place(
    Board board,
    BoardItem item,
    int Function(List<int> free) pickIndex,
  ) {
    final List<int> free = board.freeIndexes();
    if (free.isEmpty) return null;
    final int index = free[pickIndex(free).clamp(0, free.length - 1)];
    final List<BoardItem?> cells = board.mutableCells();
    cells[index] = item;
    return board.withCells(cells);
  }

  static Board removeAt(Board board, int index) {
    if (!board.inBounds(index) || board.cells[index] == null) return board;
    final List<BoardItem?> cells = board.mutableCells();
    cells[index] = null;
    return board.withCells(cells);
  }

  /// Descuenta del tablero lo que pide un pedido. Devuelve null si no alcanza,
  /// de modo que completar un pedido es atómico: o se consume todo, o nada.
  static Board? consumeOrder(Board board, CustomerOrder order) {
    final List<BoardItem?> cells = board.mutableCells();
    for (final OrderLine line in order.lines) {
      int remaining = line.quantity;
      for (int i = 0; i < cells.length && remaining > 0; i++) {
        final BoardItem? item = cells[i];
        if (item != null &&
            item.chainId == line.chainId &&
            item.level == line.level) {
          cells[i] = null;
          remaining--;
        }
      }
      if (remaining > 0) return null;
    }
    return Board(columns: board.columns, rows: board.rows, cells: cells);
  }

  /// Descuenta del tablero **lo que haya** de un pedido, sin exigir que esté
  /// completo. Devuelve el tablero nuevo; nunca falla.
  static Board consumeOrderPartially(Board board, CustomerOrder order) {
    final List<BoardItem?> cells = board.mutableCells();
    for (final OrderLine line in order.lines) {
      int remaining = line.quantity;
      for (int i = 0; i < cells.length && remaining > 0; i++) {
        final BoardItem? item = cells[i];
        if (item != null &&
            item.chainId == line.chainId &&
            item.level == line.level) {
          cells[i] = null;
          remaining--;
        }
      }
    }
    return board.withCells(cells);
  }

  /// Sugerencia para el jugador inactivo: el primer par fusionable encontrado.
  /// Devuelve null si no hay ninguno.
  static (int, int)? findMergeHint(Board board) {
    final Map<String, int> firstSeen = <String, int>{};
    for (int i = 0; i < board.cells.length; i++) {
      final BoardItem? item = board.cells[i];
      if (item == null || item.isMaxLevel) continue;
      final String key = '${item.chainId}:${item.level}';
      final int? previous = firstSeen[key];
      if (previous != null) return (previous, i);
      firstSeen[key] = i;
    }
    return null;
  }
}
