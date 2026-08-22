/// Toda la economía está parametrizada aquí (PLAN_FINAL §3.7). Ningún número
/// de balance debe quedar hardcodeado en la UI ni en el motor.
///
/// [EconomyConfig.version] se registra en analytics y en el save para poder
/// comparar cohortes cuando se cambie el balance.
library;

class EconomyConfig {
  const EconomyConfig({
    this.version = 1,
    this.startingCoins = 60,
    this.baseItemValue = 3,
    this.valueExponent = 2.6,
    this.generateCost = 3,
    this.sellRatio = 0.5,
    this.orderRewardMultiplier = 1.6,
    this.orderBonusMultiplier = 2.0,
    this.rerollCostRatio = 0.35,
    this.minRerollCost = 5,
    this.xpPerLevelUnit = 3,
    this.xpCurveBase = 30,
    this.xpCurveExponent = 1.6,
    this.visibleOrders = 3,
    this.storageSlots = 4,
    this.boardColumns = 6,
    this.boardRows = 8,
    this.offlineCapHours = 4,
    this.offlineMinClaim = 5,
    this.emergencyGenerations = 5,
    this.idleHintSeconds = 12,
  });

  /// Se sube cuando cambia el balance, para segmentar cohortes.
  final int version;

  final int startingCoins;

  /// valor(nivel) = round(baseItemValue * valueExponent^(nivel-1)).
  final int baseItemValue;
  final double valueExponent;

  /// Costo en monedas de tocar la caja del proveedor.
  final int generateCost;

  /// Al vender se recupera esta fracción del valor. Debe ser < 1 y dar un
  /// resultado menor a [generateCost] en nivel 1, o generar+vender sería una
  /// máquina de monedas infinita.
  final double sellRatio;

  /// Recompensa del pedido = valor de lo pedido × este multiplicador.
  final double orderRewardMultiplier;

  /// Multiplicador del bonus opcional (hoy: pedido especial; en Fase 3 será el
  /// caso de uso del rewarded ad).
  final double orderBonusMultiplier;

  /// Costo de cambiar un pedido = recompensa × ratio, con un piso.
  final double rerollCostRatio;
  final int minRerollCost;

  /// XP de un pedido = suma(nivel × cantidad) × xpPerLevelUnit.
  final int xpPerLevelUnit;

  /// XP acumulada necesaria para alcanzar el nivel n:
  /// round(xpCurveBase * (n-1)^xpCurveExponent).
  final int xpCurveBase;
  final double xpCurveExponent;

  final int visibleOrders;
  final int storageSlots;
  final int boardColumns;
  final int boardRows;

  /// Tope de acumulación pasiva y mínimo para ofrecer el cobro.
  final int offlineCapHours;
  final int offlineMinClaim;

  /// Si el jugador queda sin salida, se le "fía" el equivalente a esta
  /// cantidad de generaciones. Ver [GameEngine.relieveIfStuck].
  final int emergencyGenerations;

  /// Segundos de inactividad antes de sugerir una jugada.
  final int idleHintSeconds;

  int get boardCapacity => boardColumns * boardRows;

  EconomyConfig copyWith({
    int? version,
    int? startingCoins,
    int? generateCost,
    double? orderRewardMultiplier,
    int? boardColumns,
    int? boardRows,
    int? offlineCapHours,
  }) {
    return EconomyConfig(
      version: version ?? this.version,
      startingCoins: startingCoins ?? this.startingCoins,
      baseItemValue: baseItemValue,
      valueExponent: valueExponent,
      generateCost: generateCost ?? this.generateCost,
      sellRatio: sellRatio,
      orderRewardMultiplier:
          orderRewardMultiplier ?? this.orderRewardMultiplier,
      orderBonusMultiplier: orderBonusMultiplier,
      rerollCostRatio: rerollCostRatio,
      minRerollCost: minRerollCost,
      xpPerLevelUnit: xpPerLevelUnit,
      xpCurveBase: xpCurveBase,
      xpCurveExponent: xpCurveExponent,
      visibleOrders: visibleOrders,
      storageSlots: storageSlots,
      boardColumns: boardColumns ?? this.boardColumns,
      boardRows: boardRows ?? this.boardRows,
      offlineCapHours: offlineCapHours ?? this.offlineCapHours,
      offlineMinClaim: offlineMinClaim,
      emergencyGenerations: emergencyGenerations,
      idleHintSeconds: idleHintSeconds,
    );
  }

  static const EconomyConfig defaults = EconomyConfig();
}
