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
    this.rewardMultiplier = 1.0,
    this.requiresPet = false,
  });

  /// Identificador estable. Se persiste en el save y se envía a analytics.
  final String id;

  final int maxLevel;

  /// Nivel de jugador a partir del cual la cadena aparece en el generador y
  /// en los pedidos.
  final int unlockPlayerLevel;

  /// Cuánto paga esta cadena respecto de las demás.
  ///
  /// Por encima de 1 sólo para el alimento de mascotas: es un rubro caro en un
  /// almacén de verdad, y darle un margen mejor premia al jugador que se tomó
  /// el trabajo de tener mascota. **Multiplica también el precio de compra**,
  /// para que siga siendo imposible comprar y entregar con ganancia.
  final double rewardMultiplier;

  /// Sólo aparece si el jugador tiene mascota en el local.
  ///
  /// Es lo que le da sentido a la mascota: deja de ser un adorno y abre un
  /// rubro nuevo.
  final bool requiresPet;

  /// Niveles válidos de la cadena, de 1 a [maxLevel].
  Iterable<int> get levels =>
      Iterable<int>.generate(maxLevel, (int i) => i + 1);

  bool hasLevel(int level) => level >= 1 && level <= maxLevel;
}

/// El catálogo del almacén.
class ProductCatalog {
  const ProductCatalog._();

  static const String panaderia = 'panaderia';
  static const String bebidas = 'bebidas';
  static const String snacks = 'snacks';
  static const String huevos = 'huevos';
  static const String aseo = 'aseo';
  static const String mascotas = 'mascotas';
  static const String frutas = 'frutas';
  static const String lacteos = 'lacteos';
  static const String congelados = 'congelados';
  static const String libreria = 'libreria';

  /// Las cadenas **no tienen todas la misma cantidad de niveles**.
  ///
  /// Una cadena corta se completa rápido y da una sensación de logro temprana;
  /// una larga sostiene el juego a la larga. Mezclarlas evita que todo el
  /// catálogo se sienta igual, y hace que el álbum tenga ritmos distintos.
  ///
  /// Las que se desbloquean tarde agregan profundidad justo cuando el jugador
  /// ya domina el loop, que es donde el juego se empezaba a aplanar.
  /// Diez rubros, de 3 a 8 niveles, repartidos a lo largo de toda la partida.
  ///
  /// El calendario de desbloqueo es tan importante como el contenido: hay algo
  /// nuevo que descubrir en los niveles 1, 2, 4, 5, 6, 8, 11, 14 y 18, así que
  /// ninguna franja larga de la progresión se juega con el catálogo cerrado.
  /// Antes las cinco cadenas se abrían todas antes del nivel 6 y de ahí en
  /// adelante el juego no volvía a mostrar nada nuevo.
  static const List<ProductChain> chains = <ProductChain>[
    ProductChain(id: panaderia, maxLevel: 6, unlockPlayerLevel: 1),
    ProductChain(id: bebidas, maxLevel: 6, unlockPlayerLevel: 1),
    ProductChain(id: snacks, maxLevel: 6, unlockPlayerLevel: 2),
    ProductChain(id: huevos, maxLevel: 3, unlockPlayerLevel: 4),
    ProductChain(
      id: mascotas,
      maxLevel: 5,
      unlockPlayerLevel: 5,
      rewardMultiplier: 1.35,
      requiresPet: true,
    ),
    ProductChain(id: aseo, maxLevel: 5, unlockPlayerLevel: 6),
    ProductChain(id: frutas, maxLevel: 4, unlockPlayerLevel: 8),
    ProductChain(id: lacteos, maxLevel: 7, unlockPlayerLevel: 11),
    ProductChain(
      id: congelados,
      maxLevel: 8,
      unlockPlayerLevel: 14,
      // El rubro más caro y más largo del almacén, y el último que se abre:
      // es la meta de contenido de la segunda mitad de la partida.
      rewardMultiplier: 1.2,
    ),
    ProductChain(id: libreria, maxLevel: 5, unlockPlayerLevel: 18),
  ];

  /// Total de productos distintos, para el contador del álbum.
  static int get totalProducts =>
      chains.fold(0, (int sum, ProductChain c) => sum + c.maxLevel);

  static ProductChain byId(String id) =>
      chains.firstWhere((ProductChain c) => c.id == id);

  static bool exists(String id) => chains.any((ProductChain c) => c.id == id);

  /// Cadenas disponibles para un nivel de jugador dado.
  ///
  /// [hasPet] abre el rubro de alimento para mascotas. Se pasa explícito y no
  /// se lee de ningún lado: el catálogo es Dart puro y no conoce el estado.
  static List<ProductChain> unlockedFor(
    int playerLevel, {
    bool hasPet = false,
  }) => chains
      .where(
        (ProductChain c) =>
            c.unlockPlayerLevel <= playerLevel && (!c.requiresPet || hasPet),
      )
      .toList(growable: false);
}
