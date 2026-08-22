import '../../game/economy/economy_config.dart';
import '../../game/models/board.dart';
import '../../game/models/game_state.dart';
import '../../game/models/order.dart';
import '../../game/models/settings.dart';

/// Serialización del save y migraciones de esquema.
///
/// Las migraciones se diseñan desde el día 1 (PLAN_FINAL §10.2): un save viejo
/// nunca debe hacer crashear la app ni borrar el progreso del jugador.
class SaveCodec {
  const SaveCodec._();

  /// Sube cuando cambia la forma del save y agrega una migración abajo.
  static const int currentSchemaVersion = 3;

  static Map<String, dynamic> encode(GameState state) => <String, dynamic>{
    'schemaVersion': currentSchemaVersion,
    'economyVersion': state.economyVersion,
    'board': state.board.toJson(),
    'orders': state.orders
        .map((CustomerOrder o) => o.toJson())
        .toList(growable: false),
    'coins': state.coins,
    'xp': state.xp,
    'shopLevel': state.shopLevel,
    'nextItemId': state.nextItemId,
    'nextOrderId': state.nextOrderId,
    'settings': state.settings.toJson(),
    'tutorialStep': state.tutorialStep.name,
    'lastSeenAt': state.lastSeenAt.toUtc().toIso8601String(),
    'rngSeed': state.rngSeed,
    'discovered': state.discovered.toList(growable: false),
    'totalMerges': state.totalMerges,
    'totalOrdersCompleted': state.totalOrdersCompleted,
    'idleAccrued': state.idleAccrued,
    'lastIncomeAt': state.lastIncomeAt.toUtc().toIso8601String(),
  };

  /// Devuelve null si el save es irrecuperable; el llamador empieza partida
  /// nueva en ese caso.
  static GameState? decode(
    Map<String, dynamic> raw, {
    required EconomyConfig config,
  }) {
    try {
      final Map<String, dynamic> json = migrate(raw);

      final Board board = Board.fromJson(
        Map<String, dynamic>.from(json['board'] as Map),
      );

      final List<CustomerOrder> orders =
          ((json['orders'] as List<dynamic>?) ?? <dynamic>[])
              .map(
                (dynamic e) =>
                    CustomerOrder.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList(growable: false);

      return GameState(
        board: board,
        orders: orders,
        coins: json['coins'] as int,
        xp: json['xp'] as int,
        shopLevel: json['shopLevel'] as int,
        nextItemId: json['nextItemId'] as int,
        nextOrderId: json['nextOrderId'] as int,
        settings: GameSettings.fromJson(
          Map<String, dynamic>.from(
            (json['settings'] as Map?) ?? <String, dynamic>{},
          ),
        ),
        tutorialStep: _tutorialFromName(json['tutorialStep'] as String?),
        lastSeenAt:
            DateTime.tryParse(json['lastSeenAt'] as String? ?? '')?.toLocal() ??
            DateTime.now(),
        rngSeed: json['rngSeed'] as int,
        economyVersion: (json['economyVersion'] as int?) ?? config.version,
        discovered: ((json['discovered'] as List<dynamic>?) ?? <dynamic>[])
            .map((dynamic e) => e as String)
            .toSet(),
        totalMerges: (json['totalMerges'] as int?) ?? 0,
        totalOrdersCompleted: (json['totalOrdersCompleted'] as int?) ?? 0,
        idleAccrued: (json['idleAccrued'] as num?)?.toDouble() ?? 0,
        lastIncomeAt: DateTime.tryParse(json['lastIncomeAt'] as String? ?? '')
            ?.toLocal(),
      );
    } on Object {
      // Save corrupto o de una versión que no sabemos leer.
      return null;
    }
  }

  /// Lleva un save de cualquier versión conocida al esquema actual.
  static Map<String, dynamic> migrate(Map<String, dynamic> raw) {
    Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    int version = (json['schemaVersion'] as int?) ?? 0;

    if (version > currentSchemaVersion) {
      // Save escrito por una versión más nueva de la app (p.ej. downgrade).
      // No lo adivinamos: el llamador empezará de cero.
      throw StateError('save v$version > app v$currentSchemaVersion');
    }

    while (version < currentSchemaVersion) {
      final Map<String, dynamic> Function(Map<String, dynamic>)? step =
          _migrations[version];
      if (step == null) {
        throw StateError('sin migración desde la versión $version');
      }
      json = step(json);
      version++;
      json['schemaVersion'] = version;
    }
    return json;
  }

  /// version -> función que lleva el save a `version + 1`.
  static final Map<int, Map<String, dynamic> Function(Map<String, dynamic>)>
  _migrations = <int, Map<String, dynamic> Function(Map<String, dynamic>)>{
    // v0: primeras builds internas, sin álbum ni contadores de sesión.
    0: (Map<String, dynamic> json) => <String, dynamic>{
      ...json,
      'discovered': json['discovered'] ?? <String>[],
      'totalMerges': json['totalMerges'] ?? 0,
      'totalOrdersCompleted': json['totalOrdersCompleted'] ?? 0,
      'economyVersion': json['economyVersion'] ?? 1,
    },

    // v1 -> v2: el juego se internacionalizó. Los pedidos guardaban el nombre
    // del cliente ya traducido al español; ahora guardan un índice que la UI
    // resuelve en el idioma activo. Los pedidos viejos se reasignan a un
    // cliente estable derivado del id del pedido, para no descartar pedidos
    // que el jugador ya tenía en pantalla.
    1: (Map<String, dynamic> json) {
      final List<dynamic> orders =
          (json['orders'] as List<dynamic>?) ?? <dynamic>[];
      return <String, dynamic>{
        ...json,
        'orders': orders
            .map((dynamic raw) {
              final Map<String, dynamic> order = Map<String, dynamic>.from(
                raw as Map,
              );
              order.remove('customer');
              order['customerId'] ??=
                  ((order['id'] as int?) ?? 0) % _legacyCustomerCount;
              return order;
            })
            .toList(growable: false),
      };
    },

    // v2 -> v3: tablero que se amplía pagando, ganancia pasiva con decimales
    // y bonificación por rapidez en los pedidos.
    //
    // A quien ya venía jugando **no se le quita tablero**: su partida conserva
    // las filas que ya tenía. El tablero chico es sólo el punto de partida de
    // las partidas nuevas.
    2: (Map<String, dynamic> json) {
      final Map<String, dynamic> board = Map<String, dynamic>.from(
        json['board'] as Map,
      );
      board['unlockedRows'] ??= board['rows'];
      return <String, dynamic>{
        ...json,
        'board': board,
        'idleAccrued': json['idleAccrued'] ?? 0,
        // Sin marca previa, la ganancia pasiva se cuenta desde el último
        // guardado: es el mismo instante que usaba el cobro al volver.
        'lastIncomeAt': json['lastIncomeAt'] ?? json['lastSeenAt'],
      };
    },
  };

  /// Cantidad de clientes al momento de la migración v1 -> v2. Se congela acá
  /// a propósito: si mañana se agregan clientes, migrar un save viejo debe
  /// seguir dando el mismo resultado.
  static const int _legacyCustomerCount = 12;

  static TutorialStep _tutorialFromName(String? name) =>
      TutorialStep.values.firstWhere(
        (TutorialStep s) => s.name == name,
        orElse: () => TutorialStep.done,
      );
}
