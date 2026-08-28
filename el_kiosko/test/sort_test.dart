import 'package:almacen/game/economy/economy_config.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/game_events.dart';
import 'package:almacen/game/models/board.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

extension on GameStep {
  T event<T extends GameEvent>() => events.whereType<T>().first;
}

/// "Ordenar" es comodidad, no economía: lo que hay que garantizar es que
/// agrupe de verdad, que sea estable, y que no se le pueda cobrar al jugador
/// por no hacer nada.
void main() {
  final GameEngine engine = GameEngine();
  final DateTime t0 = DateTime.utc(2026, 8, 28, 12);

  GameState withBoard(Map<int, BoardItem> items, {int coins = 500}) {
    final GameState base = engine.newGame(now: t0, seed: 7).state;
    final List<BoardItem?> cells = List<BoardItem?>.filled(
      base.board.capacity,
      null,
    );
    items.forEach((int i, BoardItem item) => cells[i] = item);
    return base.copyWith(board: base.board.withCells(cells), coins: coins);
  }

  BoardItem item(int id, String chain, int level) =>
      BoardItem(id: id, chainId: chain, level: level);

  group('ordenar el tablero', () {
    test('agrupa por cadena y deja los niveles altos primero', () {
      final GameState state = withBoard(<int, BoardItem>{
        0: item(1, ProductCatalog.bebidas, 1),
        5: item(2, ProductCatalog.panaderia, 3),
        11: item(3, ProductCatalog.panaderia, 1),
        17: item(4, ProductCatalog.bebidas, 2),
      });

      final Board sorted = state.board.sorted();

      // Panadería va antes que bebidas porque va antes en el catálogo, y
      // dentro de cada cadena manda el nivel más alto.
      expect(sorted.at(0)!.chainId, ProductCatalog.panaderia);
      expect(sorted.at(0)!.level, 3);
      expect(sorted.at(1)!.chainId, ProductCatalog.panaderia);
      expect(sorted.at(1)!.level, 1);
      expect(sorted.at(2)!.chainId, ProductCatalog.bebidas);
      expect(sorted.at(2)!.level, 2);
      expect(sorted.at(3)!.chainId, ProductCatalog.bebidas);
      expect(sorted.at(3)!.level, 1);
    });

    test('no pierde ni inventa mercadería', () {
      final GameState state = withBoard(<int, BoardItem>{
        0: item(1, ProductCatalog.bebidas, 1),
        7: item(2, ProductCatalog.panaderia, 3),
        13: item(3, ProductCatalog.snacks, 2),
        22: item(4, ProductCatalog.panaderia, 1),
        26: item(5, ProductCatalog.bebidas, 4),
      });

      final Board sorted = state.board.sorted();
      expect(sorted.occupied, state.board.occupied);
      expect(
        sorted.items().map((BoardItem i) => i.id).toSet(),
        state.board.items().map((BoardItem i) => i.id).toSet(),
      );
    });

    test('es estable: ordenar dos veces no mueve nada más', () {
      final GameState state = withBoard(<int, BoardItem>{
        0: item(1, ProductCatalog.bebidas, 1),
        4: item(2, ProductCatalog.bebidas, 1),
        9: item(3, ProductCatalog.panaderia, 2),
      });

      final Board once = state.board.sorted();
      final Board twice = once.sorted();
      expect(twice.isSorted, isTrue);
      for (int i = 0; i < once.playableCapacity; i++) {
        expect(once.at(i)?.id, twice.at(i)?.id);
      }
    });

    test('nunca deja mercadería en una fila bloqueada', () {
      GameState state = withBoard(<int, BoardItem>{
        0: item(1, ProductCatalog.bebidas, 1),
        3: item(2, ProductCatalog.panaderia, 2),
      });
      state = state.copyWith(
        board: Board(
          columns: state.board.columns,
          rows: state.board.rows,
          unlockedRows: 2,
          cells: state.board.cells,
        ),
      );

      final Board sorted = state.board.sorted();
      for (int i = sorted.playableCapacity; i < sorted.capacity; i++) {
        expect(sorted.cells[i], isNull);
      }
      expect(sorted.occupied, 2);
    });

    test('cobra la comisión', () {
      final GameState state = withBoard(<int, BoardItem>{
        0: item(1, ProductCatalog.bebidas, 1),
        9: item(2, ProductCatalog.panaderia, 2),
      }, coins: 100);

      final GameStep step = engine.sortBoard(state);
      expect(step.state.coins, 100 - EconomyConfig.defaults.sortCost);
      expect(step.event<BoardSorted>().cost, EconomyConfig.defaults.sortCost);
    });

    test('no cobra si ya está ordenado', () {
      GameState state = withBoard(<int, BoardItem>{
        0: item(1, ProductCatalog.panaderia, 2),
        1: item(2, ProductCatalog.panaderia, 1),
      }, coins: 100);
      state = state.copyWith(board: state.board.sorted());

      final GameStep step = engine.sortBoard(state);
      expect(step.state.coins, 100);
      expect(step.event<ActionRejected>().reason, RejectReason.alreadySorted);
    });

    test('sin monedas no se puede ordenar', () {
      final GameState state = withBoard(<int, BoardItem>{
        0: item(1, ProductCatalog.bebidas, 1),
        9: item(2, ProductCatalog.panaderia, 2),
      }, coins: 0);

      final GameStep step = engine.sortBoard(state);
      expect(step.event<ActionRejected>().reason, RejectReason.notEnoughCoins);
      expect(step.state.board.at(0)?.chainId, ProductCatalog.bebidas);
    });
  });

  group('mejora de ordenar gratis', () {
    test('cuesta la mitad del salto de nivel del local', () {
      final GameState state = withBoard(const <int, BoardItem>{});
      expect(
        engine.freeSortCost(state),
        (state.nextShopTier!.upgradeCost * 0.5).round(),
      );
    });

    test('comprada, ordenar deja de costar', () {
      GameState state = withBoard(<int, BoardItem>{
        0: item(1, ProductCatalog.bebidas, 1),
        9: item(2, ProductCatalog.panaderia, 2),
      }, coins: 100000);

      expect(engine.sortCost(state), EconomyConfig.defaults.sortCost);

      final GameStep bought = engine.buyFreeSort(state);
      expect(bought.state.freeSortUnlocked, isTrue);
      expect(bought.event<FreeSortUnlocked>().cost, engine.freeSortCost(state));

      state = bought.state;
      expect(engine.sortCost(state), 0);

      final int before = state.coins;
      final GameStep sorted = engine.sortBoard(state);
      expect(sorted.state.coins, before);
      expect(sorted.event<BoardSorted>().cost, 0);
    });

    test('no se puede comprar dos veces', () {
      final GameState state = withBoard(
        const <int, BoardItem>{},
        coins: 100000,
      ).copyWith(freeSortUnlocked: true);

      final GameStep step = engine.buyFreeSort(state);
      expect(step.event<ActionRejected>().reason, RejectReason.alreadyOwned);
      expect(step.state.coins, 100000);
    });

    test('sin monedas no se compra', () {
      final GameState state = withBoard(const <int, BoardItem>{}, coins: 1);
      final GameStep step = engine.buyFreeSort(state);
      expect(step.event<ActionRejected>().reason, RejectReason.notEnoughCoins);
      expect(step.state.freeSortUnlocked, isFalse);
    });

    test('en el último nivel del local sigue teniendo precio', () {
      // Sin salto siguiente, cotizar contra null habría dado 0 y la mejora
      // saldría gratis justo cuando el jugador tiene más monedas.
      final GameState state = withBoard(const <int, BoardItem>{})
          .copyWith(shopLevel: 7);
      expect(state.nextShopTier, isNull);
      expect(engine.freeSortCost(state), greaterThan(0));
    });
  });
}
