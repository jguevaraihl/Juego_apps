/// Catálogo de productos. Dart puro: sin dependencias de Flutter, para que la
/// lógica de juego sea testeable sin binding.
///
/// Los nombres son genéricos y culturalmente reconocibles. No se usan marcas
/// registradas, alcohol ni tabaco (ver PLAN_FINAL §3.4 y §5).
library;

/// Un nivel dentro de una cadena. Cada merge sube un nivel y representa
/// "más cantidad / mejor presentación / mayor valor".
class ProductTier {
  const ProductTier({required this.level, required this.name});

  final int level;
  final String name;
}

/// Una cadena de productos (panadería, bebidas, snacks...).
class ProductChain {
  const ProductChain({
    required this.id,
    required this.name,
    required this.tiers,
    required this.unlockPlayerLevel,
  });

  final String id;
  final String name;
  final List<ProductTier> tiers;

  /// Nivel de jugador a partir del cual la cadena aparece en el generador y
  /// en los pedidos.
  final int unlockPlayerLevel;

  int get maxLevel => tiers.length;

  ProductTier tier(int level) {
    assert(level >= 1 && level <= maxLevel, 'nivel $level fuera de rango');
    return tiers[level - 1];
  }

  String tierName(int level) => tier(level).name;
}

/// Catálogo del MVP: 3 cadenas × 5 niveles.
class ProductCatalog {
  const ProductCatalog._();

  static const String panaderia = 'panaderia';
  static const String bebidas = 'bebidas';
  static const String snacks = 'snacks';

  static const List<ProductChain> chains = <ProductChain>[
    ProductChain(
      id: panaderia,
      name: 'Panadería',
      unlockPlayerLevel: 1,
      tiers: <ProductTier>[
        ProductTier(level: 1, name: 'Marraqueta'),
        ProductTier(level: 2, name: 'Bolsa de pan'),
        ProductTier(level: 3, name: 'Canasto de pan'),
        ProductTier(level: 4, name: 'Bandeja surtida'),
        ProductTier(level: 5, name: 'Vitrina de pan'),
      ],
    ),
    ProductChain(
      id: bebidas,
      name: 'Bebidas',
      unlockPlayerLevel: 1,
      tiers: <ProductTier>[
        ProductTier(level: 1, name: 'Vaso'),
        ProductTier(level: 2, name: 'Botella chica'),
        ProductTier(level: 3, name: 'Botella grande'),
        ProductTier(level: 4, name: 'Pack de bebidas'),
        ProductTier(level: 5, name: 'Refrigerador'),
      ],
    ),
    ProductChain(
      id: snacks,
      name: 'Snacks',
      unlockPlayerLevel: 2,
      tiers: <ProductTier>[
        ProductTier(level: 1, name: 'Dulce'),
        ProductTier(level: 2, name: 'Bolsita'),
        ProductTier(level: 3, name: 'Paquete'),
        ProductTier(level: 4, name: 'Caja surtida'),
        ProductTier(level: 5, name: 'Estante de snacks'),
      ],
    ),
  ];

  static ProductChain byId(String id) =>
      chains.firstWhere((ProductChain c) => c.id == id);

  static bool exists(String id) => chains.any((ProductChain c) => c.id == id);

  /// Cadenas disponibles para un nivel de jugador dado.
  static List<ProductChain> unlockedFor(int playerLevel) => chains
      .where((ProductChain c) => c.unlockPlayerLevel <= playerLevel)
      .toList(growable: false);
}
