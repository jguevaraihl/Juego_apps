/// Escalera de progreso del local.
///
/// **Treinta niveles, siete fachadas.** Los dos números son distintos a
/// propósito. El nivel es la unidad de progreso —lo que el jugador compra, lo
/// que sube la ganancia por hora, lo que sostiene el juego durante meses— y
/// son treinta. La fachada es la recompensa visual, y son siete porque son
/// siete ilustraciones (ver `ART_PROMPTS.md`): pedir treinta sería pedir un
/// encargo imposible, y dibujar treinta variantes en código daría veinticuatro
/// que se parecen entre sí.
///
/// Así, subir de nivel siempre da algo —más ingreso, y una estrella más en el
/// nombre— y cada cinco niveles el local además **cambia de cara**. Es la misma
/// solución que usan Township o Hay Day, y evita el problema real de una
/// escalera larga: que los últimos veinte niveles se sientan idénticos.
///
/// Sin textos: los nombres viven en lib/l10n y se resuelven en la UI.
library;

import 'dart:math' as math;

class ShopTier {
  const ShopTier({
    required this.level,
    required this.upgradeCost,
    required this.coinsPerHour,
    required this.visualTier,
    required this.starWithinTier,
    required this.shelves,
    required this.customers,
  });

  /// Nivel del local, de 1 a 30.
  final int level;

  /// Costo para pasar a este nivel. El nivel 1 es el punto de partida.
  final int upgradeCost;

  /// Ganancia pasiva por hora en este nivel.
  final int coinsPerHour;

  /// Cuál de las siete fachadas se dibuja, de 1 a 7.
  final int visualTier;

  /// Cuántas estrellas lleva el nombre dentro de su fachada: "Kiosko ★2".
  ///
  /// Es lo que hace que subir de nivel se note aunque la fachada no cambie.
  /// Sin esto, cuatro de cada cinco subidas serían invisibles.
  final int starWithinTier;

  /// Elementos dibujados en la fachada. Dependen de la fachada, no del nivel.
  final int shelves;
  final int customers;
}

class ShopTiers {
  const ShopTiers._();

  /// Primer nivel de cada fachada. La última fachada llega hasta [maxLevel].
  ///
  /// **La primera banda tiene un solo nivel**, y eso es deliberado: el mesón
  /// improvisado es el punto de partida, no un lugar donde quedarse, así que
  /// la primera subida —la más importante de las treinta, porque es donde el
  /// jugador decide si el juego le interesa— cambia la fachada entera y no
  /// sólo agrega una estrella. De ahí en adelante las bandas son de cinco.
  static const List<int> visualTierStart = <int>[1, 2, 6, 11, 16, 21, 26];

  static const int maxLevel = 30;

  /// Costo del nivel [level]: 120 monedas para el segundo y ×1.34 cada vez.
  ///
  /// El 1.34 es el número que define cuánto dura el juego. Con la escalera
  /// anterior —siete niveles, 76.750 monedas en total— un jugador eficiente
  /// llegaba al tope en **cuatro horas y media**, medido en
  /// `tool/balance_sim.dart`. Esta escalera suma 1,7 millones: el mismo
  /// jugador tarda más de cien horas de juego activo, y en la práctica menos,
  /// porque la caja produce sola mientras tanto.
  static int _costFor(int level) =>
      level <= 1 ? 0 : (120 * math.pow(1.34, level - 2)).round();

  /// Ganancia por hora del nivel [level].
  ///
  /// Crece más lento que el costo (1.30 contra 1.34) a propósito: si creciera
  /// igual o más rápido, a partir de cierto punto el local se pagaría solo y
  /// jugar dejaría de aportar. La parte pasiva tiene que ayudar, no reemplazar.
  static int _incomeFor(int level) => (12 * math.pow(1.30, level - 1)).round();

  static int _visualTierFor(int level) {
    for (int i = visualTierStart.length - 1; i >= 0; i--) {
      if (level >= visualTierStart[i]) return i + 1;
    }
    return 1;
  }

  static final List<ShopTier> all = List<ShopTier>.generate(maxLevel, (int i) {
    final int level = i + 1;
    final int vt = _visualTierFor(level);
    return ShopTier(
      level: level,
      upgradeCost: _costFor(level),
      coinsPerHour: _incomeFor(level),
      visualTier: vt,
      starWithinTier: level - visualTierStart[vt - 1] + 1,
      // La fachada nº n dibuja n estantes y n clientes, como antes.
      shelves: vt,
      customers: vt >= 7 ? 8 : vt,
    );
  }, growable: false);

  static ShopTier byLevel(int level) => all[level.clamp(1, maxLevel) - 1];

  /// Siguiente nivel, o null si ya está al máximo.
  static ShopTier? next(int currentLevel) =>
      currentLevel >= maxLevel ? null : all[currentLevel];

  /// Cuántos niveles tiene la fachada [visualTier]. Se usa para dibujar las
  /// estrellas: "★★☆☆☆" necesita saber cuántas casillas hay.
  static int starsInTier(int visualTier) {
    final int i = visualTier.clamp(1, visualTierStart.length) - 1;
    final int start = visualTierStart[i];
    final int end = i + 1 < visualTierStart.length
        ? visualTierStart[i + 1] - 1
        : maxLevel;
    return end - start + 1;
  }
}
