import 'dart:math';

import '../economy/economy.dart';
import '../models/order.dart';
import '../models/product.dart';

/// Genera pedidos. Recibe el [Random] desde fuera para que los tests sean
/// deterministas.
class OrderGenerator {
  const OrderGenerator({required this.economy});

  final Economy economy;

  /// Clientes del barrio. Sin caricaturas clasistas ni estereotipos: son
  /// oficios y roles cotidianos (PLAN_FINAL §5).
  static const List<String> customers = <String>[
    'Don Chofer',
    'La vecina del 3',
    'Estudiante de la tarde',
    'Doña del kiosko',
    'El feriante',
    'Turno de noche',
    'Repartidor',
    'Don Jubilado',
    'La maestra',
    'Oficinista apurado',
    'La emprendedora',
    'El maestro albañil',
  ];

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
      customerName: customers[rng.nextInt(customers.length)],
      lines: orderLines,
      reward: economy.orderReward(requestedValue),
      xp: economy.orderXp(
        orderLines.fold(0, (int s, OrderLine l) => s + l.levelUnits),
      ),
      isSpecial: special,
    );
  }
}
