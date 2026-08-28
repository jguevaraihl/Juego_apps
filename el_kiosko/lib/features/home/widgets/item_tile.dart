import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/board_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/game_strings.dart';
import 'chain_visuals.dart';

/// Ficha de producto. Arte placeholder (PLAN_FINAL §17): formas simples
/// dibujadas en código, sin assets con licencia pendiente.
///
/// Identificación por tres canales: color de cadena, ícono de silueta y
/// número de nivel. Además lleva `Semantics` con el nombre real del producto.
class ItemTile extends StatelessWidget {
  const ItemTile({
    required this.item,
    this.size = 56,
    this.highlighted = false,
    this.dimmed = false,
    this.sellValue,
    super.key,
  });

  final BoardItem item;
  final double size;

  /// Se resalta cuando la pista de inactividad lo señala.
  final bool highlighted;

  /// Atenuado mientras se arrastra la pieza original.
  final bool dimmed;

  /// Si no es null, se muestra el precio de venta (modo vender).
  final int? sellValue;

  @override
  Widget build(BuildContext context) {
    final ChainVisual visual = ChainVisuals.of(item.chainId);
    final double t = (item.level - 1) / (item.chain.maxLevel - 1);
    final Color base = Color.lerp(
      visual.color.withValues(alpha: 0.20),
      visual.color.withValues(alpha: 0.85),
      t,
    )!;

    final AppLocalizations l = AppLocalizations.of(context);

    return Semantics(
      label: l.itemSemantics(l.itemName(item), item.level),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: dimmed ? 0.35 : 1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(size * 0.24),
            border: Border.all(
              color: highlighted
                  ? context.palette.awning
                  : visual.color.withValues(alpha: 0.55),
              width: highlighted ? 3 : 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Center(
                child: Icon(
                  visual.icon,
                  size: size * 0.58,
                  color: t > 0.45 ? Colors.white : visual.color,
                ),
              ),
              // Insignia de nivel: el dato crítico, siempre legible.
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.brandWoodDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.level}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: size * 0.21,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              if (sellValue != null)
                Positioned(
                  left: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.brandSuccess,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+$sellValue',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: size * 0.20,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
