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
    required this.onGenerateAll,
    required this.sellMode,
    required this.onToggleSell,
    required this.onOpenMarket,
    required this.sortCost,
    required this.canSort,
    required this.onSort,
    super.key,
  });

  final int cost;
  final bool canAfford;
  final bool boardFull;
  final VoidCallback onGenerate;

  /// Mantener apretado llena el tablero de una vez.
  final VoidCallback onGenerateAll;
  final bool sellMode;
  final VoidCallback onToggleSell;
  final VoidCallback onOpenMarket;

  /// Lo que cuesta acomodar la mercadería; 0 si ya se compró la mejora.
  final int sortCost;
  final bool canSort;
  final VoidCallback onSort;

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
              label: '${l.supplierSemantics(hint)}. ${l.supplierHold}',
              child: SizedBox(
                height: _height,
                child: FilledButton(
                  onPressed: enabled ? onGenerate : null,
                  // Mantener apretado llena el tablero. Va como long press y
                  // no como segundo botón porque la barra ya tiene cuatro
                  // controles y no cabe ninguno más.
                  onLongPress: enabled ? onGenerateAll : null,
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
                      // Marca discreta de que además se puede mantener
                      // apretado. El subtítulo tiene que seguir diciendo el
                      // precio, que es lo que el jugador necesita saber.
                      if (enabled)
                        const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Icon(Icons.touch_app, size: 13),
                        ),
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
          const SizedBox(width: 6),
          _SideButton(
            icon: Icons.auto_awesome_motion,
            label: l.sort,
            // El precio va en el botón: es simbólico, pero cobrar sin decirlo
            // es cobrar a escondidas.
            sub: sortCost == 0 ? l.sortFree : '$sortCost',
            onPressed: canSort ? onSort : null,
          ),
          const SizedBox(width: 6),
          _SideButton(
            icon: Icons.add_shopping_cart,
            label: l.buy,
            onPressed: onOpenMarket,
          ),
          const SizedBox(width: 6),
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
    this.sub,
    this.active = false,
  });

  final IconData icon;
  final String label;

  /// Segunda línea opcional, para el precio.
  final String? sub;

  /// null deja el botón apagado.
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Color tint = !enabled
        ? context.palette.inkSoft.withValues(alpha: 0.5)
        : (active ? context.palette.success : context.palette.woodDark);

    return SizedBox(
      height: GeneratorBar._height,
      // Angosto a propósito: con tres botones al lado de la caja del
      // proveedor, el ancho es lo único que sobra. A 62 px la etiqueta del
      // proveedor se cortaba en español.
      width: 57,
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
            Icon(icon, size: 21, color: tint),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: tint,
                height: 1.1,
              ),
            ),
            if (sub != null)
              Text(
                sub!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: tint.withValues(alpha: 0.85),
                  height: 1.1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
