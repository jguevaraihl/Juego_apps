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
  String get displayName => chain.tierName(level);

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
    required this.customerName,
    required this.lines,
    required this.reward,
    required this.xp,
    this.isSpecial = false,
  });

  final int id;
  final String customerName;
  final List<OrderLine> lines;
  final int reward;
  final int xp;

  /// Los pedidos especiales tienen un bonus opcional. Hoy se cobra gratis;
  /// en Fase 3 será el caso de uso del rewarded ad (siempre voluntario).
  final bool isSpecial;

  int get levelUnits =>
      lines.fold(0, (int sum, OrderLine l) => sum + l.levelUnits);

  /// ¿Está el pedido completo con lo que hay en el tablero?
  bool isSatisfiedBy(Board board) => lines.every(
    (OrderLine l) => board.countOf(l.chainId, l.level) >= l.quantity,
  );

  /// Cuántas unidades de una línea ya están disponibles (para el "1/2" de la UI).
  int progressFor(OrderLine line, Board board) =>
      board.countOf(line.chainId, line.level).clamp(0, line.quantity);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'customer': customerName,
    'lines': lines.map((OrderLine l) => l.toJson()).toList(growable: false),
    'reward': reward,
    'xp': xp,
    'special': isSpecial,
  };

  static CustomerOrder fromJson(Map<String, dynamic> json) => CustomerOrder(
    id: json['id'] as int,
    customerName: json['customer'] as String,
    lines: ((json['lines'] as List<dynamic>?) ?? <dynamic>[])
        .map(
          (dynamic e) =>
              OrderLine.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false),
    reward: json['reward'] as int,
    xp: json['xp'] as int,
    isSpecial: (json['special'] as bool?) ?? false,
  );
}
