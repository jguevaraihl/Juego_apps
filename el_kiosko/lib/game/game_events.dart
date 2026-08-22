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
  });
  final int reward;
  final int xp;
  final bool withBonus;
}

class OrderRerolled extends GameEvent {
  const OrderRerolled(this.cost);
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

class OfflineEarningsClaimed extends GameEvent {
  const OfflineEarningsClaimed(this.amount);
  final int amount;
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

enum RejectReason { notEnoughCoins, boardFull, orderNotReady, maxShopLevel }

class TutorialAdvanced extends GameEvent {
  const TutorialAdvanced();
}
