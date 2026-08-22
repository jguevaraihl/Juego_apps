import '../economy/economy.dart';
import '../economy/economy_config.dart';
import '../progression/shop_tiers.dart';
import 'board.dart';
import 'order.dart';
import 'settings.dart';

/// Etapas del onboarding. Máximo 3 acciones y se puede saltar (PLAN_FINAL §6).
enum TutorialStep {
  merge,
  completeOrder,
  upgrade,
  done;

  bool get isActive => this != TutorialStep.done;
}

/// Estado completo de la partida. Inmutable: el motor devuelve estados nuevos.
class GameState {
  const GameState({
    required this.board,
    required this.orders,
    required this.coins,
    required this.xp,
    required this.shopLevel,
    required this.nextItemId,
    required this.nextOrderId,
    required this.settings,
    required this.tutorialStep,
    required this.lastSeenAt,
    required this.rngSeed,
    required this.economyVersion,
    this.discovered = const <String>{},
    this.totalMerges = 0,
    this.totalOrdersCompleted = 0,
  });

  final Board board;
  final List<CustomerOrder> orders;
  final int coins;
  final int xp;
  final int shopLevel;

  /// Contadores para generar ids únicos y estables entre sesiones.
  final int nextItemId;
  final int nextOrderId;

  final GameSettings settings;
  final TutorialStep tutorialStep;

  /// Momento del último guardado. Base para la ganancia pasiva.
  final DateTime lastSeenAt;

  /// Semilla persistida: la aleatoriedad sobrevive al cierre de la app.
  final int rngSeed;

  /// Versión de balance con la que se creó/actualizó esta partida.
  final int economyVersion;

  /// Claves "cadena:nivel" ya vistas, para el álbum de productos.
  final Set<String> discovered;

  final int totalMerges;
  final int totalOrdersCompleted;

  ShopTier get shopTier => ShopTiers.byLevel(shopLevel);
  ShopTier? get nextShopTier => ShopTiers.next(shopLevel);

  int playerLevel(Economy economy) => economy.levelForXp(xp);

  GameState copyWith({
    Board? board,
    List<CustomerOrder>? orders,
    int? coins,
    int? xp,
    int? shopLevel,
    int? nextItemId,
    int? nextOrderId,
    GameSettings? settings,
    TutorialStep? tutorialStep,
    DateTime? lastSeenAt,
    int? rngSeed,
    int? economyVersion,
    Set<String>? discovered,
    int? totalMerges,
    int? totalOrdersCompleted,
  }) => GameState(
    board: board ?? this.board,
    orders: orders ?? this.orders,
    coins: coins ?? this.coins,
    xp: xp ?? this.xp,
    shopLevel: shopLevel ?? this.shopLevel,
    nextItemId: nextItemId ?? this.nextItemId,
    nextOrderId: nextOrderId ?? this.nextOrderId,
    settings: settings ?? this.settings,
    tutorialStep: tutorialStep ?? this.tutorialStep,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    rngSeed: rngSeed ?? this.rngSeed,
    economyVersion: economyVersion ?? this.economyVersion,
    discovered: discovered ?? this.discovered,
    totalMerges: totalMerges ?? this.totalMerges,
    totalOrdersCompleted: totalOrdersCompleted ?? this.totalOrdersCompleted,
  );

  /// Partida nueva. No genera pedidos todavía: de eso se encarga el motor,
  /// que es quien tiene el generador y el RNG.
  static GameState initial({
    required EconomyConfig config,
    required DateTime now,
    required int rngSeed,
  }) => GameState(
    board: Board(columns: config.boardColumns, rows: config.boardRows),
    orders: const <CustomerOrder>[],
    coins: config.startingCoins,
    xp: 0,
    shopLevel: 1,
    nextItemId: 1,
    nextOrderId: 1,
    settings: const GameSettings(),
    tutorialStep: TutorialStep.merge,
    lastSeenAt: now,
    rngSeed: rngSeed,
    economyVersion: config.version,
  );
}
