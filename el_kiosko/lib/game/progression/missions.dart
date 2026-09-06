/// Misiones diarias: tres cada día, y mañana otras tres.
///
/// **Para qué existen.** Los logros son metas de por vida —"fusiona 500
/// veces"— y funcionan como coleccionables, pero no le dicen a nadie qué hacer
/// *hoy*. Con una escalera de treinta niveles esa diferencia importa: un
/// jugador que abre el juego en la mitad de la partida se encuentra con una
/// barra de progreso que se mueve despacio y ninguna meta a la vista. Las
/// misiones dan tres metas alcanzables en una sesión, y son la razón concreta
/// de volver mañana.
///
/// **Cómo no se convierten en un castigo.** Las misiones **no vencen con
/// penalización**: al día siguiente aparecen tres nuevas, y no haber cumplido
/// las de ayer no quita nada ni rompe ninguna racha. El brief prohíbe los
/// ganchos de culpa, y una racha diaria que se pierde es exactamente eso: un
/// castigo por tener vida fuera del teléfono.
///
/// **Sin textos**, igual que el resto de los catálogos: acá sólo ids y
/// números.
library;

import 'dart:math' as math;

/// Qué mide una misión. Cada valor es un contador que se lleva **desde el
/// inicio del día**, no desde el inicio de la partida.
enum MissionMetric {
  /// Fusiones hechas hoy.
  merges,

  /// Pedidos entregados hoy.
  orders,

  /// Monedas ganadas hoy.
  coinsEarned,

  /// Unidades pedidas al proveedor hoy.
  generated,

  /// Productos de nivel alto fabricados hoy (nivel 4 o más).
  highLevelMerges,

  /// Veces que se cobró la caja hoy.
  tillCollections,
}

/// Una plantilla de misión. La meta concreta se escala con el nivel del
/// jugador cuando la misión se reparte.
class MissionTemplate {
  const MissionTemplate({
    required this.id,
    required this.metric,
    required this.baseTarget,
    required this.targetPerLevel,
    required this.baseReward,
  });

  /// Identificador estable: se guarda en el save.
  final String id;

  final MissionMetric metric;

  /// Meta en el nivel 1 de jugador.
  final int baseTarget;

  /// Cuánto sube la meta por cada nivel de jugador.
  ///
  /// Sube, pero **mucho más despacio que la capacidad del jugador**: un
  /// jugador de nivel alto fusiona mucho más rápido, así que si la meta
  /// creciera al mismo ritmo las misiones costarían siempre lo mismo y no se
  /// sentiría el progreso. Que se vuelvan más fáciles con el tiempo es
  /// intencional: son el piso de la sesión, no el techo.
  final double targetPerLevel;

  /// Monedas base del premio. Se escala con el nivel al repartirse.
  final int baseReward;

  int targetFor(int playerLevel) =>
      math.max(1, (baseTarget + targetPerLevel * (playerLevel - 1)).round());
}

class Missions {
  const Missions._();

  /// Cuántas misiones hay activas a la vez.
  static const int perDay = 3;

  /// A partir de qué nivel de jugador aparecen.
  ///
  /// No desde el primer minuto: el jugador nuevo ya tiene el tutorial, los
  /// pedidos y el local que subir. Una cuarta lista de metas en la primera
  /// sesión es ruido, no dirección.
  static const int unlockPlayerLevel = 3;

  /// El premio de una misión, escalado al nivel del jugador.
  ///
  /// **Crece más despacio que la escalera del local** —1.26 contra 1.34— y eso
  /// es lo que mantiene a las misiones en su sitio: aportan del orden de un
  /// tercio de una subida de nivel al principio y menos a medida que la
  /// partida avanza. Si pagaran de más, el juego óptimo sería abrir la app una
  /// vez al día, cobrar y cerrarla, que es exactamente lo contrario de lo que
  /// las misiones vienen a producir.
  ///
  /// Hay un test que compara los tres premios del día contra lo que cuesta
  /// subir el local en ese nivel, y falla si alguna vez lo superan.
  static int rewardFor(int baseReward, int playerLevel) =>
      math.max(1, (baseReward * math.pow(1.26, playerLevel - 1)).round());

  static const List<MissionTemplate> all = <MissionTemplate>[
    MissionTemplate(
      id: 'daily_merges',
      metric: MissionMetric.merges,
      baseTarget: 20,
      targetPerLevel: 3,
      baseReward: 18,
    ),
    MissionTemplate(
      id: 'daily_merges_big',
      metric: MissionMetric.merges,
      baseTarget: 60,
      targetPerLevel: 8,
      baseReward: 22,
    ),
    MissionTemplate(
      id: 'daily_orders',
      metric: MissionMetric.orders,
      baseTarget: 5,
      targetPerLevel: 0.6,
      baseReward: 25,
    ),
    MissionTemplate(
      id: 'daily_orders_big',
      metric: MissionMetric.orders,
      baseTarget: 12,
      targetPerLevel: 1.2,
      baseReward: 58,
    ),
    MissionTemplate(
      id: 'daily_generate',
      metric: MissionMetric.generated,
      baseTarget: 30,
      targetPerLevel: 5,
      baseReward: 20,
    ),
    MissionTemplate(
      id: 'daily_high_level',
      metric: MissionMetric.highLevelMerges,
      baseTarget: 3,
      targetPerLevel: 0.5,
      baseReward: 40,
    ),
    MissionTemplate(
      id: 'daily_coins',
      metric: MissionMetric.coinsEarned,
      baseTarget: 200,
      targetPerLevel: 60,
      baseReward: 27,
    ),
    MissionTemplate(
      id: 'daily_till',
      metric: MissionMetric.tillCollections,
      baseTarget: 2,
      targetPerLevel: 0.15,
      baseReward: 50,
    ),
  ];

  static MissionTemplate? byId(String id) {
    for (final MissionTemplate t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Reparte las misiones del día [dayNumber] para un jugador de [playerLevel].
  ///
  /// El reparto es **determinista a partir del día**: dos aperturas del mismo
  /// día dan las mismas tres misiones, sin necesidad de guardar cuáles
  /// tocaron ni de consultar a nadie. Si el jugador cambia la fecha del
  /// teléfono verá otras tres, pero el progreso del día se reinicia con ellas,
  /// así que no hay nada que ganar haciéndolo.
  static List<MissionTemplate> forDay(int dayNumber, int playerLevel) {
    final List<MissionTemplate> pool = List<MissionTemplate>.of(all);
    // Barajado determinista: el mismo día siempre da el mismo orden.
    final math.Random rng = math.Random(dayNumber * 7919 + 13);
    for (int i = pool.length - 1; i > 0; i--) {
      final int j = rng.nextInt(i + 1);
      final MissionTemplate tmp = pool[i];
      pool[i] = pool[j];
      pool[j] = tmp;
    }
    // Nunca dos misiones de la misma métrica el mismo día: tres formas de
    // decir "fusiona" no son tres metas, son una escrita tres veces.
    final List<MissionTemplate> picked = <MissionTemplate>[];
    final Set<MissionMetric> used = <MissionMetric>{};
    for (final MissionTemplate t in pool) {
      if (used.add(t.metric)) picked.add(t);
      if (picked.length == perDay) break;
    }
    return picked;
  }
}
