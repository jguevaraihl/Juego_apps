import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';

/// Barra inferior: la caja del proveedor, comprar mercadería y vender.
///
/// Va abajo a propósito: son los controles que más se usan y tienen que quedar
/// al alcance del pulgar con una sola mano (PLAN_FINAL §6).
///
/// Los textos están acotados a una línea con recorte: con tres controles el
/// espacio es justo, y una etiqueta larga en un idioma cualquiera no puede
/// romper el layout.
class GeneratorBar extends StatelessWidget {
  const GeneratorBar({
    required this.cost,
    required this.canAfford,
    required this.boardFull,
    required this.onGenerate,
    required this.sellMode,
    required this.onToggleSell,
    required this.onOpenMarket,
    super.key,
  });

  final int cost;
  final bool canAfford;
  final bool boardFull;
  final VoidCallback onGenerate;
  final bool sellMode;
  final VoidCallback onToggleSell;
  final VoidCallback onOpenMarket;

  static const double _height = 62;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool enabled = canAfford && !boardFull && !sellMode;
    final String hint = boardFull
        ? l.boardFull
        : (!canAfford ? l.notEnoughCoinsShort : l.supplierCost(cost));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              button: true,
              label: l.supplierSemantics(hint),
              child: SizedBox(
                height: _height,
                child: FilledButton(
                  onPressed: enabled ? onGenerate : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.palette.wood,
                    disabledBackgroundColor: context.palette.wood.withValues(
                      alpha: 0.30,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.inventory_2, size: 24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l.supplierBox,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              hint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SideButton(
            icon: Icons.add_shopping_cart,
            label: l.buy,
            onPressed: onOpenMarket,
          ),
          const SizedBox(width: 8),
          _SideButton(
            icon: sellMode ? Icons.sell : Icons.sell_outlined,
            label: sellMode ? l.sellDone : l.sell,
            onPressed: onToggleSell,
            active: sellMode,
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color tint = active
        ? context.palette.success
        : context.palette.woodDark;

    return SizedBox(
      height: GeneratorBar._height,
      width: 68,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: active
              ? context.palette.success.withValues(alpha: 0.15)
              : null,
          side: BorderSide(
            color: active ? context.palette.success : context.palette.wood,
            width: active ? 2 : 1.5,
          ),
          padding: EdgeInsets.zero,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 22, color: tint),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: tint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
