import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../game/models/game_state.dart';
import '../../game/models/product.dart';
import '../../l10n/app_localizations.dart';
import '../common/game_strings.dart';
import '../home/widgets/chain_visuals.dart';

/// Álbum de productos: retención por colección, sin costo de mantenimiento.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState? state = ref.watch(gameControllerProvider).state;
    if (state == null) return const Scaffold();

    final AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.collectionTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Text(
            l.collectionProgress(
              state.discovered.length,
              ProductCatalog.totalProducts,
            ),
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
    final AppLocalizations l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(visual.icon, color: visual.color),
            const SizedBox(width: 8),
            Text(
              l.chainName(chain.id),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final int level in chain.levels)
          _TierRow(
            chainId: chain.id,
            level: level,
            found: discovered.contains('${chain.id}:$level'),
            color: visual.color,
            icon: visual.icon,
          ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.chainId,
    required this.level,
    required this.found,
    required this.color,
    required this.icon,
  });

  final String chainId;
  final int level;
  final bool found;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final String name = l.productName(chainId, level);

    return Semantics(
      label: found
          ? l.collectionFoundSemantics(name)
          : l.collectionMissingSemantics(level),
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
                    : context.palette.wood.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: found
                      ? color.withValues(alpha: 0.5)
                      : context.palette.wood.withValues(alpha: 0.18),
                ),
              ),
              child: Icon(
                found ? icon : Icons.help_outline,
                size: 20,
                color: found
                    ? color
                    : context.palette.inkSoft.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                found ? name : l.collectionUnknown,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: found ? context.palette.ink : context.palette.inkSoft,
                ),
              ),
            ),
            Text(
              l.collectionLevel(level),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
