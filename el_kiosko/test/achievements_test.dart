import 'package:almacen/features/common/game_strings.dart';
import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/game_events.dart';
import 'package:almacen/game/models/board_item.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/product.dart';
import 'package:almacen/game/progression/achievements.dart';
import 'package:almacen/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

extension on GameStep {
  T event<T extends GameEvent>() => events.whereType<T>().first;
}

void main() {
  final GameEngine engine = GameEngine();
  final DateTime t0 = DateTime.utc(2026, 9, 1, 12);

  GameState fresh() => engine.newGame(now: t0, seed: 5).state;

  group('catálogo', () {
    test('los ids son únicos: el save guarda ids', () {
      final Set<String> ids = Achievements.all
          .map((Achievement a) => a.id)
          .toSet();
      expect(ids.length, Achievements.all.length);
    });

    test('ninguna meta es cero ni ningún premio es negativo', () {
      for (final Achievement a in Achievements.all) {
        expect(a.target, greaterThan(0), reason: a.id);
        expect(a.reward, greaterThan(0), reason: a.id);
      }
    });

    test('las escaleras suben: metas y premios crecientes', () {
      for (final AchievementMetric m in AchievementMetric.values) {
        final List<Achievement> steps = Achievements.all
            .where((Achievement a) => a.metric == m)
            .toList(growable: false);
        for (int i = 1; i < steps.length; i++) {
          expect(
            steps[i].target,
            greaterThan(steps[i - 1].target),
            reason: '$m',
          );
          expect(
            steps[i].reward,
            greaterThan(steps[i - 1].reward),
            reason: '$m',
          );
        }
      }
    });
  });

  group('progreso', () {
    test('una partida nueva no tiene nada cumplido', () {
      final GameState s = fresh();
      for (final Achievement a in Achievements.all) {
        expect(engine.isAchievementComplete(s, a), isFalse, reason: a.id);
      }
      expect(engine.hasClaimableAchievement(s), isFalse);
    });

    test('cobrar paga una vez y sólo una', () {
      final GameState s = fresh().copyWith(totalMerges: 999, coins: 100);
      final Achievement a = Achievements.byId('merges_1')!;
      expect(engine.isAchievementComplete(s, a), isTrue);

      final GameStep first = engine.claimAchievement(s, a.id);
      expect(first.state.coins, 100 + a.reward);
      expect(first.event<AchievementClaimed>().reward, a.reward);

      final GameStep again = engine.claimAchievement(first.state, a.id);
      expect(again.state.coins, first.state.coins);
      expect(again.event<ActionRejected>().reason, RejectReason.alreadyOwned);
    });

    test('no se puede cobrar algo no cumplido', () {
      final GameState s = fresh().copyWith(coins: 100);
      final GameStep step = engine.claimAchievement(s, 'merges_3');
      expect(step.state.coins, 100);
      expect(
        step.event<ActionRejected>().reason,
        RejectReason.achievementNotDone,
      );
    });

    test('un id desconocido no hace nada', () {
      final GameState s = fresh().copyWith(coins: 100);
      final GameStep step = engine.claimAchievement(s, 'no_existe');
      expect(step.state.coins, 100);
      expect(step.state.claimedAchievements, isEmpty);
    });
  });

  group('racha de fusiones', () {
    GameState withPair(GameState base, int idA, int idB) {
      final List<BoardItem?> cells = List<BoardItem?>.filled(
        base.board.capacity,
        null,
      );
      cells[0] = BoardItem(
        id: idA,
        chainId: ProductCatalog.panaderia,
        level: 1,
      );
      cells[1] = BoardItem(
        id: idB,
        chainId: ProductCatalog.panaderia,
        level: 1,
      );
      return base.copyWith(board: base.board.withCells(cells));
    }

    test('sube al fusionar y guarda la mejor', () {
      GameState s = fresh().copyWith(coins: 500);
      for (int i = 0; i < 3; i++) {
        s = withPair(s, 100 + i * 2, 101 + i * 2);
        s = engine.drop(s, 0, 1).state;
      }
      expect(s.mergeStreak, 3);
      expect(s.bestMergeStreak, 3);
    });

    test('otra acción la corta, pero la mejor se conserva', () {
      // La mejor es lo que mira el logro: si mirara la actual, conseguirlo
      // dependería de acordarse de cobrarlo antes de tocar cualquier cosa.
      GameState s = fresh().copyWith(coins: 500);
      for (int i = 0; i < 4; i++) {
        s = withPair(s, 200 + i * 2, 201 + i * 2);
        s = engine.drop(s, 0, 1).state;
      }
      expect(s.mergeStreak, 4);

      s = engine.generate(s).state;
      expect(s.mergeStreak, 0, reason: 'generar corta la racha');
      expect(s.bestMergeStreak, 4);

      final Achievement streak = Achievements.byId('streak_1')!;
      s = s.copyWith(bestMergeStreak: streak.target);
      expect(engine.isAchievementComplete(s, streak), isTrue);
    });

    test('entregar un pedido también la corta', () {
      GameState s = fresh().copyWith(coins: 500);
      s = withPair(s, 300, 301);
      s = engine.drop(s, 0, 1).state;
      expect(s.mergeStreak, 1);

      s = engine.sell(s, 1).state;
      expect(s.mergeStreak, 0);
    });
  });

  group('textos', () {
    testWidgets('todos los logros tienen nombre real en los dos idiomas', (
      WidgetTester tester,
    ) async {
      // Mismo seguro que el catálogo de productos: agregar un logro sin
      // traducirlo falla acá y no en el teléfono de alguien.
      for (final Locale locale in AppLocalizations.supportedLocales) {
        final AppLocalizations l = await AppLocalizations.delegate.load(locale);
        for (final Achievement a in Achievements.all) {
          final String name = l.achievementName(a.id);
          expect(
            name,
            isNot(a.id),
            reason: 'falta el nombre de ${a.id} en ${locale.languageCode}',
          );
          expect(name.trim(), isNotEmpty);
          expect(
            l.achievementGoal(a.metric, a.target),
            contains('${a.target}'),
            reason: 'la meta de ${a.id} tiene que decir el número',
          );
        }
      }
    });
  });
}
