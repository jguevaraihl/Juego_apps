/// Toda la economía está parametrizada aquí (PLAN_FINAL §3.7). Ningún número
/// de balance debe quedar hardcodeado en la UI ni en el motor.
///
/// [EconomyConfig.version] se registra en analytics y en el save para poder
/// comparar cohortes cuando se cambie el balance.
library;

import 'dart:math' as math;

class EconomyConfig {
  const EconomyConfig({
    this.version = 2,
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
    this.startingRows = 5,
    this.expandBaseCost = 250,
    this.expandCostGrowth = 3.4,
    this.buyPriceRatio = 2.2,
    this.splitCostRatio = 0.35,
    this.minSplitCost = 2,
    this.orderBonusWindow = const Duration(minutes: 5),
    this.timeBonusMultiplier = 1.5,
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

  /// Filas desbloqueadas al empezar. El resto se compran (ver [expandCost]).
  final int startingRows;

  /// Costo de la primera ampliación; cada una siguiente se multiplica por
  /// [expandCostGrowth].
  final int expandBaseCost;
  final double expandCostGrowth;

  /// Precio de comprar un producto ya hecho, como múltiplo de su valor.
  ///
  /// Tiene que quedar **por encima de lo que paga un pedido de ese nivel**, o
  /// comprar y entregar sería más rentable que fusionar y el core loop se
  /// vuelve irrelevante. Con 2.2 y una recompensa de 1.6× el valor, comprar
  /// siempre deja pérdida frente al pedido: es un atajo de conveniencia y un
  /// sumidero de monedas, nunca una fuente de ganancia.
  final double buyPriceRatio;

  /// Costo de separar un producto en dos del nivel anterior.
  final double splitCostRatio;
  final int minSplitCost;

  /// Ventana durante la cual un pedido paga bonificación por rapidez.
  ///
  /// Los pedidos **nunca caducan**: pasada la ventana simplemente se cobra lo
  /// normal. Es un premio por rapidez, no un castigo por demorarse, para que
  /// guardar el teléfono a mitad de partida no cueste nada.
  final Duration orderBonusWindow;
  final double timeBonusMultiplier;

  int get boardCapacity => boardColumns * boardRows;

  /// Costo de desbloquear la fila número [row] (1-indexada). Sólo tiene
  /// sentido para filas por sobre [startingRows].
  int expandCost(int row) {
    final int step = row - startingRows;
    if (step <= 0) return 0;
    return (expandBaseCost * math.pow(expandCostGrowth, step - 1)).round();
  }

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
      startingRows: startingRows,
      expandBaseCost: expandBaseCost,
      expandCostGrowth: expandCostGrowth,
      buyPriceRatio: buyPriceRatio,
      splitCostRatio: splitCostRatio,
      minSplitCost: minSplitCost,
      orderBonusWindow: orderBonusWindow,
      timeBonusMultiplier: timeBonusMultiplier,
    );
  }

  static const EconomyConfig defaults = EconomyConfig();
}
