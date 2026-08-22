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
  static const int currentSchemaVersion = 1;

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
  };

  static TutorialStep _tutorialFromName(String? name) =>
      TutorialStep.values.firstWhere(
        (TutorialStep s) => s.name == name,
        orElse: () => TutorialStep.done,
      );
}
