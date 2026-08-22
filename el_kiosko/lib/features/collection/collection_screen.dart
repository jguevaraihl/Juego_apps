import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../game/models/game_state.dart';
import '../../game/models/product.dart';
import '../home/widgets/chain_visuals.dart';

/// Álbum de productos: retención por colección, sin costo de mantenimiento.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState? state = ref.watch(gameControllerProvider).state;
    if (state == null) return const Scaffold();

    final int total = ProductCatalog.chains.fold(
      0,
      (int sum, ProductChain c) => sum + c.maxLevel,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Álbum del almacén')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Text(
            'Descubiertos ${state.discovered.length} de $total',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          for (final ProductChain chain in ProductCatalog.chains) ...<Widget>[
            _ChainSection(chain: chain, discovered: state.discovered),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _ChainSection extends StatelessWidget {
  const _ChainSection({required this.chain, required this.discovered});

  final ProductChain chain;
  final Set<String> discovered;

  @override
  Widget build(BuildContext context) {
    final ChainVisual visual = ChainVisuals.of(chain.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(visual.icon, color: visual.color),
            const SizedBox(width: 8),
            Text(chain.name, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        for (final ProductTier tier in chain.tiers)
          _TierRow(
            chain: chain,
            tier: tier,
            found: discovered.contains('${chain.id}:${tier.level}'),
            color: visual.color,
            icon: visual.icon,
          ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.chain,
    required this.tier,
    required this.found,
    required this.color,
    required this.icon,
  });

  final ProductChain chain;
  final ProductTier tier;
  final bool found;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: found
          ? '${tier.name}, descubierto'
          : 'Producto nivel ${tier.level} no descubierto',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: found
                    ? color.withValues(alpha: 0.20)
                    : AppTheme.wood.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: found
                      ? color.withValues(alpha: 0.5)
                      : AppTheme.wood.withValues(alpha: 0.18),
                ),
              ),
              child: Icon(
                found ? icon : Icons.help_outline,
                size: 20,
                color: found ? color : AppTheme.inkSoft.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                found ? tier.name : '???',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: found ? AppTheme.ink : AppTheme.inkSoft,
                ),
              ),
            ),
            Text(
              'Nivel ${tier.level}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
