import 'product.dart';

/// Un objeto sobre el tablero o en el almacenamiento temporal.
///
/// [id] es estable durante la vida del objeto y se usa como key de las
/// animaciones, para que mover una pieza no la reconstruya desde cero.
class BoardItem {
  const BoardItem({
    required this.id,
    required this.chainId,
    required this.level,
  });

  final int id;
  final String chainId;
  final int level;

  ProductChain get chain => ProductCatalog.byId(chainId);
  bool get isMaxLevel => level >= chain.maxLevel;

  /// Dos objetos se pueden fusionar si son de la misma cadena, del mismo
  /// nivel, y ese nivel no es el máximo de la cadena.
  bool canMergeWith(BoardItem other) =>
      chainId == other.chainId && level == other.level && !isMaxLevel;

  BoardItem levelUp({required int newId}) =>
      BoardItem(id: newId, chainId: chainId, level: level + 1);

  BoardItem copyWith({int? id}) =>
      BoardItem(id: id ?? this.id, chainId: chainId, level: level);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'chain': chainId,
    'level': level,
  };

  static BoardItem fromJson(Map<String, dynamic> json) => BoardItem(
    id: json['id'] as int,
    chainId: json['chain'] as String,
    level: json['level'] as int,
  );

  @override
  bool operator ==(Object other) =>
      other is BoardItem &&
      other.id == id &&
      other.chainId == chainId &&
      other.level == level;

  @override
  int get hashCode => Object.hash(id, chainId, level);

  @override
  String toString() => 'BoardItem($id, $chainId L$level)';
}
