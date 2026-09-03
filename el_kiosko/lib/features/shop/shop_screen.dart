import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../game/game_controller.dart';
import '../../game/progression/workers.dart';
import '../home/widgets/game_clock.dart';
import '../../game/game_engine.dart';
import '../../game/economy/economy_config.dart';
import '../../game/models/game_state.dart';
import '../../game/progression/shop_tiers.dart';
import '../../l10n/app_localizations.dart';
import '../common/game_strings.dart';
import '../home/widgets/storefront.dart';

/// Mejorar el local: la meta visible de largo plazo.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState? state = ref.watch(gameControllerProvider).state;
    if (state == null) return const Scaffold();

    final AppLocalizations l = AppLocalizations.of(context);
    final GameController controller = ref.read(gameControllerProvider.notifier);
    final EconomyConfig config = ref.read(economyConfigProvider);
    final GameEngine engine = ref.read(gameEngineProvider);
    final ShopTier? next = state.nextShopTier;
    final bool canAfford = next != null && state.coins >= next.upgradeCost;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.shopTitle),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: <Widget>[
                  Icon(Icons.payments, size: 18, color: context.palette.coin),
                  const SizedBox(width: 4),
                  Text(
                    '${state.coins}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: context.palette.coin,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Storefront(
            tier: state.shopTier,
            height: 190,
            animate: !state.settings.reducedMotion,
            storeName: state.settings.storeName,
            awningColor: state.settings.awningColor,
            petId: state.settings.petId,
          ),
          const SizedBox(height: 12),
          Text(
            // El nombre que puso el jugador manda sobre el del nivel: es su
            // local. El nivel se sigue viendo en la tarjeta de la mejora.
            state.settings.storeName ?? l.shopTierName(state.shopLevel),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            l.shopTierTagline(state.shopLevel),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(
            l.shopIncomePerHour(state.shopTier.coinsPerHour),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          if (next == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.shopMaxedOut),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l.shopNext(l.shopTierName(next.level)),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.shopTierTagline(next.level),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    _Delta(
                      label: l.shopShelves,
                      from: state.shopTier.shelves,
                      to: next.shelves,
                    ),
                    _Delta(
                      label: l.shopCustomers,
                      from: state.shopTier.customers,
                      to: next.customers,
                    ),
                    _Delta(
                      label: l.shopIncomeLabel,
                      from: state.shopTier.coinsPerHour,
                      to: next.coinsPerHour,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: canAfford
                            ? () {
                                controller.upgradeShop();
                                Navigator.of(context).maybePop();
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: context.palette.wood,
                        ),
                        icon: const Icon(Icons.upgrade),
                        label: Text(
                          canAfford
                              ? l.shopUpgradeFor(next.upgradeCost)
                              : l.shopMissingCoins(
                                  next.upgradeCost - state.coins,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          // La caja: cuántas horas aguanta antes de llenarse. Ampliarla es un
          // sumidero de monedas y, sobre todo, más tiempo de ganancia mientras
          // el jugador no está.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.savings_outlined, color: context.palette.wood),
                      const SizedBox(width: 8),
                      Text(
                        l.tillUpgradeTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.tillUpgradeBody(
                      config.tillHours(state.tillLevel),
                      config.tillHours(state.tillLevel + 1),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: state.tillLevel >= config.tillMaxLevel
                        ? OutlinedButton(
                            onPressed: null,
                            child: Text(l.tillAtMax),
                          )
                        : FilledButton.icon(
                            onPressed:
                                state.coins >=
                                    config.tillUpgradeCost(state.tillLevel + 1)
                                ? controller.upgradeTill
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: context.palette.wood,
                            ),
                            icon: const Icon(Icons.savings),
                            label: Text(
                              l.tillUpgradeFor(
                                config.tillUpgradeCost(state.tillLevel + 1),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // El ayudante: la única automatización del juego, y por horas.
          _WorkerCard(state: state, engine: engine, controller: controller),
          const SizedBox(height: 20),
          // Ordenar gratis: una compra de una sola vez, cotizada contra el
          // salto de nivel para que acompañe al progreso en vez de quedar
          // barata al final o inalcanzable al principio.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.auto_awesome_motion,
                        color: context.palette.wood,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.freeSortTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.freeSortBody,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: state.freeSortUnlocked
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.check),
                            label: Text(l.freeSortOwned),
                          )
                        : FilledButton.icon(
                            onPressed: state.coins >= engine.freeSortCost(state)
                                ? controller.buyFreeSort
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: context.palette.wood,
                            ),
                            icon: const Icon(Icons.auto_awesome_motion),
                            label: Text(
                              l.freeSortBuy(engine.freeSortCost(state)),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l.shopAllLevels, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final ShopTier tier in ShopTiers.all)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                tier.level <= state.shopLevel
                    ? Icons.check_circle
                    : Icons.lock_outline,
                color: tier.level <= state.shopLevel
                    ? context.palette.success
                    : context.palette.inkSoft,
              ),
              title: Text(l.shopTierName(tier.level)),
              subtitle: Text(
                tier.level == 1
                    ? l.shopStartingPoint
                    : l.shopCosts(tier.upgradeCost),
              ),
            ),
        ],
      ),
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta({required this.label, required this.from, required this.to});

  final String label;
  final int from;
  final int to;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text('$from', style: TextStyle(color: context.palette.inkSoft)),
          Icon(Icons.arrow_right_alt, size: 18, color: context.palette.inkSoft),
          Text(
            '$to',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.palette.success,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contratar ayuda, o ver cuánto le queda al que ya está.
///
/// Muestra los tres niveles con lo que hace cada uno: horas, hasta qué nivel
/// junta y cuántas acciones hace por hora. Sin eso, elegir entre tres precios
/// sería adivinar.
class _WorkerCard extends ConsumerStatefulWidget {
  const _WorkerCard({
    required this.state,
    required this.engine,
    required this.controller,
  });

  final GameState state;
  final GameEngine engine;
  final GameController controller;

  @override
  ConsumerState<_WorkerCard> createState() => _WorkerCardState();
}

class _WorkerCardState extends ConsumerState<_WorkerCard> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final GameState state = widget.state;
    final bool locked = state.shopLevel < Workers.unlockShopLevel;
    final DateTime now = DateTime.now();
    final bool busy = widget.engine.hasWorkerAt(state, now);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.badge_outlined, color: context.palette.wood),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.workerTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(l.workerSub, style: Theme.of(context).textTheme.bodySmall),
            if (busy) ...<Widget>[
              const SizedBox(height: 8),
              // Cuánto le queda al que ya está. Se recalcula con el reloj de
              // la pantalla, así que baja a la vista.
              ClockBuilder(
                builder: (BuildContext context, DateTime tick) {
                  final Duration left = state.workerUntil!.difference(tick);
                  final int h = left.inHours;
                  final int m = left.inMinutes % 60;
                  return Text(
                    l.workerBusyUntil('${h}h ${m}m'),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: context.palette.success,
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            if (locked)
              OutlinedButton(onPressed: null, child: Text(l.workerLockedMsg))
            else
              for (final WorkerTier tier in Workers.all)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              l.workerLevel(tier.level),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              l.workerDetail(
                                tier.hours,
                                tier.maxMergeLevel,
                                tier.actionsPerHour,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: AppTheme.minTouchTarget,
                        child: FilledButton(
                          onPressed: state.coins >= tier.hireCost
                              ? () => widget.controller.hireWorker(tier.level)
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: context.palette.wood,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(
                            busy
                                ? l.workerExtend(tier.hireCost)
                                : l.workerHire(tier.hireCost),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
