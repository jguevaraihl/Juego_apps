import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../game/game_controller.dart';
import '../../game/game_engine.dart';
import '../../game/models/game_state.dart';
import '../../game/progression/achievements.dart';
import '../../l10n/app_localizations.dart';
import '../common/game_strings.dart';

/// Los logros, con su progreso y su premio.
///
/// Los cumplidos y sin cobrar van **primero**: es lo único accionable de la
/// pantalla, y dejarlos mezclados entre diecisiete filas obligaría a buscarlos.
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l.achievementsTitle),
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
          for (final Achievement a in <Achievement>[
            ...claimable,
            ...pending,
            ...done,
          ])
            _AchievementCard(
              achievement: a,
              progress: engine.achievementProgress(state, a),
              claimed: state.claimedAchievements.contains(a.id),
              onClaim: () => controller.claimAchievement(a.id),
            ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.achievement,
    required this.progress,
    required this.claimed,
    required this.onClaim,
  });

  final Achievement achievement;
  final int progress;
  final bool claimed;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool complete = progress >= achievement.target;
    final bool canClaim = complete && !claimed;
    final double fraction = achievement.target == 0
        ? 1
        : (progress / achievement.target).clamp(0.0, 1.0);

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
                  Text(
                    l.achievementName(achievement.id),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.achievementGoal(achievement.metric, achievement.target),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
                          progress.clamp(0, achievement.target),
                          achievement.target,
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
                  child: Text(l.achievementClaim(achievement.reward)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
