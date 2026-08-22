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
/// Usa un pool de reproductores en round-robin: fusionar rápido dispara varios
/// sonidos solapados, y un único reproductor cortaría el anterior en cada
/// toque.
///
/// Ningún fallo de audio puede romper el juego: si el dispositivo no puede
/// reproducir, se juega en silencio.
class AudioplayersSoundPlayer implements SoundPlayer {
  AudioplayersSoundPlayer({this.poolSize = 4});

  final int poolSize;
  final List<AudioPlayer> _players = <AudioPlayer>[];
  int _next = 0;
  bool _ready = false;

  @override
  Future<void> preload() async {
    if (_ready) return;
    try {
      for (int i = 0; i < poolSize; i++) {
        final AudioPlayer player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        _players.add(player);
      }
      // Deja los archivos en caché para que el primer toque no tenga lag.
      await AudioCache.instance.loadAll(
        GameSound.values.map((GameSound s) => s.assetPath).toList(),
      );
      _ready = true;
    } on Object catch (error) {
      debugPrint('Audio no disponible: $error');
      _ready = false;
    }
  }

  @override
  void play(GameSound sound) {
    if (!_ready || _players.isEmpty) return;
    final AudioPlayer player = _players[_next];
    _next = (_next + 1) % _players.length;
    // Sin await: el sonido no debe introducir latencia en el gesto.
    unawaited(
      player
          .play(AssetSource(sound.assetPath), volume: 0.7)
          .catchError((Object _) {}),
    );
  }

  @override
  Future<void> dispose() async {
    for (final AudioPlayer player in _players) {
      try {
        await player.dispose();
      } on Object {
        // Nada que hacer si ya estaba liberado.
      }
    }
    _players.clear();
    _ready = false;
  }
}
