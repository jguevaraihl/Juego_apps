/// Eventos que el motor emite tras aplicar una acción. La UI los usa para
/// feedback (háptico, toasts, animaciones) y la capa de analytics los traduce
/// a los eventos del plan de medición (ver services/analytics).
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
  });
  final int reward;
  final int xp;
  final bool withBonus;

  /// Se entregó dentro de la ventana de bonificación por rapidez.
  final bool withTimeBonus;
}

class OrderPartiallyCompleted extends GameEvent {
  const OrderPartiallyCompleted({required this.reward, required this.coverage});
  final int reward;

  /// Fracción del pedido que se alcanzó a cubrir, entre 0 y 1.
  final double coverage;
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
}

class TutorialAdvanced extends GameEvent {
  const TutorialAdvanced();
}
