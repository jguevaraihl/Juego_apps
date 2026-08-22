import 'package:flutter/material.dart';

import '../../../game/models/product.dart';

/// Silueta de cada cadena. Junto con el color y la etiqueta de texto, da tres
/// canales distintos para identificar un producto: nunca solo color.
enum ChainShape { loaf, bottle, candy }

class ChainVisual {
  const ChainVisual({
    required this.color,
    required this.shape,
    required this.icon,
  });

  final Color color;
  final ChainShape shape;
  final IconData icon;
}

/// Mapa presentación ↔ catálogo. Vive en la capa de UI a propósito: el
/// catálogo de productos es Dart puro y no debe conocer colores.
class ChainVisuals {
  const ChainVisuals._();

  static const Map<String, ChainVisual> _byChain = <String, ChainVisual>{
    ProductCatalog.panaderia: ChainVisual(
      color: Color(0xFFD97706),
      shape: ChainShape.loaf,
      icon: Icons.bakery_dining,
    ),
    ProductCatalog.bebidas: ChainVisual(
      color: Color(0xFF0369A1),
      shape: ChainShape.bottle,
      icon: Icons.local_drink,
    ),
    ProductCatalog.snacks: ChainVisual(
      color: Color(0xFF9333EA),
      shape: ChainShape.candy,
      icon: Icons.cookie,
    ),
    ProductCatalog.huevos: ChainVisual(
      color: Color(0xFFB45309),
      shape: ChainShape.loaf,
      icon: Icons.egg,
    ),
    ProductCatalog.aseo: ChainVisual(
      color: Color(0xFF0F766E),
      shape: ChainShape.bottle,
      icon: Icons.cleaning_services,
    ),
  };

  static ChainVisual of(String chainId) =>
      _byChain[chainId] ??
      const ChainVisual(
        color: Color(0xFF57534E),
        shape: ChainShape.candy,
        icon: Icons.inventory_2,
      );
}
