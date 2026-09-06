// ignore_for_file: avoid_print
// Modelo analítico del ritmo del juego. No es un test: es el instrumento con
// el que se ajusta el balance, y se corre a mano con
//   flutter test tool/balance_sim.dart
//
// Por qué analítico y no una partida simulada: una heurística que juega sola
// se atasca en bucles que ningún humano haría, y entonces mide la heurística
// en vez del juego. La cuenta de abajo, en cambio, describe al jugador
// eficiente —el que marca el techo— y da el mismo número que el owner midió
// jugando: el local llegaba al último nivel en menos de cinco horas.
import 'package:almacen/game/economy/economy.dart';
import 'package:almacen/game/economy/economy_config.dart';
import 'package:almacen/game/progression/shop_tiers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Segundos de tiempo real por acción (un toque o un arrastre).
const double secondsPerAction = 1.2;

/// Acciones necesarias para fabricar UNA unidad de [level] desde cero:
/// 2^(n-1) pedidos al proveedor más los 2^(n-1)-1 arrastres que los juntan.
int actionsToBuild(int level) => (1 << level) - 1;

/// Monedas gastadas en el proveedor para fabricar esa unidad.
int coinCostToBuild(int level, EconomyConfig c) =>
    c.generateCost * (1 << (level - 1));

void main() {
  final Economy economy = Economy(EconomyConfig.defaults);
  final EconomyConfig c = EconomyConfig.defaults;

  test('ritmo del juego', () {
    print('\n=== Rendimiento por nivel de producto ===');
    print('nivel | acciones | costo | paga pedido | neto | monedas/acción');
    double best = 0;
    for (int l = 1; l <= 8; l++) {
      final int acts = actionsToBuild(l);
      final int cost = coinCostToBuild(l, c);
      final int pays = economy.orderReward(economy.itemValue(l));
      final double rate = (pays - cost) / acts;
      if (rate > best) best = rate;
      print(
        '  $l   |   $acts   |  $cost  |     $pays     | ${pays - cost} | '
        '${rate.toStringAsFixed(2)}',
      );
    }

    int ladder = 0;
    for (final ShopTier t in ShopTiers.all) {
      ladder += t.upgradeCost;
    }

    print('\n=== Escalera del local ===');
    int cum = 0;
    for (final ShopTier t in ShopTiers.all) {
      cum += t.upgradeCost;
      if (t.level % 5 != 0 && t.level != 2 && t.level != ShopTiers.maxLevel) {
        continue;
      }
      print(
        'nivel ${t.level} (fachada ${t.visualTier} ★${t.starWithinTier}): '
        '${t.upgradeCost} monedas (acumulado $cum) · ${t.coinsPerHour}/h',
      );
    }

    final double actionsNeeded = ladder / best;
    final double hours = actionsNeeded * secondsPerAction / 3600;
    print('\n=== Resultado ===');
    print('Monedas para la escalera completa: $ladder');
    print(
      'Mejor tasa del jugador eficiente: '
      '${best.toStringAsFixed(2)} monedas/acción',
    );
    print('Acciones: ${actionsNeeded.round()}');
    print(
      'HORAS DE JUEGO ACTIVO HASTA EL TOPE: '
      '${hours.toStringAsFixed(1)} h',
    );
    print('(sin contar la ganancia pasiva de la caja, que lo acorta más)');
  });
}
