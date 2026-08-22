import 'dart:async';

import '../../game/economy/economy_config.dart';
import '../../game/game_engine.dart';
import '../../game/models/game_state.dart';
import '../local/save_codec.dart';
import '../local/save_store.dart';

/// Puente entre el motor y el almacenamiento local.
///
/// El autoguardado está debounced: el jugador hace muchas acciones por
/// segundo (arrastres, merges) y escribir en cada una castiga a los teléfonos
/// de gama baja.
class GameRepository {
  GameRepository(
    this._store,
    this._engine, {
    this.autosaveDelay = const Duration(milliseconds: 800),
  });

  final SaveStore _store;
  final GameEngine _engine;
  final Duration autosaveDelay;

  Timer? _debounce;
  GameState? _pending;

  EconomyConfig get config => _engine.config;

  /// Carga la partida guardada. Si no hay, o el save es irrecuperable,
  /// devuelve una partida nueva.
  Future<GameStep> load({required DateTime now}) async {
    final Map<String, dynamic>? raw = await _store.read();
    if (raw == null) return _engine.newGame(now: now);

    final GameState? state = SaveCodec.decode(raw, config: config);
    if (state == null) return _engine.newGame(now: now);

    return _engine.resume(state: state, now: now);
  }

  /// Programa un guardado. Llamadas seguidas colapsan en una sola escritura.
  void scheduleSave(GameState state) {
    _pending = state;
    _debounce?.cancel();
    _debounce = Timer(autosaveDelay, () {
      unawaited(flush());
    });
  }

  /// Escribe de inmediato lo que esté pendiente. Se usa al pausar la app.
  Future<void> flush() async {
    _debounce?.cancel();
    _debounce = null;
    final GameState? state = _pending;
    if (state == null) return;
    _pending = null;
    await _store.write(SaveCodec.encode(state));
  }

  Future<void> saveNow(GameState state) async {
    _pending = state;
    await flush();
  }

  Future<void> deleteSave() async {
    _debounce?.cancel();
    _debounce = null;
    _pending = null;
    await _store.clear();
  }

  void dispose() {
    _debounce?.cancel();
    _debounce = null;
  }
}
