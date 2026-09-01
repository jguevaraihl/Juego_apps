/// Catálogo de logros.
///
/// **Sin textos.** Igual que el catálogo de productos, acá viven sólo los
/// identificadores y los números; los nombres y descripciones se resuelven en
/// la UI contra lib/l10n, para que la misma partida se lea en cualquier
/// idioma (D-021).
///
/// **Qué se mide y qué no.** Todos los logros de esta tanda se calculan con
/// contadores que la partida ya lleva o que se agregan acá: nada depende de
/// amigos, barrios ni empleados, porque esas funciones todavía no existen. Los
/// identificadores de esas familias están reservados abajo para que agregarlas
/// sea sumar una fila y no rehacer el sistema.
library;

/// De qué depende un logro. Cada valor se mapea a un contador de la partida.
enum AchievementMetric {
  /// Fusiones hechas en total.
  merges,

  /// Fusiones encadenadas sin hacer otra cosa en el medio.
  mergeStreak,

  /// Pedidos entregados en total.
  ordersDelivered,

  /// Pedidos mayoristas entregados.
  bigOrdersDelivered,

  /// Nivel más alto alcanzado por el local.
  shopLevel,

  /// Productos distintos descubiertos en el álbum.
  discovered,

  /// Monedas cobradas de la caja, acumuladas.
  tillCollected,
}

class Achievement {
  const Achievement({
    required this.id,
    required this.metric,
    required this.target,
    required this.reward,
  });

  /// Identificador estable. **Nunca cambia**: es lo que se guarda en el save.
  final String id;

  final AchievementMetric metric;

  /// Cuánto hay que alcanzar.
  final int target;

  /// Monedas que paga al reclamarlo.
  final int reward;
}

class Achievements {
  const Achievements._();

  /// Los logros, en el orden en que se muestran.
  ///
  /// Las escaleras (3 → 25 → 150 fusiones) existen porque un logro suelto se
  /// consigue una vez y se olvida; una escalera acompaña toda la partida. Las
  /// recompensas crecen más rápido que las metas para que el último escalón
  /// siga valiendo la pena cuando el jugador ya maneja muchas monedas.
  static const List<Achievement> all = <Achievement>[
    // Fusionar: el gesto central del juego.
    Achievement(
      id: 'merges_1',
      metric: AchievementMetric.merges,
      target: 10,
      reward: 30,
    ),
    Achievement(
      id: 'merges_2',
      metric: AchievementMetric.merges,
      target: 100,
      reward: 250,
    ),
    Achievement(
      id: 'merges_3',
      metric: AchievementMetric.merges,
      target: 500,
      reward: 1500,
    ),

    // Rachas: fusionar varias veces seguidas, sin generar ni vender en el
    // medio. Premia jugar en tandas, que es como se juega de verdad.
    Achievement(
      id: 'streak_1',
      metric: AchievementMetric.mergeStreak,
      target: 5,
      reward: 60,
    ),
    Achievement(
      id: 'streak_2',
      metric: AchievementMetric.mergeStreak,
      target: 10,
      reward: 300,
    ),

    // Atender: el otro medio del bucle.
    Achievement(
      id: 'orders_1',
      metric: AchievementMetric.ordersDelivered,
      target: 10,
      reward: 40,
    ),
    Achievement(
      id: 'orders_2',
      metric: AchievementMetric.ordersDelivered,
      target: 75,
      reward: 400,
    ),
    Achievement(
      id: 'orders_3',
      metric: AchievementMetric.ordersDelivered,
      target: 300,
      reward: 2000,
    ),

    // Mayoristas: son escasos, así que las metas son bajas y pagan bien.
    Achievement(
      id: 'wholesale_1',
      metric: AchievementMetric.bigOrdersDelivered,
      target: 1,
      reward: 150,
    ),
    Achievement(
      id: 'wholesale_2',
      metric: AchievementMetric.bigOrdersDelivered,
      target: 10,
      reward: 1200,
    ),

    // El local: la meta visible de largo plazo.
    Achievement(
      id: 'shop_3',
      metric: AchievementMetric.shopLevel,
      target: 3,
      reward: 120,
    ),
    Achievement(
      id: 'shop_5',
      metric: AchievementMetric.shopLevel,
      target: 5,
      reward: 800,
    ),
    Achievement(
      id: 'shop_7',
      metric: AchievementMetric.shopLevel,
      target: 7,
      reward: 3000,
    ),

    // El álbum: premia explorar en vez de repetir la cadena más cómoda.
    Achievement(
      id: 'album_1',
      metric: AchievementMetric.discovered,
      target: 8,
      reward: 80,
    ),
    Achievement(
      id: 'album_2',
      metric: AchievementMetric.discovered,
      target: 22,
      reward: 1800,
    ),

    // La caja: premia volver.
    Achievement(
      id: 'till_1',
      metric: AchievementMetric.tillCollected,
      target: 500,
      reward: 100,
    ),
    Achievement(
      id: 'till_2',
      metric: AchievementMetric.tillCollected,
      target: 10000,
      reward: 1000,
    ),
  ];

  static Achievement? byId(String id) {
    for (final Achievement a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Familias reservadas para cuando existan las funciones que las alimentan.
  /// Están acá y no en un comentario suelto para que quede claro que el
  /// sistema ya las contempla y sólo falta el dato:
  ///
  /// - `friends_*`  — invitar amigos. Necesita atribución y backend
  ///   (MONETIZATION_DESIGN §7b).
  /// - `barrio_*`   — cambiarse de barrio. Necesita el meta de barrios.
  /// - `staff_*`    — contratar un locatario. Necesita el meta de empleados.
  static const List<String> reservedFamilies = <String>[
    'friends',
    'barrio',
    'staff',
  ];
}
