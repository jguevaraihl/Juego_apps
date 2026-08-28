import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Efectos de sonido del juego. Los archivos los genera
/// `tools/generate_sounds.py` (ver ASSET_LICENSES.md).
enum GameSound {
  /// Llega mercadería desde la caja del proveedor.
  spawn('spawn.wav'),

  /// Se levanta una ficha para arrastrarla.
  pick('pick.wav'),

  /// Se fusionan dos productos de nivel 2.
  merge2('merge_2.wav'),
  merge3('merge_3.wav'),
  merge4('merge_4.wav'),
  merge5('merge_5.wav'),

  /// Se alcanza el nivel máximo de una cadena.
  maxLevel('max_level.wav'),

  /// Se cobra un pedido.
  coin('coin.wav'),

  /// Se mejora el local.
  upgrade('upgrade.wav'),

  /// Se vende un excedente.
  sell('sell.wav');

  const GameSound(this.file);

  final String file;

  String get assetPath => 'sounds/$file';

  /// Sonido de fusión según el nivel resultante. Sube por la escala, así que
  /// encadenar fusiones suena como una melodía que asciende.
  static GameSound forMergeLevel(int level) => switch (level) {
    <= 2 => merge2,
    3 => merge3,
    4 => merge4,
    _ => merge5,
  };
}

/// Reproductor de efectos. Se abstrae para que los tests de widget no toquen
/// el canal nativo de audio.
abstract class SoundPlayer {
  Future<void> preload();
  void play(GameSound sound);
  Future<void> dispose();
}

/// No hace nada. Es lo que se usa en tests.
class NoopSoundPlayer implements SoundPlayer {
  const NoopSoundPlayer();

  @override
  Future<void> preload() async {}

  @override
  void play(GameSound sound) {}

  @override
  Future<void> dispose() async {}
}

/// Implementación real sobre `audioplayers`.
///
/// **Un reproductor por sonido, con la fuente puesta una sola vez.** La
/// versión anterior llamaba `player.play(AssetSource(...))` en cada efecto, y
/// eso hace tres saltos al canal nativo —volumen, fuente y reproducir— más un
/// `prepare` del archivo, *cada vez*. Encadenando fusiones rápido, esas
/// llamadas se acumulaban en la cola del canal más rápido de lo que se
/// resolvían: los sonidos llegaban tarde y, como el canal es el mismo que usa
/// todo lo demás, el juego entero se ponía lento a medida que la sesión
/// avanzaba. La documentación del propio paquete lo dice: para bajar la
/// latencia hay que llamar `setSource` antes y `resume` por separado.
///
/// Ahora `preload()` deja los diez reproductores listos con su archivo y su
/// volumen, y reproducir es **una** llamada.
///
/// Ningún fallo de audio puede romper el juego: si el dispositivo no puede
/// reproducir, se juega en silencio.
class AudioplayersSoundPlayer implements SoundPlayer {
  AudioplayersSoundPlayer();

  final Map<GameSound, AudioPlayer> _players = <GameSound, AudioPlayer>{};
  final Map<GameSound, DateTime> _lastPlayed = <GameSound, DateTime>{};
  bool _ready = false;

  /// Dos disparos del mismo efecto más juntos que esto no se distinguen de
  /// uno solo, así que el segundo se descarta. Es el freno que evita que una
  /// ráfaga de fusiones inunde el canal nativo.
  static const Duration _minGap = Duration(milliseconds: 60);

  @override
  Future<void> preload() async {
    if (_ready) return;
    try {
      for (final GameSound sound in GameSound.values) {
        final AudioPlayer player = AudioPlayer(playerId: 'sfx_${sound.name}');
        await player.setPlayerMode(PlayerMode.lowLatency);
        // `stop` deja el cursor al principio al terminar, así que volver a
        // sonar es un `resume` y nada más.
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setVolume(0.7);
        await player.setSource(AssetSource(sound.assetPath));
        _players[sound] = player;
      }
      _ready = true;
    } on Object catch (error) {
      debugPrint('Audio no disponible: $error');
      _ready = false;
    }
  }

  @override
  void play(GameSound sound) {
    if (!_ready) return;
    final AudioPlayer? player = _players[sound];
    if (player == null) return;

    final DateTime now = DateTime.now();
    final DateTime? last = _lastPlayed[sound];
    if (last != null && now.difference(last) < _minGap) return;
    _lastPlayed[sound] = now;

    // Sin await: el sonido no puede meterle latencia al gesto. Si el efecto
    // todavía estaba sonando, `stop` lo rebobina; si no, no cuesta nada.
    unawaited(
      player.stop().then((_) => player.resume()).catchError((Object _) {}),
    );
  }

  @override
  Future<void> dispose() async {
    for (final AudioPlayer player in _players.values) {
      try {
        await player.dispose();
      } on Object {
        // Nada que hacer si ya estaba liberado.
      }
    }
    _players.clear();
    _lastPlayed.clear();
    _ready = false;
  }
}
