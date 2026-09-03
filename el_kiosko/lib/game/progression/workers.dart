/// Los trabajadores que se contratan por horas.
///
/// **Qué hace un trabajador.** Mientras dura su contrato, y sobre todo
/// mientras el jugador no está, el trabajador hace dos cosas: junta mercadería
/// que ya está en el mesón (fusiona) y pide más al proveedor si hay monedas.
/// No entrega pedidos: elegir a quién se le vende sigue siendo del jugador,
/// porque ahí está la decisión y por lo tanto el juego.
///
/// **Por qué se le pone tope de nivel.** Uno de nivel 1 sólo junta lo más
/// básico. Si juntara todo, contratarlo una vez reemplazaría al jugador y el
/// juego se jugaría solo. Subiendo de nivel llega más arriba, cuesta más, y
/// sigue sin tocar los niveles altos, que son los que dan el logro de fusionar.
///
/// **Por qué el contrato vence.** El brief prohíbe los ganchos de culpa, y un
/// empleado permanente convertiría el juego en una pantalla que se mira. Que
/// haya que volver a contratarlo es una razón para volver que no castiga a
/// nadie: si no vuelves, simplemente no está trabajando.
library;

class WorkerTier {
  const WorkerTier({
    required this.level,
    required this.hireCost,
    required this.hours,
    required this.maxMergeLevel,
    required this.actionsPerHour,
  });

  final int level;

  /// Lo que cuesta contratarlo, en monedas.
  final int hireCost;

  /// Cuántas horas dura el contrato.
  final int hours;

  /// El nivel más alto que sabe juntar. Por encima de esto no toca nada.
  final int maxMergeLevel;

  /// Cuántas acciones hace por hora. Una acción es juntar un par o pedirle
  /// una unidad al proveedor.
  final int actionsPerHour;
}

class Workers {
  const Workers._();

  /// Los tres niveles. El costo por hora sube más rápido que la eficiencia a
  /// propósito: el trabajador es una comodidad, no una inversión que se paga
  /// sola. Si rindiera más de lo que cuesta, lo óptimo sería no jugar nunca.
  static const List<WorkerTier> all = <WorkerTier>[
    WorkerTier(
      level: 1,
      hireCost: 400,
      hours: 2,
      maxMergeLevel: 2,
      actionsPerHour: 30,
    ),
    WorkerTier(
      level: 2,
      hireCost: 1800,
      hours: 4,
      maxMergeLevel: 3,
      actionsPerHour: 60,
    ),
    WorkerTier(
      level: 3,
      hireCost: 7000,
      hours: 8,
      maxMergeLevel: 4,
      actionsPerHour: 110,
    ),
  ];

  static int get maxLevel => all.length;

  static WorkerTier byLevel(int level) =>
      all[(level - 1).clamp(0, all.length - 1)];

  /// A partir de qué nivel de local se puede contratar. Antes de eso el
  /// jugador todavía está aprendiendo el bucle y automatizarlo se lo saltaría.
  static const int unlockShopLevel = 3;
}
