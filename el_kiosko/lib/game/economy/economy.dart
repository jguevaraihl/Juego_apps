import 'dart:math' as math;

import 'economy_config.dart';

/// Fórmulas puras de economía. Documentadas en GAME_ECONOMY.md.
class Economy {
  const Economy(this.config);

  final EconomyConfig config;

  /// Valor de mercado de un objeto de nivel [level].
  int itemValue(int level) {
    assert(level >= 1);
    return (config.baseItemValue * math.pow(config.valueExponent, level - 1))
        .round();
  }

  /// Lo que paga el mesón por vender un excedente. Siempre menor que
  /// [EconomyConfig.generateCost] en nivel 1 (ver invariante en los tests).
  int sellValue(int level) =>
      math.max(1, (itemValue(level) * config.sellRatio).floor());

  /// Recompensa base de un pedido, dado el valor total de lo solicitado.
  int orderReward(int requestedValue) =>
      math.max(1, (requestedValue * config.orderRewardMultiplier).round());

  /// Recompensa si se cobra el bonus opcional del pedido.
  int orderBonusReward(int baseReward) =>
      (baseReward * config.orderBonusMultiplier).round();

  /// Precio de comprar un producto ya hecho de nivel [level].
  ///
  /// Invariante (verificado en tests): siempre mayor que lo que paga un pedido
  /// de ese mismo nivel, para que comprar nunca reemplace a fusionar.
  int buyPrice(int level) => (itemValue(level) * config.buyPriceRatio).round();

  /// Costo de separar un producto de nivel [level] en dos del nivel anterior.
  int splitCost(int level) => math.max(
    config.minSplitCost,
    (itemValue(level) * config.splitCostRatio).round(),
  );

  /// Recompensa con la bonificación por rapidez aplicada.
  int timeBonusReward(int baseReward) =>
      (baseReward * config.timeBonusMultiplier).round();

  int rerollCost(int orderReward) => math.max(
    config.minRerollCost,
    (orderReward * config.rerollCostRatio).round(),
  );

  /// XP que entrega un pedido, según la suma de nivel×cantidad pedida.
  int orderXp(int levelUnits) => levelUnits * config.xpPerLevelUnit;

  /// XP acumulada necesaria para alcanzar [level]. Nivel 1 = 0 XP.
  int xpForLevel(int level) {
    if (level <= 1) return 0;
    return (config.xpCurveBase * math.pow(level - 1, config.xpCurveExponent))
        .round();
  }

  /// Nivel de jugador correspondiente a una XP acumulada.
  int levelForXp(int xp) {
    var level = 1;
    while (level < 999 && xp >= xpForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  /// Progreso [0..1] dentro del nivel actual, para la barra de XP.
  double levelProgress(int xp) {
    final int level = levelForXp(xp);
    final int floor = xpForLevel(level);
    final int ceil = xpForLevel(level + 1);
    if (ceil <= floor) return 1;
    return ((xp - floor) / (ceil - floor)).clamp(0.0, 1.0);
  }

  /// Nivel máximo de producto que pueden pedir los clientes.
  /// Sube de a uno cada dos niveles de jugador.
  int maxOrderLevel(int playerLevel, int chainMaxLevel) {
    final int unlocked = 1 + ((playerLevel + 1) ~/ 2);
    return unlocked.clamp(1, chainMaxLevel);
  }

  /// Ganancia pasiva por segundo, para el contador que corre en vivo.
  double incomePerSecond(int coinsPerHour) =>
      coinsPerHour / Duration.secondsPerHour;

  /// Ganancia pasiva acumulada mientras la app estuvo cerrada.
  ///
  /// Se topa en [EconomyConfig.offlineCapHours]. Devuelve 0 si el reloj del
  /// dispositivo retrocedió (elapsed negativo), para que cambiar la hora del
  /// teléfono no sea un exploit.
  int offlineEarnings({required Duration elapsed, required int coinsPerHour}) {
    if (elapsed.isNegative || coinsPerHour <= 0) return 0;
    final double cappedHours = math.min(
      elapsed.inSeconds / Duration.secondsPerHour,
      config.offlineCapHours.toDouble(),
    );
    return (coinsPerHour * cappedHours).floor();
  }
}
