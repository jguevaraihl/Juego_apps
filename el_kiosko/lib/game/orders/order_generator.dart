import 'dart:math';

import '../economy/economy.dart';
import '../models/order.dart';
import '../models/product.dart';

/// Genera pedidos. Recibe el [Random] desde fuera para que los tests sean
/// deterministas.
class OrderGenerator {
  const OrderGenerator({required this.economy});

  final Economy economy;

  /// Cantidad de clientes del catálogo. Los nombres viven en lib/l10n
  /// (claves customer0..customer11) y son oficios y roles cotidianos, no
  /// caricaturas ni estereotipos (PLAN_FINAL §5).
  static const int customerCount = 12;

  /// Cuántas líneas tiene un pedido, según el nivel de jugador.
  int _lineCount(int playerLevel, Random rng) {
    if (playerLevel < 3) return 1;
    return rng.nextInt(100) < 30 ? 2 : 1;
  }

  /// Nivel pedido: se favorece el nivel más alto desbloqueado, pero se mantiene
  /// variedad para que el tablero exija decisiones y no "fusionar todo".
  int _pickLevel(int maxLevel, Random rng) {
    if (maxLevel <= 1) return 1;
    // Ventana de hasta 3 niveles bajo el techo, con sesgo hacia arriba.
    final int floor = max(1, maxLevel - 2);
    final int span = maxLevel - floor + 1;
    final int roll = rng.nextInt(span * (span + 1) ~/ 2);
    int acc = 0;
    for (int i = 0; i < span; i++) {
      acc += i + 1;
      if (roll < acc) return floor + i;
    }
    return maxLevel;
  }

  int _pickQuantity(int level, Random rng) {
    if (level <= 2) return 1 + rng.nextInt(2);
    return 1;
  }

  CustomerOrder generate({
    required int id,
    required int playerLevel,
    required Random rng,
    DateTime? bonusUntil,
    bool? forceSpecial,
  }) {
    final List<ProductChain> unlocked = ProductCatalog.unlockedFor(playerLevel);
    final int lines = _lineCount(playerLevel, rng);
    final List<OrderLine> orderLines = <OrderLine>[];
    final Set<String> usedKeys = <String>{};

    for (int i = 0; i < lines; i++) {
      final ProductChain chain = unlocked[rng.nextInt(unlocked.length)];
      final int maxLevel = economy.maxOrderLevel(playerLevel, chain.maxLevel);
      final int level = _pickLevel(maxLevel, rng);
      final String key = '${chain.id}:$level';
      if (!usedKeys.add(key)) continue;
      orderLines.add(
        OrderLine(
          chainId: chain.id,
          level: level,
          quantity: _pickQuantity(level, rng),
        ),
      );
    }

    // Nunca devolver un pedido vacío.
    if (orderLines.isEmpty) {
      final ProductChain chain = unlocked.first;
      orderLines.add(OrderLine(chainId: chain.id, level: 1, quantity: 1));
    }

    final int requestedValue = orderLines.fold(
      0,
      (int sum, OrderLine l) => sum + economy.itemValue(l.level) * l.quantity,
    );
    final bool special = forceSpecial ?? (rng.nextInt(100) < 18);

    return CustomerOrder(
      id: id,
      customerId: rng.nextInt(customerCount),
      lines: orderLines,
      reward: economy.orderReward(requestedValue),
      xp: economy.orderXp(
        orderLines.fold(0, (int s, OrderLine l) => s + l.levelUnits),
      ),
      isSpecial: special,
      bonusUntil: bonusUntil,
    );
  }

  /// El pedido mayorista: grande, caro y con fecha de vencimiento.
  ///
  /// Se arma con cadenas distintas y cantidades altas —no es "un pedido normal
  /// con más plata"— porque lo que lo hace un evento es tener que vaciar medio
  /// tablero de una vez. Paga por encima de lo proporcional
  /// ([EconomyConfig.bigOrderMultiplier]): ese sobreprecio es la recompensa
  /// por el desafío, no un regalo.
  CustomerOrder generateBig({
    required int id,
    required int playerLevel,
    required Random rng,
    required DateTime expiresAt,
  }) {
    final List<ProductChain> unlocked = ProductCatalog.unlockedFor(playerLevel);
    final List<OrderLine> orderLines = <OrderLine>[];
    final Set<String> usedChains = <String>{};

    // Una línea por cadena distinta: obliga a mirar todo el tablero.
    final List<ProductChain> pool = List<ProductChain>.of(unlocked)
      ..shuffle(rng);
    for (final ProductChain chain in pool) {
      if (orderLines.length >= economy.config.bigOrderLines) break;
      if (!usedChains.add(chain.id)) continue;
      final int maxLevel = economy.maxOrderLevel(playerLevel, chain.maxLevel);
      // Un escalón por debajo del tope habitual: el volumen ya es el desafío,
      // pedir además el nivel más alto lo volvería imposible.
      final int level = maxLevel <= 1 ? 1 : 1 + rng.nextInt(maxLevel);
      orderLines.add(
        OrderLine(
          chainId: chain.id,
          level: level,
          quantity: 2 + rng.nextInt(3),
        ),
      );
    }

    if (orderLines.isEmpty) {
      orderLines.add(
        OrderLine(chainId: unlocked.first.id, level: 1, quantity: 3),
      );
    }

    final int requestedValue = orderLines.fold(
      0,
      (int sum, OrderLine l) => sum + economy.itemValue(l.level) * l.quantity,
    );

    return CustomerOrder(
      id: id,
      customerId: rng.nextInt(customerCount),
      lines: orderLines,
      reward:
          (economy.orderReward(requestedValue) *
                  economy.config.bigOrderMultiplier)
              .round(),
      xp:
          economy.orderXp(
            orderLines.fold(0, (int s, OrderLine l) => s + l.levelUnits),
          ) *
          2,
      isBig: true,
      expiresAt: expiresAt,
    );
  }
}
