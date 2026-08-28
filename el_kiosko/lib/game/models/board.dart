import 'board_item.dart';
import 'product.dart';

/// Tablero de [columns] × [rows] casillas. Inmutable: cada operación devuelve
/// un tablero nuevo, lo que hace la lógica trivial de testear y permite
/// deshacer en el futuro sin refactor.
class Board {
  Board({
    required this.columns,
    required this.rows,
    int? unlockedRows,
    List<BoardItem?>? cells,
  }) : unlockedRows = (unlockedRows ?? rows).clamp(1, rows),
       cells = List<BoardItem?>.unmodifiable(
         cells ?? List<BoardItem?>.filled(columns * rows, null),
       ) {
    assert(this.cells.length == columns * rows, 'tamaño de tablero inválido');
  }

  final int columns;
  final int rows;

  /// Filas disponibles hoy. Las de más abajo se compran con monedas: el
  /// tablero empieza chico y crecer es parte del progreso.
  final int unlockedRows;

  final List<BoardItem?> cells;

  /// Tamaño total del tablero, incluidas las filas todavía bloqueadas.
  int get capacity => columns * rows;

  /// Casillas realmente jugables hoy.
  int get playableCapacity => columns * unlockedRows;

  bool get canExpand => unlockedRows < rows;

  /// ¿La casilla está en una fila todavía bloqueada?
  bool isLocked(int index) => index >= playableCapacity;

  int get occupied => cells.where((BoardItem? c) => c != null).length;
  int get freeCells => playableCapacity - occupied;
  bool get isFull => freeCells <= 0;
  bool get isEmpty => occupied == 0;

  /// Sólo las casillas jugables cuentan como dentro del tablero: soltar una
  /// ficha en una fila bloqueada no debe hacer nada.
  bool inBounds(int index) => index >= 0 && index < playableCapacity;

  BoardItem? at(int index) => inBounds(index) ? cells[index] : null;

  /// Tablero con una fila más desbloqueada.
  Board expanded() => Board(
    columns: columns,
    rows: rows,
    unlockedRows: (unlockedRows + 1).clamp(1, rows),
    cells: cells,
  );

  int indexOf(int column, int row) => row * columns + column;
  int columnOf(int index) => index % columns;
  int rowOf(int index) => index ~/ columns;

  Board withCells(List<BoardItem?> next) => Board(
    columns: columns,
    rows: rows,
    unlockedRows: unlockedRows,
    cells: next,
  );

  /// Copia mutable de las casillas, para construir el siguiente estado.
  List<BoardItem?> mutableCells() => List<BoardItem?>.of(cells);

  List<int> freeIndexes() {
    final List<int> result = <int>[];
    for (int i = 0; i < playableCapacity; i++) {
      if (cells[i] == null) result.add(i);
    }
    return result;
  }

  List<BoardItem> items() =>
      cells.whereType<BoardItem>().toList(growable: false);

  /// Cuántos objetos hay de una cadena y nivel dados.
  int countOf(String chainId, int level) => cells
      .whereType<BoardItem>()
      .where((BoardItem i) => i.chainId == chainId && i.level == level)
      .length;

  /// Índices de los objetos de una cadena y nivel dados, en orden de casilla.
  List<int> indexesOf(String chainId, int level) {
    final List<int> result = <int>[];
    for (int i = 0; i < cells.length; i++) {
      final BoardItem? item = cells[i];
      if (item != null && item.chainId == chainId && item.level == level) {
        result.add(i);
      }
    }
    return result;
  }

  /// Tablero con la mercadería agrupada por cadena y nivel, apretada arriba a
  /// la izquierda.
  ///
  /// El orden es el del catálogo y, dentro de cada cadena, de mayor a menor
  /// nivel. Poner los niveles altos primero deja juntos —y a la vista— los
  /// que están a un paso de fusionarse, que es lo que el jugador busca cuando
  /// toca "ordenar".
  ///
  /// Sólo toca las filas desbloqueadas: la mercadería nunca cae en una fila
  /// que todavía no se compró.
  Board sorted() {
    final List<BoardItem> loose = <BoardItem>[];
    for (int i = 0; i < playableCapacity; i++) {
      final BoardItem? item = cells[i];
      if (item != null) loose.add(item);
    }

    loose.sort((BoardItem a, BoardItem b) {
      final int byChain = _chainRank(a.chainId)
          .compareTo(_chainRank(b.chainId));
      if (byChain != 0) return byChain;
      final int byLevel = b.level.compareTo(a.level);
      if (byLevel != 0) return byLevel;
      // Desempate por id: dos fichas iguales tienen que quedar siempre en el
      // mismo orden, o "ordenar" dos veces seguidas movería cosas sin motivo.
      return a.id.compareTo(b.id);
    });

    final List<BoardItem?> next = mutableCells();
    for (int i = 0; i < playableCapacity; i++) {
      next[i] = i < loose.length ? loose[i] : null;
    }
    return withCells(next);
  }

  /// ¿Ordenar cambiaría algo? Sirve para no cobrarle al jugador por nada.
  bool get isSorted {
    final Board other = sorted();
    for (int i = 0; i < playableCapacity; i++) {
      if (cells[i]?.id != other.cells[i]?.id) return false;
    }
    return true;
  }

  static int _chainRank(String chainId) {
    final int index = ProductCatalog.chains.indexWhere(
      (ProductChain c) => c.id == chainId,
    );
    // Una cadena desconocida (save de otra versión) va al final en vez de
    // romper el orden.
    return index < 0 ? ProductCatalog.chains.length : index;
  }

  /// ¿Existe algún par fusionable en el tablero? No depende de adyacencia:
  /// el jugador puede arrastrar cualquier pieza sobre cualquier otra.
  bool hasPossibleMerge() {
    final Map<String, int> counts = <String, int>{};
    for (final BoardItem item in cells.whereType<BoardItem>()) {
      if (item.isMaxLevel) continue;
      final String key = '${item.chainId}:${item.level}';
      final int next = (counts[key] ?? 0) + 1;
      if (next >= 2) return true;
      counts[key] = next;
    }
    return false;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'columns': columns,
    'rows': rows,
    'unlockedRows': unlockedRows,
    'cells': cells.map((BoardItem? c) => c?.toJson()).toList(growable: false),
  };

  static Board fromJson(Map<String, dynamic> json) {
    final int columns = json['columns'] as int;
    final int rows = json['rows'] as int;
    // Un save anterior a las filas bloqueadas tenía el tablero completo.
    final int unlocked = (json['unlockedRows'] as int?) ?? rows;
    final List<dynamic> raw = (json['cells'] as List<dynamic>?) ?? <dynamic>[];
    final List<BoardItem?> cells = List<BoardItem?>.filled(
      columns * rows,
      null,
    );
    for (int i = 0; i < raw.length && i < cells.length; i++) {
      final Object? entry = raw[i];
      if (entry is Map) {
        cells[i] = BoardItem.fromJson(Map<String, dynamic>.from(entry));
      }
    }
    return Board(
      columns: columns,
      rows: rows,
      unlockedRows: unlocked,
      cells: cells,
    );
  }
}
