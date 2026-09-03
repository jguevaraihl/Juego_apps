import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../data/repositories/game_repository.dart';
import '../services/analytics/analytics.dart';
import 'economy/economy.dart';
import 'game_engine.dart';
import 'game_events.dart';
import 'models/game_state.dart';
import 'models/settings.dart';

/// Acciones que se pueden deshacer, y que la UI nombra en el aviso.
///
/// La lista sale de lo que la gente reclama en los juegos de fusionar: vender
/// sin querer es tan común que varios tienen artículo de soporte titulado
/// "vendí un objeto sin querer". No entran acciones baratas y repetitivas como
/// tocar la caja del proveedor: ofrecer deshacer en cada toque sería ruido.
///
/// **Fusionar tampoco entra**, aunque sea el otro accidente clásico del
/// género. Se probó y el botón terminaba apareciendo en cada jugada —fusionar
/// es el gesto que más se repite— y eso convertía una ayuda en una presencia
/// permanente. La protección contra la fusión equivocada quedó del lado de
/// prevenirla: la casilla de destino avisa en verde o rojo qué va a pasar
/// antes de soltar (D-048).
enum UndoableAction { sell, split, buy, reroll }

/// El estado justo antes de una acción deshacible.
class UndoSnapshot {
  const UndoSnapshot({required this.state, required this.action});

  final GameState state;
  final UndoableAction action;
}

/// Lo que la UI observa: la partida, si todavía está cargando, y los eventos
/// de la última acción.
///
/// [eventTicket] sube en cada acción que emite eventos; la UI lo usa para
/// reaccionar una sola vez a cada tanda (feedback háptico, toasts).
class GameSession {
  const GameSession({
    this.state,
    this.loading = true,
    this.events = const <GameEvent>[],
    this.eventTicket = 0,
    this.undo,
  });

  final GameState? state;
  final bool loading;
  final List<GameEvent> events;
  final int eventTicket;

  /// Qué se puede deshacer ahora mismo, o null si nada. Lo borra la acción
  /// siguiente: la ventana dura hasta que el jugador vuelva a jugar.
  final UndoSnapshot? undo;

  bool get isReady => state != null && !loading;

  /// [clearUndo] permite borrar el snapshot, que copyWith por sí solo no
  /// podría expresar (pasar null significa "no cambiar").
  GameSession copyWith({
    GameState? state,
    bool? loading,
    List<GameEvent>? events,
    int? eventTicket,
    UndoSnapshot? undo,
    bool clearUndo = false,
  }) => GameSession(
    state: state ?? this.state,
    loading: loading ?? this.loading,
    events: events ?? this.events,
    eventTicket: eventTicket ?? this.eventTicket,
    undo: clearUndo ? null : (undo ?? this.undo),
  );
}

/// Orquesta motor + persistencia + analytics. No contiene reglas de juego:
/// esas viven en [GameEngine], que es puro y testeable por separado.
class GameController extends Notifier<GameSession> {
  GameEngine get _engine => ref.read(gameEngineProvider);
  GameRepository get _repository => ref.read(gameRepositoryProvider);
  AnalyticsSink get _analytics => ref.read(analyticsProvider);

  Economy get economy => _engine.economy;

  @override
  GameSession build() {
    unawaited(_load());
    return const GameSession();
  }

  Future<void> _load() async {
    GameStep step;
    try {
      step = await _repository.load(now: DateTime.now());
    } on Object catch (error, stack) {
      // Si el almacenamiento del dispositivo falla (sin espacio, permisos,
      // plataforma sin soporte), es preferible jugar sin guardar que quedarse
      // para siempre en la pantalla de carga.
      debugPrint('No se pudo cargar la partida: $error\n$stack');
      step = _engine.newGame(now: DateTime.now());
    }

    final bool isNewGame =
        step.state.totalOrdersCompleted == 0 &&
        step.state.totalMerges == 0 &&
        step.state.tutorialStep == TutorialStep.merge;

    state = GameSession(
      state: step.state,
      loading: false,
      events: step.events,
      eventTicket: state.eventTicket + 1,
    );

    if (isNewGame) {
      _analytics.log(AnalyticsEvents.firstOpenGame, _baseParams(step.state));
      _analytics.log(AnalyticsEvents.tutorialStart, _baseParams(step.state));
    }
    _report(step);
    // Un fallo al guardar no puede tumbar el arranque: la partida ya está en
    // pantalla y jugable.
    try {
      await _repository.saveNow(step.state);
    } on Object catch (error) {
      debugPrint('No se pudo guardar la partida: $error');
    }
  }

  // ------------------------------------------------------------------
  // Acciones de la UI
  // ------------------------------------------------------------------

  void generate() => _apply((GameState s) => _engine.generate(s));

  void generateAll() => _apply((GameState s) => _engine.generateAll(s));

  void hireWorker(int level) =>
      _apply((GameState s) => _engine.hireWorker(s, level, DateTime.now()));

  void drop(int from, int to) =>
      _apply((GameState s) => _engine.drop(s, from, to));

  void sell(int index) => _apply(
    (GameState s) => _engine.sell(s, index),
    undoable: UndoableAction.sell,
  );

  void completeOrder(int orderId, {bool withBonus = false}) => _apply(
    (GameState s) => _engine.completeOrder(
      s,
      orderId,
      now: DateTime.now(),
      withBonus: withBonus,
    ),
  );

  void completeOrderPartially(int orderId) => _apply(
    (GameState s) =>
        _engine.completeOrderPartially(s, orderId, now: DateTime.now()),
  );

  void rerollOrder(int orderId) => _apply(
    (GameState s) => _engine.rerollOrder(s, orderId, now: DateTime.now()),
    undoable: UndoableAction.reroll,
  );

  void buyProduct(String chainId, int level) => _apply(
    (GameState s) => _engine.buyProduct(s, chainId, level),
    undoable: UndoableAction.buy,
  );

  void splitItem(int index) => _apply(
    (GameState s) => _engine.splitItem(s, index),
    undoable: UndoableAction.split,
  );

  void expandBoard() => _apply((GameState s) => _engine.expandBoard(s));

  void collectTill() =>
      _apply((GameState s) => _engine.collectTill(s, DateTime.now()));

  void upgradeTill() => _apply((GameState s) => _engine.upgradeTill(s));

  void sortBoard() => _apply((GameState s) => _engine.sortBoard(s));

  void claimAchievement(String id) =>
      _apply((GameState s) => _engine.claimAchievement(s, id));

  void buyFreeSort() => _apply((GameState s) => _engine.buyFreeSort(s));

  void upgradeShop() => _apply((GameState s) => _engine.upgradeShop(s));

  void skipTutorial() => _apply((GameState s) => _engine.skipTutorial(s));

  void advanceTutorial() => _apply((GameState s) => _engine.advanceTutorial(s));

  void updateSettings(GameSettings settings) =>
      _apply((GameState s) => _engine.updateSettings(s, settings));

  /// Se llama al volver del background: cobra la ganancia pasiva y vuelve a
  /// garantizar que haya jugada posible.
  void resumeFromBackground() => _apply(
    (GameState s) => _engine.resume(state: s, now: DateTime.now()),
    save: true,
  );

  /// Deshace la última acción deshacible. Sin efecto si no hay ninguna.
  ///
  /// Restaura el tablero y el bolsillo, pero **no el reloj**: la caja siguió
  /// juntando mientras el aviso estaba en pantalla, y devolverla atrás sería
  /// una máquina de rehacer tiempo. Ninguna acción que toque la caja es
  /// deshacible, así que copiar esos campos del estado actual es seguro.
  ///
  /// El álbum tampoco retrocede: descubrir un producto no es un recurso que
  /// se pueda explotar, y borrar una casilla recién marcada se siente a
  /// castigo por arrepentirse.
  void undo() {
    final UndoSnapshot? snapshot = state.undo;
    final GameState? current = state.state;
    if (snapshot == null || current == null) return;

    // Deshacer cobra una comisión chica y fija. No es un castigo por
    // equivocarse —sería mezquino— sino lo que impide que deshacer se use como
    // una jugada más: probar una fusión, mirar el resultado y volver atrás
    // gratis todas las veces que uno quiera.
    final int cost = _engine.config.undoCost;
    if (current.coins < cost) {
      state = state.copyWith(
        events: <GameEvent>[const ActionRejected(RejectReason.notEnoughCoins)],
        eventTicket: state.eventTicket + 1,
      );
      return;
    }

    final GameState restored = snapshot.state.copyWith(
      // La comisión se cobra sobre las monedas que había ANTES de la jugada:
      // ese es el saldo al que se vuelve.
      coins: snapshot.state.coins - cost,
      idleAccrued: current.idleAccrued,
      lastIncomeAt: current.lastIncomeAt,
      lastSeenAt: current.lastSeenAt,
      discovered: current.discovered,
    );

    state = state.copyWith(
      state: restored,
      events: <GameEvent>[ActionUndone(cost)],
      eventTicket: state.eventTicket + 1,
      clearUndo: true,
    );
    _analytics.log(AnalyticsEvents.actionUndone, <String, Object?>{
      ..._baseParams(restored),
      'action': snapshot.action.name,
    });
    _repository.scheduleSave(restored);
  }

  /// Hace aparecer o vencer el pedido mayorista sin que el jugador haga nada.
  /// La llama el reloj de la pantalla cuando el momento ya llegó, para que el
  /// mayorista entre aunque el jugador esté mirando sin tocar.
  void refreshBigOrder() =>
      _apply((GameState s) => _engine.refreshBigOrder(s, DateTime.now()));

  /// Cierra la ventana de deshacer por tiempo. La llama la UI cuando el aviso
  /// se apaga solo, para que el estado no quede diciendo que se puede deshacer
  /// algo que ya no se ofrece en pantalla.
  void expireUndo() {
    if (state.undo == null) return;
    state = state.copyWith(clearUndo: true);
  }

  /// Guardado inmediato, para cuando la app pasa a segundo plano.
  Future<void> flushSave() => _repository.flush();

  // ------------------------------------------------------------------

  /// [undoable] marca la acción como deshacible y guarda el estado previo.
  /// [keepUndo] deja intacta la ventana abierta; lo usa el latido de la
  /// ganancia pasiva, que corre cada segundo y no es una jugada. Cualquier
  /// otra acción cierra la ventana: deshacer vale hasta que vuelvas a jugar.
  void _apply(
    GameStep Function(GameState) action, {
    bool save = true,
    UndoableAction? undoable,
    bool keepUndo = false,
  }) {
    final GameState? current = state.state;
    if (current == null) return;

    GameStep step = action(current);
    // Una acción rechazada no cambió nada, así que tampoco cierra la ventana:
    // que un toque sin monedas te quite el deshacer sería desconcertante.
    final bool rejected = step.events.any((GameEvent e) => e is ActionRejected);

    // El trabajador cobra su tiempo antes que nada: lo que hizo mientras el
    // jugador no estaba tiene que estar aplicado cuando se evalúe el resto.
    final GameStep worked = _engine.runWorker(step.state, DateTime.now());
    step = GameStep(worked.state, <GameEvent>[
      ...step.events,
      ...worked.events,
    ]);

    // Cada acción es también la oportunidad de que entre o se venza el
    // pedido mayorista. Va acá y no en un temporizador para no reintroducir
    // el latido que ponía lento el juego (D-044).
    final GameStep big = _engine.refreshBigOrder(step.state, DateTime.now());
    if (big.events.isNotEmpty) {
      step = GameStep(big.state, <GameEvent>[...step.events, ...big.events]);
    } else {
      step = GameStep(big.state, step.events);
    }

    // Toda acción del jugador deja el tablero en un estado jugable.
    final GameStep relief = _engine.relieveIfStuck(step.state);
    if (relief.events.isNotEmpty) {
      step = GameStep(relief.state, <GameEvent>[
        ...step.events,
        ...relief.events,
      ]);
    }

    // Si tuvo que saltar el rescate del proveedor, no se ofrece deshacer:
    // volvería a dejar al jugador sin salida y el rescate saltaría de nuevo.
    final bool canUndo = undoable != null && !rejected && relief.events.isEmpty;

    state = GameSession(
      state: step.state,
      loading: false,
      events: step.events,
      eventTicket: state.eventTicket + 1,
      undo: canUndo
          ? UndoSnapshot(state: current, action: undoable)
          : (keepUndo || rejected ? state.undo : null),
    );

    _report(step);
    if (save) _repository.scheduleSave(step.state);
  }

  Map<String, Object?> _baseParams(GameState s) => <String, Object?>{
    'economy_version': s.economyVersion,
    'player_level': s.playerLevel(economy),
    'shop_level': s.shopLevel,
  };

  /// Traduce eventos de juego a eventos de analytics. Sin PII.
  void _report(GameStep step) {
    final GameState s = step.state;
    for (final GameEvent event in step.events) {
      switch (event) {
        case ItemGenerated(:final String chainId):
          _analytics.log(AnalyticsEvents.itemGenerated, <String, Object?>{
            ..._baseParams(s),
            'chain': chainId,
          });
        case MergeCompleted(:final String chainId, :final int newLevel):
          _analytics.log(AnalyticsEvents.mergeCompleted, <String, Object?>{
            ..._baseParams(s),
            'chain': chainId,
            'level': newLevel,
          });
        case OrderCompleted(:final int reward, :final int xp):
          _analytics.log(AnalyticsEvents.orderCompleted, <String, Object?>{
            ..._baseParams(s),
            'reward': reward,
            'xp': xp,
          });
        case ShopUpgraded(:final int newLevel):
          _analytics.log(AnalyticsEvents.upgradePurchased, <String, Object?>{
            ..._baseParams(s),
            'new_shop_level': newLevel,
          });
        case TutorialAdvanced() when s.tutorialStep == TutorialStep.done:
          _analytics.log(AnalyticsEvents.tutorialComplete, _baseParams(s));
        default:
          break;
      }
    }
  }
}
