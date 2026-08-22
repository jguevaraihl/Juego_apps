import 'package:almacen/game/economy/economy.dart';
import 'package:almacen/game/economy/economy_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const EconomyConfig config = EconomyConfig.defaults;
  const Economy economy = Economy(config);

  group('valor de los productos', () {
    test('crece con el nivel', () {
      int previous = 0;
      for (int level = 1; level <= 5; level++) {
        final int value = economy.itemValue(level);
        expect(value, greaterThan(previous));
        previous = value;
      }
    });

    test('fusionar dos objetos vale más que los dos por separado', () {
      // Si no se cumple, fusionar sería una mala jugada y el loop se rompe.
      for (int level = 1; level < 5; level++) {
        expect(
          economy.itemValue(level + 1),
          greaterThan(economy.itemValue(level) * 2),
          reason: 'nivel $level -> ${level + 1} debe ser rentable',
        );
      }
    });
  });

  group('invariantes anti-exploit', () {
    test('vender nivel 1 paga menos que generar', () {
      // Si vender pagara igual o más que generar, generar+vender sería una
      // máquina infinita de monedas.
      expect(economy.sellValue(1), lessThan(config.generateCost));
    });

    test('vender nunca paga más que el valor del objeto', () {
      for (int level = 1; level <= 5; level++) {
        expect(
          economy.sellValue(level),
          lessThanOrEqualTo(economy.itemValue(level)),
        );
      }
    });
  });

  group('comprar y separar', () {
    test('comprar nunca es más rentable que fusionar', () {
      // Esta es LA invariante que protege el core loop. Si comprar un
      // producto costara menos de lo que paga un pedido de ese nivel, la
      // jugada óptima sería comprar y entregar en bucle, y fusionar —que es
      // el juego— dejaría de tener sentido.
      for (int level = 2; level <= 5; level++) {
        expect(
          economy.buyPrice(level),
          greaterThan(economy.orderReward(economy.itemValue(level))),
          reason:
              'comprar nivel \$level debe costar más de lo que paga el pedido',
        );
      }
    });

    test('comprar cuesta más que producir fusionando', () {
      for (int level = 2; level <= 5; level++) {
        final int productionCost = (1 << (level - 1)) * config.generateCost;
        expect(economy.buyPrice(level), greaterThan(productionCost));
      }
    });

    test('separar cuesta algo pero no una fortuna', () {
      for (int level = 2; level <= 5; level++) {
        expect(economy.splitCost(level), greaterThanOrEqualTo(1));
        // Separar devuelve dos objetos del nivel de abajo, que juntos valen
        // lo mismo que el original: la comisión no puede superar eso o nadie
        // lo usaría nunca.
        expect(economy.splitCost(level), lessThan(economy.itemValue(level)));
      }
    });

    test('ampliar el tablero se encarece cada vez', () {
      int previous = 0;
      for (int row = config.startingRows + 1; row <= config.boardRows; row++) {
        final int cost = config.expandCost(row);
        expect(cost, greaterThan(previous));
        previous = cost;
      }
      // Las filas que ya vienen desbloqueadas no cuestan nada.
      expect(config.expandCost(config.startingRows), 0);
    });

    test('la bonificación por rapidez paga más que la recompensa base', () {
      expect(economy.timeBonusReward(100), greaterThan(100));
    });
  });

  group('recompensa de pedidos', () {
    test('paga más que el costo de producir lo pedido', () {
      for (int level = 1; level <= 5; level++) {
        final int generationsNeeded = 1 << (level - 1);
        final int productionCost = generationsNeeded * config.generateCost;
        final int reward = economy.orderReward(economy.itemValue(level));
        expect(
          reward,
          greaterThan(productionCost),
          reason: 'un pedido de nivel $level debe dejar ganancia',
        );
      }
    });

    test('el bonus duplica la recompensa base', () {
      expect(economy.orderBonusReward(100), 200);
    });

    test('el reroll tiene piso', () {
      expect(economy.rerollCost(1), config.minRerollCost);
      expect(economy.rerollCost(1000), greaterThan(config.minRerollCost));
    });
  });

  group('niveles de jugador', () {
    test('el nivel 1 empieza en 0 XP', () {
      expect(economy.levelForXp(0), 1);
      expect(economy.xpForLevel(1), 0);
    });

    test('levelForXp es la inversa de xpForLevel', () {
      for (int level = 1; level <= 20; level++) {
        expect(economy.levelForXp(economy.xpForLevel(level)), level);
      }
    });

    test('el progreso queda entre 0 y 1', () {
      for (int xp = 0; xp < 2000; xp += 37) {
        final double progress = economy.levelProgress(xp);
        expect(progress, inInclusiveRange(0.0, 1.0));
      }
    });

    test('el nivel máximo de pedido sube con el nivel de jugador', () {
      expect(economy.maxOrderLevel(1, 5), 2);
      expect(economy.maxOrderLevel(3, 5), 3);
      expect(economy.maxOrderLevel(5, 5), 4);
      expect(economy.maxOrderLevel(7, 5), 5);
      // Nunca supera el máximo de la cadena.
      expect(economy.maxOrderLevel(99, 5), 5);
      expect(economy.maxOrderLevel(99, 3), 3);
    });
  });

  group('ganancia offline', () {
    test('escala con el tiempo ausente', () {
      expect(
        economy.offlineEarnings(
          elapsed: const Duration(hours: 1),
          coinsPerHour: 30,
        ),
        30,
      );
      expect(
        economy.offlineEarnings(
          elapsed: const Duration(minutes: 30),
          coinsPerHour: 30,
        ),
        15,
      );
    });

    test('se topa en offlineCapHours', () {
      expect(
        economy.offlineEarnings(
          elapsed: const Duration(hours: 100),
          coinsPerHour: 30,
        ),
        30 * config.offlineCapHours,
      );
    });

    test('un reloj hacia atrás no genera monedas', () {
      expect(
        economy.offlineEarnings(
          elapsed: const Duration(hours: -5),
          coinsPerHour: 30,
        ),
        0,
      );
    });
  });
}
