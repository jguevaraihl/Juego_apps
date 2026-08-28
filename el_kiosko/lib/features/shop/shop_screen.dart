import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../game/game_controller.dart';
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
