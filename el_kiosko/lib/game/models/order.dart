import 'board.dart';
import 'product.dart';

/// Una línea de un pedido: "2 × Bolsa de pan".
class OrderLine {
  const OrderLine({
    required this.chainId,
    required this.level,
    required this.quantity,
  });

  final String chainId;
  final int level;
  final int quantity;

  ProductChain get chain => ProductCatalog.byId(chainId);

  /// Suma nivel×cantidad, unidad con la que se calcula la XP.
  int get levelUnits => level * quantity;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'chain': chainId,
    'level': level,
    'qty': quantity,
  };

  static OrderLine fromJson(Map<String, dynamic> json) => OrderLine(
    chainId: json['chain'] as String,
    level: json['level'] as int,
    quantity: json['qty'] as int,
  );

  @override
  bool operator ==(Object other) =>
      other is OrderLine &&
      other.chainId == chainId &&
      other.level == level &&
      other.quantity == quantity;

  @override
  int get hashCode => Object.hash(chainId, level, quantity);
}

/// Un pedido de un cliente. La recompensa se congela al generarlo para que la
/// UI muestre un número estable aunque cambie el balance en una actualización.
class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.customerId,
    required this.lines,
    required this.reward,
    required this.xp,
    this.isSpecial = false,
    this.bonusUntil,
  });

  final int id;

  /// Índice del cliente en el catálogo de clientes. Se guarda el índice y no
  /// el nombre para que la partida no quede escrita en un idioma.
  final int customerId;

  final List<OrderLine> lines;
  final int reward;
  final int xp;

  /// Los pedidos especiales tienen un bonus opcional. Hoy se cobra gratis;
  /// en Fase 3 será el caso de uso del rewarded ad (siempre voluntario).
  final bool isSpecial;

  /// Hasta cuándo el pedido paga bonificación por rapidez.
  ///
  /// El pedido **nunca caduca**: pasada esta hora simplemente se cobra lo
  /// normal. Es un premio por entregar rápido, no un castigo por demorarse.
  final DateTime? bonusUntil;

  /// ¿Todavía corre la bonificación por rapidez?
  bool hasTimeBonusAt(DateTime now) =>
      bonusUntil != null && now.isBefore(bonusUntil!);

  /// Cuánto queda de bonificación, o null si ya pasó.
  Duration? bonusRemainingAt(DateTime now) {
    final DateTime? until = bonusUntil;
    if (until == null || !now.isBefore(until)) return null;
    return until.difference(now);
  }

  int get levelUnits =>
      lines.fold(0, (int sum, OrderLine l) => sum + l.levelUnits);

  /// ¿Está el pedido completo con lo que hay en el tablero?
  bool isSatisfiedBy(Board board) => lines.every(
    (OrderLine l) => board.countOf(l.chainId, l.level) >= l.quantity,
  );

  /// Unidades (nivel × cantidad) que el jugador ya puede entregar.
  int availableUnitsIn(Board board) => lines.fold(0, (int sum, OrderLine l) {
    final int have = board.countOf(l.chainId, l.level).clamp(0, l.quantity);
    return sum + l.level * have;
  });

  /// Fracción del pedido que se puede cubrir hoy, entre 0 y 1.
  double coverageIn(Board board) {
    final int total = levelUnits;
    if (total == 0) return 0;
    return availableUnitsIn(board) / total;
  }

  /// Cuántas unidades de una línea ya están disponibles (para el "1/2" de la UI).
  int progressFor(OrderLine line, Board board) =>
      board.countOf(line.chainId, line.level).clamp(0, line.quantity);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'customerId': customerId,
    'lines': lines.map((OrderLine l) => l.toJson()).toList(growable: false),
    'reward': reward,
    'xp': xp,
    'special': isSpecial,
    'bonusUntil': bonusUntil?.toUtc().toIso8601String(),
  };

  static CustomerOrder fromJson(Map<String, dynamic> json) => CustomerOrder(
    id: json['id'] as int,
    customerId: json['customerId'] as int,
    lines: ((json['lines'] as List<dynamic>?) ?? <dynamic>[])
        .map(
          (dynamic e) =>
              OrderLine.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false),
    reward: json['reward'] as int,
    xp: json['xp'] as int,
    isSpecial: (json['special'] as bool?) ?? false,
    bonusUntil: DateTime.tryParse(json['bonusUntil'] as String? ?? '')
        ?.toLocal(),
  );
}
