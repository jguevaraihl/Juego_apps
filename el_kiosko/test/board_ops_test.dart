import 'package:almacen/game/board/board_ops.dart';
import 'package:almacen/game/models/board.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/order.dart';
import 'package:almacen/game/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

BoardItem item(int id, String chain, int level) =>
    BoardItem(id: id, chainId: chain, level: level);

Board boardWith(Map<int, BoardItem> placed, {int columns = 3, int rows = 3}) {
  final List<BoardItem?> cells = List<BoardItem?>.filled(columns * rows, null);
  placed.forEach((int index, BoardItem value) => cells[index] = value);
  return Board(columns: columns, rows: rows, cells: cells);
}

void main() {
  const String pan = ProductCatalog.panaderia;
  const String bebida = ProductCatalog.bebidas;

  group('merge válido', () {
    test('dos iguales se fusionan y suben un nivel', () {
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, pan, 1),
        1: item(2, pan, 1),
      });

      final DropResult result = BoardOps.drop(
        board: board,
        from: 0,
        to: 1,
        nextItemId: 3,
      );

      expect(result.kind, DropKind.merge);
      expect(result.board.at(0), isNull);
      expect(result.board.at(1)!.level, 2);
      expect(result.board.at(1)!.chainId, pan);
      // El objeto resultante recibe un id nuevo, para animarlo como pieza nueva.
      expect(result.board.at(1)!.id, 3);
      expect(result.nextItemId, 4);
      // Dos objetos entran, uno sale.
      expect(result.board.occupied, 1);
    });
  });

  group('merge inválido', () {
    test('distinta cadena intercambia en vez de fusionar', () {
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, pan, 1),
        1: item(2, bebida, 1),
      });

      final DropResult result = BoardOps.drop(
        board: board,
        from: 0,
        to: 1,
        nextItemId: 3,
      );

      expect(result.kind, DropKind.swap);
      expect(result.board.at(0)!.chainId, bebida);
      expect(result.board.at(1)!.chainId, pan);
      expect(result.board.occupied, 2);
    });

    test('distinto nivel intercambia', () {
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, pan, 1),
        1: item(2, pan, 2),
      });

      final DropResult result = BoardOps.drop(
        board: board,
        from: 0,
        to: 1,
        nextItemId: 3,
      );

      expect(result.kind, DropKind.swap);
      expect(result.board.occupied, 2);
    });

    test('el nivel máximo no se puede fusionar', () {
      final int maxLevel = ProductCatalog.byId(pan).maxLevel;
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, pan, maxLevel),
        1: item(2, pan, maxLevel),
      });

      final DropResult result = BoardOps.drop(
        board: board,
        from: 0,
        to: 1,
        nextItemId: 3,
      );

      expect(result.kind, DropKind.swap);
      expect(result.board.occupied, 2);
    });

    test('soltar sobre sí mismo o fuera del tablero no hace nada', () {
      final Board board = boardWith(<int, BoardItem>{0: item(1, pan, 1)});

      expect(
        BoardOps.drop(board: board, from: 0, to: 0, nextItemId: 2).kind,
        DropKind.none,
      );
      expect(
        BoardOps.drop(board: board, from: 0, to: 99, nextItemId: 2).kind,
        DropKind.none,
      );
      expect(
        BoardOps.drop(board: board, from: 5, to: 0, nextItemId: 2).kind,
        DropKind.none,
      );
    });
  });

  test('mover a casilla vacía', () {
    final Board board = boardWith(<int, BoardItem>{0: item(1, pan, 1)});
    final DropResult result = BoardOps.drop(
      board: board,
      from: 0,
      to: 4,
      nextItemId: 2,
    );

    expect(result.kind, DropKind.move);
    expect(result.board.at(0), isNull);
    expect(result.board.at(4)!.id, 1);
  });

  group('consumo de pedidos', () {
    test('descuenta exactamente lo pedido', () {
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, pan, 1),
        1: item(2, pan, 1),
        2: item(3, pan, 1),
        3: item(4, bebida, 1),
      });

      const CustomerOrder order = CustomerOrder(
        id: 1,
        customerName: 'x',
        lines: <OrderLine>[OrderLine(chainId: pan, level: 1, quantity: 2)],
        reward: 10,
        xp: 3,
      );

      final Board? result = BoardOps.consumeOrder(board, order);
      expect(result, isNotNull);
      expect(result!.countOf(pan, 1), 1);
      expect(result.countOf(bebida, 1), 1);
    });

    test('es atómico: si falta algo no consume nada', () {
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, pan, 1),
        1: item(2, bebida, 1),
      });

      const CustomerOrder order = CustomerOrder(
        id: 1,
        customerName: 'x',
        lines: <OrderLine>[
          OrderLine(chainId: pan, level: 1, quantity: 1),
          OrderLine(chainId: bebida, level: 1, quantity: 5),
        ],
        reward: 10,
        xp: 3,
      );

      expect(BoardOps.consumeOrder(board, order), isNull);
      // El tablero original queda intacto.
      expect(board.occupied, 2);
    });
  });

  group('detección de jugadas', () {
    test('hasPossibleMerge encuentra un par aunque no sea adyacente', () {
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, pan, 1),
        8: item(2, pan, 1),
      });
      expect(board.hasPossibleMerge(), isTrue);
    });

    test('hasPossibleMerge es falso sin pares', () {
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, pan, 1),
        1: item(2, bebida, 2),
      });
      expect(board.hasPossibleMerge(), isFalse);
    });

    test('un par en nivel máximo no cuenta como jugada', () {
      final int maxLevel = ProductCatalog.byId(pan).maxLevel;
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, pan, maxLevel),
        1: item(2, pan, maxLevel),
      });
      expect(board.hasPossibleMerge(), isFalse);
    });

    test('findMergeHint devuelve un par realmente fusionable', () {
      final Board board = boardWith(<int, BoardItem>{
        0: item(1, bebida, 2),
        3: item(2, pan, 1),
        7: item(3, pan, 1),
      });

      final (int, int)? hint = BoardOps.findMergeHint(board);
      expect(hint, isNotNull);
      final BoardItem a = board.at(hint!.$1)!;
      final BoardItem b = board.at(hint.$2)!;
      expect(a.canMergeWith(b), isTrue);
    });
  });

  test('placeInFirstFree respeta el tablero lleno', () {
    final Board full = boardWith(<int, BoardItem>{
      for (int i = 0; i < 9; i++) i: item(i, pan, 1),
    });
    expect(BoardOps.placeInFirstFree(full, item(99, pan, 1)), isNull);
  });
}
