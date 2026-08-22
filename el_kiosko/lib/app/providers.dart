import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/save_store.dart';
import '../data/local/save_store_factory.dart';
import '../data/repositories/game_repository.dart';
import '../game/economy/economy.dart';
import '../game/economy/economy_config.dart';
import '../game/game_controller.dart';
import '../game/game_engine.dart';
import '../services/analytics/analytics.dart';

/// Configuración de balance. Se sobreescribe en tests para fijar números.
final Provider<EconomyConfig> economyConfigProvider = Provider<EconomyConfig>(
  (Ref ref) => EconomyConfig.defaults,
);

final Provider<GameEngine> gameEngineProvider = Provider<GameEngine>(
  (Ref ref) => GameEngine(config: ref.watch(economyConfigProvider)),
);

final Provider<Economy> economyProvider = Provider<Economy>(
  (Ref ref) => ref.watch(gameEngineProvider).economy,
);

/// Dónde se guarda la partida. La implementación concreta la elige la
/// plataforma (ver save_store_factory.dart). En tests se sobreescribe por
/// [MemorySaveStore].
final Provider<SaveStore> saveStoreProvider = Provider<SaveStore>(
  (Ref ref) => createSaveStore(),
);

/// En Fase 1 no sale ningún dato del dispositivo. Fase 2 cambia esta línea
/// por el sink de Firebase Analytics.
final Provider<AnalyticsSink> analyticsProvider = Provider<AnalyticsSink>(
  (Ref ref) => const DebugAnalytics(),
);

final Provider<GameRepository> gameRepositoryProvider =
    Provider<GameRepository>((Ref ref) {
      final GameRepository repository = GameRepository(
        ref.watch(saveStoreProvider),
        ref.watch(gameEngineProvider),
      );
      ref.onDispose(repository.dispose);
      return repository;
    });

final NotifierProvider<GameController, GameSession> gameControllerProvider =
    NotifierProvider<GameController, GameSession>(GameController.new);
