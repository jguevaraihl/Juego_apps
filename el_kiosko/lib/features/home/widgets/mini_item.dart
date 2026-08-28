import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/models/product.dart';
import 'chain_visuals.dart';

/// Una ficha chiquita, con el mismo aspecto que las del tablero.
///
/// Existe para que un pedido se pueda **reconocer de un vistazo** contra el
/// tablero. Antes la línea del pedido era texto y un ícono suelto, y el nivel
/// no se veía en ninguna parte: había que leer "Botella grande" y traducirlo
/// mentalmente a cuál de las fichas de la grilla era. Eso es lo que hacía que
/// el juego se sintiera una planilla de cálculo.
///
/// Ahora la línea muestra la misma pieza que hay que juntar —mismo color,
/// mismo ícono, mismo número— y el ojo hace la comparación sin pensar.
class MiniItem extends StatelessWidget {
  const MiniItem({
    required this.chainId,
    required this.level,
    this.size = 30,
    this.faded = false,
    super.key,
  });

  final String chainId;
  final int level;
  final double size;

  /// Apagada mientras el jugador todavía no tiene la pieza.
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final ChainVisual visual = ChainVisuals.of(chainId);
    final ProductChain chain = ProductCatalog.byId(chainId);
    // El relleno se satura con el nivel, igual que en el tablero: dos piezas
    // de la misma cadena se distinguen también por tono, no sólo por número.
    final double t = chain.maxLevel > 1
        ? (level - 1) / (chain.maxLevel - 1)
        : 1.0;
    final Color base = Color.lerp(
      visual.color.withValues(alpha: 0.20),
      visual.color.withValues(alpha: 0.85),
      t,
    )!;

    return Opacity(
      opacity: faded ? 0.45 : 1,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(size * 0.26),
                border: Border.all(color: visual.color.withValues(alpha: 0.55)),
              ),
              child: Icon(
                visual.icon,
                size: size * 0.56,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3.5),
                decoration: BoxDecoration(
                  color: AppTheme.brandWoodDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.palette.paper, width: 1),
                ),
                child: Text(
                  '$level',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.34,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
