import 'package:almacen/game/game_engine.dart';
import 'package:almacen/game/game_events.dart';
import 'package:almacen/game/models/game_state.dart';
import 'package:almacen/game/models/product.dart';
import 'package:almacen/game/progression/missions.dart';
import 'package:flutter_test/flutter_test.dart';

/// Las misiones diarias son lo primero del juego que depende del calendario,
/// así que lo que hay que proteger no es que sumen —eso es fácil— sino que el
/// día pase limpio, que no se puedan cobrar dos veces, y sobre todo que **no
/// castiguen** a quien no jugó ayer.
final DateTime t0 = DateTime(2026, 3, 10, 10);

void main() {
  late GameEngine engine;
  setUp(() => engine = GameEngine());

  /// Partida con nivel de jugador suficiente para tener misiones.
  GameState player({int xp = 3000, int coins = 1000}) => engine
      .newGame(now: t0, seed: 5)
      .state
      .copyWith(xp: xp, coins: coins, lastSeenAt: t0, lastIncomeAt: t0);

  group('reparto', () {
    test('antes del nivel de desbloqueo no hay ninguna', () {
      final GameState novice = player(xp: 0);
      expect(novice.playerLevel(engine.economy), 1);
      expect(engine.missionsFor(novice, t0), isEmpty);
    });

    test('reparte exactamente tres', () {
      expect(engine.missionsFor(player(), t0).length, Missions.perDay);
    });

    test('el mismo día siempre da las mismas tres', () {
      final List<String> a = engine
          .missionsFor(player(), t0)
          .map((MissionTemplate t) => t.id)
          .toList();
      final List<String> b = engine
          .missionsFor(player(), t0.add(const Duration(hours: 6)))
          .map((MissionTemplate t) => t.id)
          .toList();
      expect(
        a,
        b,
        reason: 'el reparto es determinista: no hace falta guardar cuáles son',
      );
    });

    test('nunca repite la misma métrica el mismo día', () {
      // Tres formas de decir "fusiona" no son tres metas.
      for (int day = 0; day < 400; day++) {
        final List<MissionMetric> metrics = Missions.forDay(
          day,
          10,
        ).map((MissionTemplate t) => t.metric).toList();
        expect(metrics.toSet().length, metrics.length, reason: 'día $day');
      }
    });

    test('a lo largo del tiempo salen todas las plantillas', () {
      final Set<String> seen = <String>{};
      for (int day = 0; day < 200; day++) {
        seen.addAll(Missions.forDay(day, 10).map((MissionTemplate t) => t.id));
      }
      expect(
        seen.length,
        Missions.all.length,
        reason: 'si alguna nunca sale, es contenido escrito que nadie ve',
      );
    });
  });

  group('progreso', () {
    test('fusionar cuenta para la misión de fusionar', () {
      GameState s = engine.rolloverMissions(player(), t0);
      final MissionTemplate merges = Missions.byId('daily_merges')!;
      s = s.copyWith(
        missionProgress: const <String, int>{},
        missionDay: GameState.dayNumberOf(t0),
      );

      // Se cuenta desde los eventos, igual que en la partida real.
      final GameStep step = engine.applyMissionProgress(s, <GameEvent>[
        const MergeCompleted(ProductCatalog.panaderia, 2),
        const MergeCompleted(ProductCatalog.panaderia, 2),
      ], t0);

      final List<MissionTemplate> today = engine.missionsFor(s, t0);
      if (today.any((MissionTemplate t) => t.id == merges.id)) {
        expect(engine.missionProgress(step.state, merges), 2);
      }
    });

    test('sólo suma a las tres de hoy, no a las ocho plantillas', () {
      final GameState s = engine.rolloverMissions(player(), t0);
      final GameStep step = engine.applyMissionProgress(s, <GameEvent>[
        const MergeCompleted(ProductCatalog.panaderia, 5),
      ], t0);

      final Set<String> today = engine
          .missionsFor(s, t0)
          .map((MissionTemplate t) => t.id)
          .toSet();
      expect(
        step.state.missionProgress.keys.every(today.contains),
        isTrue,
        reason: 'contar las que no tocaron las dejaría cumplidas mañana',
      );
    });

    test(
      'una fusión de nivel alto cuenta para las dos misiones que aplican',
      () {
        // Nivel 5 es a la vez "una fusión" y "una fusión de nivel alto".
        final GameState s = engine
            .rolloverMissions(player(), t0)
            .copyWith(missionProgress: const <String, int>{});
        final GameStep step = engine.applyMissionProgress(s, <GameEvent>[
          const MergeCompleted(ProductCatalog.panaderia, 5),
        ], t0);

        for (final MissionTemplate t in engine.missionsFor(s, t0)) {
          if (t.metric == MissionMetric.merges ||
              t.metric == MissionMetric.highLevelMerges) {
            expect(engine.missionProgress(step.state, t), 1);
          }
        }
      },
    );
  });

  group('el día pasa', () {
    test('al día siguiente el progreso vuelve a cero', () {
      GameState s = engine.rolloverMissions(player(), t0);
      s = engine.applyMissionProgress(s, <GameEvent>[
        const MergeCompleted(ProductCatalog.panaderia, 2),
      ], t0).state;
      expect(s.missionProgress, isNotEmpty);

      final DateTime tomorrow = t0.add(const Duration(days: 1));
      final GameStep step = engine.applyMissionProgress(
        s,
        const <GameEvent>[],
        tomorrow,
      );

      expect(step.state.missionProgress, isEmpty);
      expect(step.state.missionsClaimed, isEmpty);
      expect(step.state.missionDay, GameState.dayNumberOf(tomorrow));
      expect(step.events.whereType<MissionsRefreshed>(), isNotEmpty);
    });

    test('no haber cumplido ayer no quita nada', () {
      // El brief prohíbe los ganchos de culpa: una racha diaria que se pierde
      // es un castigo por tener vida fuera del teléfono. Acá no hay racha que
      // perder, y volver después de una semana cuesta exactamente lo mismo que
      // volver mañana.
      final GameState s = engine.rolloverMissions(player(coins: 777), t0);
      final GameState later = engine
          .applyMissionProgress(
            s,
            const <GameEvent>[],
            t0.add(const Duration(days: 9)),
          )
          .state;

      expect(later.coins, 777);
      expect(later.xp, s.xp);
      expect(
        engine.missionsFor(later, t0.add(const Duration(days: 9))).length,
        3,
      );
    });

    test('varias acciones el mismo día no repiten el aviso de renovación', () {
      final GameState s = engine.rolloverMissions(player(), t0);
      final GameStep again = engine.applyMissionProgress(
        s,
        const <GameEvent>[],
        t0.add(const Duration(hours: 2)),
      );
      expect(again.events.whereType<MissionsRefreshed>(), isEmpty);
    });
  });

  group('cobrar', () {
    /// Deja una misión cumplida, sea cual sea la que tocó hoy.
    (GameState, MissionTemplate) completed() {
      GameState s = engine.rolloverMissions(player(), t0);
      final MissionTemplate t = engine.missionsFor(s, t0).first;
      s = s.copyWith(
        missionProgress: <String, int>{
          t.id: t.targetFor(s.playerLevel(engine.economy)),
        },
      );
      return (s, t);
    }

    test('cumplida y cobrada paga una vez', () {
      final (GameState s, MissionTemplate t) = completed();
      expect(engine.isMissionComplete(s, t), isTrue);
      expect(engine.hasClaimableMission(s, t0), isTrue);

      final GameStep first = engine.claimMission(s, t.id, t0);
      final int reward = engine.missionReward(s, t);
      expect(first.state.coins, s.coins + reward);
      expect(first.events.whereType<MissionClaimed>().first.reward, reward);

      final GameStep second = engine.claimMission(first.state, t.id, t0);
      expect(second.state.coins, first.state.coins);
      expect(
        second.events.whereType<ActionRejected>().first.reason,
        RejectReason.alreadyOwned,
      );
    });

    test('sin cumplir no se puede cobrar', () {
      final GameState s = engine.rolloverMissions(player(), t0);
      final MissionTemplate t = engine.missionsFor(s, t0).first;

      final GameStep step = engine.claimMission(s, t.id, t0);
      expect(step.state.coins, s.coins);
      expect(
        step.events.whereType<ActionRejected>().first.reason,
        RejectReason.achievementNotDone,
      );
    });

    test('una misión que no es de hoy no hace nada', () {
      final GameState s = engine.rolloverMissions(player(), t0);
      final Set<String> today = engine
          .missionsFor(s, t0)
          .map((MissionTemplate m) => m.id)
          .toSet();
      final MissionTemplate other = Missions.all.firstWhere(
        (MissionTemplate m) => !today.contains(m.id),
      );

      expect(engine.claimMission(s, other.id, t0).state.coins, s.coins);
    });
  });

  group('balance', () {
    test('tres misiones no reemplazan a subir de nivel', () {
      // Si un día de misiones pagara una subida entera, el juego óptimo sería
      // abrir la app una vez al día, cobrar y cerrarla.
      //
      // La comparación se hace contra el nivel de local que le corresponde al
      // nivel de jugador —van más o menos juntos— y no contra el local del
      // fixture, que arranca siempre en 1 y haría trampa a favor del test.
      for (int level = Missions.unlockPlayerLevel; level <= 25; level++) {
        final GameState s = engine
            .newGame(now: t0, seed: 1)
            .state
            .copyWith(xp: engine.economy.xpForLevel(level), shopLevel: level);
        final int daily = engine
            .missionsFor(s, t0)
            .fold(
              0,
              (int sum, MissionTemplate t) => sum + engine.missionReward(s, t),
            );
        final int upgrade = s.nextShopTier!.upgradeCost;
        expect(
          daily,
          lessThan(upgrade),
          reason: 'en nivel $level las misiones pagan $daily y subir $upgrade',
        );
      }
    });

    test('pero aportan lo suficiente para que valga la pena abrirlas', () {
      final GameState s = engine
          .newGame(now: t0, seed: 1)
          .state
          .copyWith(xp: engine.economy.xpForLevel(8));
      final int daily = engine
          .missionsFor(s, t0)
          .fold(
            0,
            (int sum, MissionTemplate t) => sum + engine.missionReward(s, t),
          );
      expect(
        daily,
        greaterThan(engine.economy.orderReward(engine.economy.itemValue(4))),
      );
    });
  });

  test('un save de otra versión con misiones desconocidas no rompe nada', () {
    final GameState s = engine
        .rolloverMissions(player(), t0)
        .copyWith(
          missionProgress: const <String, int>{'mision_que_ya_no_existe': 99},
          missionsClaimed: const <String>{'otra_que_no_existe'},
        );

    expect(engine.missionsFor(s, t0).length, 3);
    expect(engine.hasClaimableMission(s, t0), isFalse);
    expect(engine.claimMission(s, 'mision_que_ya_no_existe', t0).state, s);
  });
}
