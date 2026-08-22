/// Escalera de progreso visual del local (PLAN_FINAL §3.6).
///
/// Sin textos: los nombres y frases viven en lib/l10n y se resuelven en la UI.
/// Cada nivel cambia la fachada dibujada en pantalla.
class ShopTier {
  const ShopTier({
    required this.level,
    required this.upgradeCost,
    required this.coinsPerHour,
    required this.shelves,
    required this.customers,
  });

  final int level;

  /// Costo para pasar a este nivel. El nivel 1 es el punto de partida.
  final int upgradeCost;

  /// Ganancia pasiva por hora en este nivel.
  final int coinsPerHour;

  /// Elementos dibujados en la fachada.
  final int shelves;
  final int customers;
}

class ShopTiers {
  const ShopTiers._();

  static const List<ShopTier> all = <ShopTier>[
    ShopTier(
      level: 1,
      upgradeCost: 0,
      coinsPerHour: 12,
      shelves: 1,
      customers: 1,
    ),
    ShopTier(
      level: 2,
      upgradeCost: 150,
      coinsPerHour: 30,
      shelves: 2,
      customers: 2,
    ),
    ShopTier(
      level: 3,
      upgradeCost: 600,
      coinsPerHour: 70,
      shelves: 3,
      customers: 3,
    ),
    ShopTier(
      level: 4,
      upgradeCost: 2000,
      coinsPerHour: 160,
      shelves: 4,
      customers: 4,
    ),
    ShopTier(
      level: 5,
      upgradeCost: 6000,
      coinsPerHour: 360,
      shelves: 5,
      customers: 5,
    ),
    ShopTier(
      level: 6,
      upgradeCost: 18000,
      coinsPerHour: 800,
      shelves: 6,
      customers: 6,
    ),
    ShopTier(
      level: 7,
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
