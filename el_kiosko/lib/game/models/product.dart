/// Catálogo de productos. Dart puro: sin dependencias de Flutter, para que la
/// lógica de juego sea testeable sin binding.
///
/// El catálogo **no contiene textos**: sólo identificadores y números. Los
/// nombres visibles viven en lib/l10n y se resuelven en la capa de UI
/// (features/common/game_strings.dart). Así el mismo save funciona en
/// cualquier idioma y cambiar de idioma no reescribe la partida.
library;

/// Una cadena de productos (panadería, bebidas, snacks...).
class ProductChain {
  const ProductChain({
    required this.id,
    required this.maxLevel,
    required this.unlockPlayerLevel,
  });

  /// Identificador estable. Se persiste en el save y se envía a analytics.
  final String id;

  final int maxLevel;

  /// Nivel de jugador a partir del cual la cadena aparece en el generador y
  /// en los pedidos.
  final int unlockPlayerLevel;

  /// Niveles válidos de la cadena, de 1 a [maxLevel].
  Iterable<int> get levels =>
      Iterable<int>.generate(maxLevel, (int i) => i + 1);

  bool hasLevel(int level) => level >= 1 && level <= maxLevel;
}

/// Catálogo del MVP: 3 cadenas × 5 niveles.
class ProductCatalog {
  const ProductCatalog._();

  static const String panaderia = 'panaderia';
  static const String bebidas = 'bebidas';
  static const String snacks = 'snacks';

  static const List<ProductChain> chains = <ProductChain>[
    ProductChain(id: panaderia, maxLevel: 5, unlockPlayerLevel: 1),
    ProductChain(id: bebidas, maxLevel: 5, unlockPlayerLevel: 1),
    ProductChain(id: snacks, maxLevel: 5, unlockPlayerLevel: 2),
  ];

  /// Total de productos distintos, para el contador del álbum.
  static int get totalProducts =>
      chains.fold(0, (int sum, ProductChain c) => sum + c.maxLevel);

  static ProductChain byId(String id) =>
      chains.firstWhere((ProductChain c) => c.id == id);

  static bool exists(String id) => chains.any((ProductChain c) => c.id == id);

  /// Cadenas disponibles para un nivel de jugador dado.
  static List<ProductChain> unlockedFor(int playerLevel) => chains
      .where((ProductChain c) => c.unlockPlayerLevel <= playerLevel)
      .toList(growable: false);
}
