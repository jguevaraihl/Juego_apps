import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../data/repositories/game_repository.dart';
import '../services/analytics/analytics.dart';
import 'economy/economy.dart';
import 'game_engine.dart';
import 'game_events.dart';
import 'models/game_state.dart';
import 'models/settings.dart';

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
  });

  final GameState? state;
  final bool loading;
  final List<GameEvent> events;
  final int eventTicket;

  bool get isReady => state != null && !loading;

  GameSession copyWith({
    GameState? state,
    bool? loading,
    List<GameEvent>? events,
    int? eventTicket,
  }) => GameSession(
    state: state ?? this.state,
    loading: loading ?? this.loading,
    events: events ?? this.events,
    eventTicket: eventTicket ?? this.eventTicket,
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
    final GameStep step = await _repository.load(now: DateTime.now());
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
    await _repository.saveNow(step.state);
  }

  // ------------------------------------------------------------------
  // Acciones de la UI
  // ------------------------------------------------------------------

  void generate() => _apply((GameState s) => _engine.generate(s));

  void drop(int from, int to) =>
      _apply((GameState s) => _engine.drop(s, from, to));

  void sell(int index) => _apply((GameState s) => _engine.sell(s, index));

  void completeOrder(int orderId, {bool withBonus = false}) => _apply(
    (GameState s) => _engine.completeOrder(s, orderId, withBonus: withBonus),
  );

  void rerollOrder(int orderId) =>
      _apply((GameState s) => _engine.rerollOrder(s, orderId));

  void upgradeShop() => _apply((GameState s) => _engine.upgradeShop(s));

  void skipTutorial() => _apply((GameState s) => _engine.skipTutorial(s));

  void updateSettings(GameSettings settings) =>
      _apply((GameState s) => _engine.updateSettings(s, settings));

  /// Se llama al volver del background: cobra la ganancia pasiva y vuelve a
  /// garantizar que haya jugada posible.
  void resumeFromBackground() => _apply(
    (GameState s) => _engine.resume(state: s, now: DateTime.now()),
    save: true,
  );

  /// Guardado inmediato, para cuando la app pasa a segundo plano.
  Future<void> flushSave() => _repository.flush();

  // ------------------------------------------------------------------

  void _apply(GameStep Function(GameState) action, {bool save = true}) {
    final GameState? current = state.state;
    if (current == null) return;

    GameStep step = action(current);

    // Toda acción del jugador deja el tablero en un estado jugable.
    final GameStep relief = _engine.relieveIfStuck(step.state);
    if (relief.events.isNotEmpty) {
      step = GameStep(relief.state, <GameEvent>[
        ...step.events,
        ...relief.events,
      ]);
    }

    state = GameSession(
      state: step.state,
      loading: false,
      events: step.events,
      eventTicket: state.eventTicket + 1,
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
