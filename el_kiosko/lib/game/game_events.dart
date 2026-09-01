/// Eventos que el motor emite tras aplicar una acción. La UI los usa para
/// feedback (háptico, toasts, animaciones) y la capa de analytics los traduce
/// a los eventos del plan de medición (ver services/analytics).
library;

import 'models/order.dart';

sealed class GameEvent {
  const GameEvent();
}

class ItemGenerated extends GameEvent {
  const ItemGenerated(this.chainId);
  final String chainId;
}

class MergeCompleted extends GameEvent {
  const MergeCompleted(this.chainId, this.newLevel);
  final String chainId;
  final int newLevel;
}

class OrderCompleted extends GameEvent {
  const OrderCompleted({
    required this.reward,
    required this.xp,
    required this.withBonus,
    required this.withTimeBonus,
    required this.customerId,
    required this.lines,
  });
  final int reward;
  final int xp;
  final bool withBonus;

  /// Se entregó dentro de la ventana de bonificación por rapidez.
  final bool withTimeBonus;

  /// Quién se lo llevó y qué se llevó. La UI ya no tiene el pedido —fue
  /// reemplazado por uno nuevo en el mismo lugar—, así que el evento lo trae.
  final int customerId;
  final List<OrderLine> lines;
}

class OrderPartiallyCompleted extends GameEvent {
  const OrderPartiallyCompleted({
    required this.reward,
    required this.coverage,
    required this.customerId,
    required this.lines,
  });
  final int reward;

  /// Fracción del pedido que se alcanzó a cubrir, entre 0 y 1.
  final double coverage;

  final int customerId;
  final List<OrderLine> lines;
}

class OrderRerolled extends GameEvent {
  const OrderRerolled(this.cost);
  final int cost;
}

class ProductBought extends GameEvent {
  const ProductBought(this.chainId, this.level, this.price);
  final String chainId;
  final int level;
  final int price;
}

class ItemSplit extends GameEvent {
  const ItemSplit(this.chainId, this.newLevel, this.cost);
  final String chainId;
  final int newLevel;
  final int cost;
}

class BoardExpanded extends GameEvent {
  const BoardExpanded(this.unlockedRows, this.cost);
  final int unlockedRows;
  final int cost;
}

class ItemSold extends GameEvent {
  const ItemSold(this.value);
  final int value;
}

class ShopUpgraded extends GameEvent {
  const ShopUpgraded(this.newLevel);
  final int newLevel;
}

class PlayerLeveledUp extends GameEvent {
  const PlayerLeveledUp(this.newLevel);
  final int newLevel;
}

class ChainUnlocked extends GameEvent {
  const ChainUnlocked(this.chainId);
  final String chainId;
}

class ProductDiscovered extends GameEvent {
  const ProductDiscovered(this.chainId, this.level);
  final String chainId;
  final int level;
}

class TillCollected extends GameEvent {
  const TillCollected(this.amount);
  final int amount;
}

class TillUpgraded extends GameEvent {
  const TillUpgraded(this.newLevel, this.cost);
  final int newLevel;
  final int cost;
}

/// Al volver, el almacén juntó algo mientras la app estuvo cerrada.
///
/// Son dos números distintos a propósito: [earned] es lo que se juntó durante
/// la ausencia —lo único que se puede afirmar honestamente— y [total] es lo
/// que hay en la caja, que incluye lo que el jugador dejó sin cobrar la vez
/// anterior. El botón cobra [total].
class OfflineEarningsClaimed extends GameEvent {
  const OfflineEarningsClaimed({required this.earned, required this.total});
  final int earned;
  final int total;
}

/// Se cobró un logro.
class AchievementClaimed extends GameEvent {
  const AchievementClaimed({required this.id, required this.reward});
  final String id;
  final int reward;
}

/// Llegó un pedido mayorista: grande, caro y con los minutos contados.
class BigOrderArrived extends GameEvent {
  const BigOrderArrived({required this.reward, required this.expiresAt});
  final int reward;
  final DateTime expiresAt;
}

/// Se fue sin que lo tomaran. No se pierde nada: es una oportunidad que pasó.
class BigOrderExpired extends GameEvent {
  const BigOrderExpired();
}

/// Se acomodó la mercadería por tipo y nivel.
class BoardSorted extends GameEvent {
  const BoardSorted(this.cost);

  /// 0 si el jugador ya compró la mejora de ordenar gratis.
  final int cost;
}

/// Se compró la mejora que deja ordenar gratis para siempre.
class FreeSortUnlocked extends GameEvent {
  const FreeSortUnlocked(this.cost);
  final int cost;
}

/// Se deshizo la última jugada, pagando la comisión.
class ActionUndone extends GameEvent {
  const ActionUndone(this.cost);
  final int cost;
}

/// El proveedor "fía" monedas porque el jugador quedó sin salida posible.
/// Red de seguridad, no un gancho de monetización (PLAN_FINAL §3.2).
class EmergencyRelief extends GameEvent {
  const EmergencyRelief(this.amount);
  final int amount;
}

class ActionRejected extends GameEvent {
  const ActionRejected(this.reason);
  final RejectReason reason;
}

enum RejectReason {
  notEnoughCoins,
  boardFull,
  orderNotReady,
  maxShopLevel,
  boardAtMaxSize,
  cannotSplit,
  partialNotAvailable,
  tillAtMaxLevel,
  alreadySorted,
  alreadyOwned,
  cannotRerollBig,
  achievementNotDone,
}

class TutorialAdvanced extends GameEvent {
  const TutorialAdvanced();
}
