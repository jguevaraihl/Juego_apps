import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../game/game_controller.dart';
import '../../game/game_engine.dart';
import '../../game/models/game_state.dart';
import '../../game/progression/achievements.dart';
import '../../game/progression/missions.dart';
import '../../l10n/app_localizations.dart';
import '../common/game_strings.dart';

/// Las metas del jugador: las tres de hoy y las de siempre.
///
/// **Las dos cosas van juntas y en ese orden.** Los logros son de por vida y
/// se mueven despacio; las misiones diarias son lo que se puede hacer *hoy*,
/// y son la respuesta a la pregunta con la que alguien abre el juego en la
/// mitad de una partida de treinta niveles: "¿y ahora qué hago?". Ponerlas en
/// una pantalla aparte habría significado un quinto ícono en una barra que ya
/// tiene cuatro, y dos lugares donde buscar lo mismo.
///
/// Dentro de cada bloque, lo cumplido y sin cobrar va **primero**: es lo único
/// accionable, y mezclado entre veinte filas habría que buscarlo.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState? state = ref.watch(gameControllerProvider).state;
    if (state == null) return const Scaffold();

    final AppLocalizations l = AppLocalizations.of(context);
    final GameEngine engine = ref.read(gameEngineProvider);
    final GameController controller = ref.read(gameControllerProvider.notifier);

    final List<Achievement> claimable = <Achievement>[];
    final List<Achievement> pending = <Achievement>[];
    final List<Achievement> done = <Achievement>[];
    for (final Achievement a in Achievements.all) {
      if (state.claimedAchievements.contains(a.id)) {
        done.add(a);
      } else if (engine.isAchievementComplete(state, a)) {
        claimable.add(a);
      } else {
        pending.add(a);
      }
    }

    final List<MissionTemplate> missions = engine.missionsFor(
      state,
      DateTime.now(),
    );
    // Igual que los logros: lo cobrable arriba.
    final List<MissionTemplate> missionsSorted = <MissionTemplate>[
      ...missions.where(
        (MissionTemplate t) =>
            engine.isMissionComplete(state, t) &&
            !state.missionsClaimed.contains(t.id),
      ),
      ...missions.where(
        (MissionTemplate t) =>
            !engine.isMissionComplete(state, t) ||
            state.missionsClaimed.contains(t.id),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.goalsTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l.achievementsSub(done.length, Achievements.all.length),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: <Widget>[
          _SectionTitle(l.missionsToday),
          if (missionsSorted.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
              child: Text(
                l.missionsLocked(Missions.unlockPlayerLevel),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: Text(
                l.missionsSub,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            for (final MissionTemplate t in missionsSorted)
              _GoalCard(
                title: l.missionName(t.id),
                goal: l.missionDescription(
                  t.metric,
                  t.targetFor(state.playerLevel(engine.economy)),
                ),
                progress: engine.missionProgress(state, t),
                target: t.targetFor(state.playerLevel(engine.economy)),
                reward: engine.missionReward(state, t),
                claimed: state.missionsClaimed.contains(t.id),
                onClaim: () => controller.claimMission(t.id),
              ),
          ],
          const SizedBox(height: 8),
          _SectionTitle(l.achievementsAll),
          for (final Achievement a in <Achievement>[
            ...claimable,
            ...pending,
            ...done,
          ])
            _GoalCard(
              title: l.achievementName(a.id),
              goal: l.achievementGoal(a.metric, a.target),
              progress: engine.achievementProgress(state, a),
              target: a.target,
              reward: a.reward,
              claimed: state.claimedAchievements.contains(a.id),
              onClaim: () => controller.claimAchievement(a.id),
            ),
        ],
      ),
    );
  }
}

/// Una meta con su progreso y su premio.
///
/// La usan las misiones del día y los logros de siempre: los dos muestran
/// exactamente lo mismo —nombre, qué pide, barra, premio— y tenerlos en dos
/// widgets distintos habría significado arreglar cada detalle visual dos veces.
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.goal,
    required this.progress,
    required this.target,
    required this.reward,
    required this.claimed,
    required this.onClaim,
  });

  final String title;
  final String goal;
  final int progress;
  final int target;
  final int reward;
  final bool claimed;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool complete = progress >= target;
    final bool canClaim = complete && !claimed;
    final double fraction = target == 0
        ? 1
        : (progress / target).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: canClaim
              ? context.palette.success
              : context.palette.wood.withValues(alpha: 0.22),
          width: canClaim ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            // El ícono dice el estado sin depender del color: candado, copa o
            // visto bueno.
            Icon(
              claimed
                  ? Icons.check_circle
                  : (complete ? Icons.emoji_events : Icons.lock_outline),
              size: 28,
              color: claimed
                  ? context.palette.success
                  : (complete
                        ? context.palette.coin
                        : context.palette.inkSoft.withValues(alpha: 0.6)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(goal, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 6,
                            backgroundColor: context.palette.wood.withValues(
                              alpha: 0.15,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              complete
                                  ? context.palette.success
                                  : context.palette.wood,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l.achievementProgress(
                          progress.clamp(0, target),
                          target,
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: context.palette.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (claimed)
              Text(
                l.achievementClaimed,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.palette.inkSoft,
                ),
              )
            else
              SizedBox(
                height: AppTheme.minTouchTarget,
                child: FilledButton(
                  onPressed: canClaim ? onClaim : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.palette.success,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(l.achievementClaim(reward)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: context.palette.wood,
      ),
    ),
  );
}
