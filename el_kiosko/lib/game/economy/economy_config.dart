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
    this.sortCost = 2,
    this.undoCost = 3,
    this.freeSortRatio = 0.5,
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
    this.partialDeliveryPlayerLevel = 4,
    this.partialDeliveryPenalty = 0.7,
    this.tillBaseHours = 4,
    this.tillHoursPerLevel = 2,
    this.tillMaxLevel = 5,
    this.tillUpgradeBaseCost = 400,
    this.tillUpgradeGrowth = 2.8,
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
  /// Lo que cuesta ordenar la mercadería. Simbólico a propósito: es una ayuda
  /// de comodidad, no una decisión económica. Si costara de verdad, el jugador
  /// se pondría a ordenar a mano para ahorrar, que es exactamente el trabajo
  /// aburrido que el botón viene a sacar.
  final int sortCost;

  /// Lo que cuesta deshacer. Bajo y fijo: deshacer existe para reparar un
  /// accidente, y cobrar caro por arrepentirse sería castigar al jugador por
  /// un resbalón. El cobro está para que no se use como un botón más.
  final int undoCost;

  /// La mejora "ordenar gratis" cuesta esta fracción de lo que cuesta subir el
  /// local al siguiente nivel.
  final double freeSortRatio;

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

  /// Nivel de jugador a partir del cual se puede entregar un pedido a medias.
  ///
  /// No está desde el principio a propósito: el jugador nuevo tiene que
  /// aprender a completar pedidos antes de que se le ofrezca una salida.
  final int partialDeliveryPlayerLevel;

  /// Lo que se paga por una entrega parcial, sobre lo proporcional. Menor que
  /// 1 para que entregar completo siempre convenga.
  final double partialDeliveryPenalty;

  /// Horas de ganancia que aguanta la caja en el nivel 1, y cuánto suma cada
  /// mejora.
  ///
  /// La caja tiene tope a propósito: cuando se llena, deja de acumular. Eso
  /// es lo que da una razón concreta para volver —y algo real que avisar por
  /// notificación— en vez de dejar que el dinero se junte para siempre.
  final int tillBaseHours;
  final int tillHoursPerLevel;
  final int tillMaxLevel;

  final int tillUpgradeBaseCost;
  final double tillUpgradeGrowth;

  int get boardCapacity => boardColumns * boardRows;

  /// Horas de ganancia que aguanta la caja en un nivel dado.
  int tillHours(int tillLevel) =>
      tillBaseHours +
      (tillLevel.clamp(1, tillMaxLevel) - 1) * tillHoursPerLevel;

  /// Costo de subir la caja al nivel [tillLevel].
  int tillUpgradeCost(int tillLevel) {
    if (tillLevel <= 1 || tillLevel > tillMaxLevel) return 0;
    return (tillUpgradeBaseCost * math.pow(tillUpgradeGrowth, tillLevel - 2))
        .round();
  }

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
    int? sortCost,
    int? undoCost,
    double? freeSortRatio,
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
      sortCost: sortCost ?? this.sortCost,
      undoCost: undoCost ?? this.undoCost,
      freeSortRatio: freeSortRatio ?? this.freeSortRatio,
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
      partialDeliveryPlayerLevel: partialDeliveryPlayerLevel,
      partialDeliveryPenalty: partialDeliveryPenalty,
      tillBaseHours: tillBaseHours,
      tillHoursPerLevel: tillHoursPerLevel,
      tillMaxLevel: tillMaxLevel,
      tillUpgradeBaseCost: tillUpgradeBaseCost,
      tillUpgradeGrowth: tillUpgradeGrowth,
    );
  }

  static const EconomyConfig defaults = EconomyConfig();
}
