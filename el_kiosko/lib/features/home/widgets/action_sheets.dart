import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/economy/economy.dart';
import '../../../game/models/board_item.dart';
import '../../../game/models/game_state.dart';
import '../../../game/models/product.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/game_strings.dart';
import 'chain_visuals.dart';
import 'item_tile.dart';

Widget _sheetTitle(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
  child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
);

/// Comprar mercadería ya hecha.
///
/// Sólo se ofrecen niveles que el jugador ya produjo al menos una vez: el
/// mercado acompaña al progreso, no lo saltea. Y el precio siempre está por
/// encima de lo que paga un pedido del mismo nivel, así que comprar es un
/// atajo, nunca un atajo *rentable*.
class MarketSheet extends StatelessWidget {
  const MarketSheet({
    required this.state,
    required this.economy,
    required this.onBuy,
    super.key,
  });

  final GameState state;
  final Economy economy;
  final void Function(String chainId, int level) onBuy;

  static Future<void> show(
    BuildContext context, {
    required GameState state,
    required Economy economy,
    required void Function(String chainId, int level) onBuy,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: context.palette.paper,
    builder: (BuildContext context) =>
        MarketSheet(state: state, economy: economy, onBuy: onBuy),
  );

  /// Nivel más alto que el jugador ya descubrió en una cadena.
  int _highestDiscovered(String chainId) {
    int best = 0;
    for (final String key in state.discovered) {
      final List<String> parts = key.split(':');
      if (parts.length == 2 && parts.first == chainId) {
        final int level = int.tryParse(parts.last) ?? 0;
        if (level > best) best = level;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final int playerLevel = state.playerLevel(economy);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sheetTitle(context, l.marketTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                l.marketNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                children: <Widget>[
                  for (final ProductChain chain in ProductCatalog.unlockedFor(
                    playerLevel,
                  ))
                    ..._chainRows(context, l, chain),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _chainRows(
    BuildContext context,
    AppLocalizations l,
    ProductChain chain,
  ) {
    final int highest = _highestDiscovered(chain.id);
    // Comprar nivel 1 nunca conviene frente a la caja del proveedor, así que
    // el mercado parte en el nivel 2.
    if (highest < 2) return const <Widget>[];

    return <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
        child: Row(
          children: <Widget>[
            Icon(
              ChainVisuals.of(chain.id).icon,
              size: 18,
              color: ChainVisuals.of(chain.id).color,
            ),
            const SizedBox(width: 8),
            Text(
              l.chainName(chain.id),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
      for (int level = 2; level <= highest; level++)
        _BuyRow(
          item: BoardItem(id: -level, chainId: chain.id, level: level),
          price: economy.buyPrice(level),
          affordable: state.coins >= economy.buyPrice(level),
          boardFull: state.board.isFull,
          onBuy: () {
            onBuy(chain.id, level);
            Navigator.of(context).pop();
          },
        ),
    ];
  }
}

class _BuyRow extends StatelessWidget {
  const _BuyRow({
    required this.item,
    required this.price,
    required this.affordable,
    required this.boardFull,
    required this.onBuy,
  });

  final BoardItem item;
  final int price;
  final bool affordable;
  final bool boardFull;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool enabled = affordable && !boardFull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: <Widget>[
          ItemTile(item: item, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l.productName(item.chainId, item.level),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: enabled ? onBuy : null,
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.wood,
              minimumSize: const Size(0, AppTheme.minTouchTarget),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: Text(l.buyFor(price)),
          ),
        ],
      ),
    );
  }
}

/// Acciones sobre una ficha del tablero: separarla o venderla.
class ItemActionsSheet extends StatelessWidget {
  const ItemActionsSheet({
    required this.item,
    required this.economy,
    required this.coins,
    required this.hasFreeCell,
    required this.onSplit,
    required this.onSell,
    super.key,
  });

  final BoardItem item;
  final Economy economy;
  final int coins;
  final bool hasFreeCell;
  final VoidCallback onSplit;
  final VoidCallback onSell;

  static Future<void> show(
    BuildContext context, {
    required BoardItem item,
    required Economy economy,
    required int coins,
    required bool hasFreeCell,
    required VoidCallback onSplit,
    required VoidCallback onSell,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.palette.paper,
    builder: (BuildContext context) => ItemActionsSheet(
      item: item,
      economy: economy,
      coins: coins,
      hasFreeCell: hasFreeCell,
      onSplit: onSplit,
      onSell: onSell,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final String name = l.productName(item.chainId, item.level);
    final bool splittable = item.level > 1;
    final int splitPrice = economy.splitCost(item.level);
    final bool canSplit = splittable && hasFreeCell && coins >= splitPrice;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: <Widget>[
                  ItemTile(item: item, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.itemActionsTitle(name, item.level),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              enabled: canSplit,
              leading: const Icon(Icons.call_split),
              title: Text(l.splitAction),
              subtitle: Text(
                splittable
                    ? l.splitInto(
                        l.productName(item.chainId, item.level - 1),
                        splitPrice,
                      )
                    : l.splitNotPossible,
              ),
              onTap: canSplit
                  ? () {
                      onSplit();
                      Navigator.of(context).pop();
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.sell_outlined),
              title: Text(l.sell),
              subtitle: Text(l.toastSold(economy.sellValue(item.level))),
              onTap: () {
                onSell();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmación para desbloquear una fila más del tablero.
class ExpandSheet extends StatelessWidget {
  const ExpandSheet({
    required this.cost,
    required this.columns,
    required this.affordable,
    required this.atMaxSize,
    required this.onExpand,
    super.key,
  });

  final int cost;
  final int columns;
  final bool affordable;
  final bool atMaxSize;
  final VoidCallback onExpand;

  static Future<void> show(
    BuildContext context, {
    required int cost,
    required int columns,
    required bool affordable,
    required bool atMaxSize,
    required VoidCallback onExpand,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.palette.paper,
    builder: (BuildContext context) => ExpandSheet(
      cost: cost,
      columns: columns,
      affordable: affordable,
      atMaxSize: atMaxSize,
      onExpand: onExpand,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              atMaxSize ? l.boardMaxSize : l.expandTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            if (!atMaxSize)
              Text(
                l.expandBody(columns),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 18),
            if (!atMaxSize)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: affordable
                      ? () {
                          onExpand();
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.palette.wood,
                  ),
                  icon: const Icon(Icons.open_in_full),
                  label: Text(l.expandFor(cost)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
