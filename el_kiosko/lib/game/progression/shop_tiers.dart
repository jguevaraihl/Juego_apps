/// Escalera de progreso visual del local (PLAN_FINAL §3.6).
///
/// Cada nivel cambia la fachada y agrega elementos visibles. El costo del
/// nivel 2 está calibrado para ser alcanzable en los primeros 3–5 minutos.
class ShopTier {
  const ShopTier({
    required this.level,
    required this.name,
    required this.tagline,
    required this.upgradeCost,
    required this.coinsPerHour,
    required this.shelves,
    required this.customers,
  });

  final int level;
  final String name;
  final String tagline;

  /// Costo para pasar a este nivel. El nivel 1 es el punto de partida.
  final int upgradeCost;

  /// Ganancia pasiva por hora en este nivel.
  final int coinsPerHour;

  /// Elementos dibujados en la fachada: cantidad de estantes y de clientes.
  final int shelves;
  final int customers;
}

class ShopTiers {
  const ShopTiers._();

  static const List<ShopTier> all = <ShopTier>[
    ShopTier(
      level: 1,
      name: 'Mesón improvisado',
      tagline: 'Una tabla, dos cajones y muchas ganas.',
      upgradeCost: 0,
      coinsPerHour: 12,
      shelves: 1,
      customers: 1,
    ),
    ShopTier(
      level: 2,
      name: 'Kiosko',
      tagline: 'Ya tienes techo y una ventanilla.',
      upgradeCost: 150,
      coinsPerHour: 30,
      shelves: 2,
      customers: 2,
    ),
    ShopTier(
      level: 3,
      name: 'Almacén chico',
      tagline: 'Entra un cliente a la vez, pero entra.',
      upgradeCost: 600,
      coinsPerHour: 70,
      shelves: 3,
      customers: 3,
    ),
    ShopTier(
      level: 4,
      name: 'Almacén de barrio',
      tagline: 'Te saludan por el nombre.',
      upgradeCost: 2000,
      coinsPerHour: 160,
      shelves: 4,
      customers: 4,
    ),
    ShopTier(
      level: 5,
      name: 'Minimarket',
      tagline: 'Refrigerador propio y letrero iluminado.',
      upgradeCost: 6000,
      coinsPerHour: 360,
      shelves: 5,
      customers: 5,
    ),
    ShopTier(
      level: 6,
      name: 'Local renovado',
      tagline: 'Piso nuevo, vitrinas y fila en la caja.',
      upgradeCost: 18000,
      coinsPerHour: 800,
      shelves: 6,
      customers: 6,
    ),
    ShopTier(
      level: 7,
      name: 'Cadena de barrio',
      tagline: 'El almacén más querido del sector.',
      upgradeCost: 50000,
      coinsPerHour: 1800,
      shelves: 7,
      customers: 8,
    ),
  ];

  static int get maxLevel => all.length;

  static ShopTier byLevel(int level) => all[level.clamp(1, all.length) - 1];

  /// Siguiente nivel, o null si ya está al máximo.
  static ShopTier? next(int currentLevel) =>
      currentLevel >= all.length ? null : all[currentLevel];
}
