import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../game/game_controller.dart';
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
                  const Icon(Icons.payments, size: 18, color: AppTheme.coin),
                  const SizedBox(width: 4),
                  Text(
                    '${state.coins}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.coin,
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
          ),
          const SizedBox(height: 12),
          Text(
            l.shopTierName(state.shopLevel),
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
                          backgroundColor: AppTheme.wood,
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
                    ? AppTheme.success
                    : AppTheme.inkSoft,
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
          Text('$from', style: const TextStyle(color: AppTheme.inkSoft)),
          const Icon(Icons.arrow_right_alt, size: 18, color: AppTheme.inkSoft),
          Text(
            '$to',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}
