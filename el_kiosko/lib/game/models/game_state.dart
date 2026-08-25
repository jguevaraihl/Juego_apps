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

  /// Paso siguiente, para el botón "Siguiente" del onboarding.
  TutorialStep get next => switch (this) {
    TutorialStep.merge => TutorialStep.completeOrder,
    TutorialStep.completeOrder => TutorialStep.upgrade,
    TutorialStep.upgrade => TutorialStep.done,
    TutorialStep.done => TutorialStep.done,
  };
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
    this.idleAccrued = 0,
    this.tillLevel = 1,
    DateTime? lastIncomeAt,
  }) : lastIncomeAt = lastIncomeAt ?? lastSeenAt;

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

  /// Saldo de la caja: lo que el almacén lleva vendido y el jugador todavía no
  /// cobra. Sube con decimales para que se vea acumular, y **deja de subir**
  /// al llegar al tope (ver [EconomyConfig.tillHours]).
  final double idleAccrued;

  /// Nivel de la caja. Cada nivel aguanta más horas de ganancia antes de
  /// llenarse.
  final int tillLevel;

  /// Última vez que se acreditó la ganancia pasiva. Se separa de [lastSeenAt]
  /// para que el contador en vivo y el cobro al volver usen el mismo reloj sin
  /// pisarse.
  final DateTime lastIncomeAt;

  /// Lo cobrable de la caja, en monedas enteras.
  int get tillCoins => idleAccrued.floor();

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
    double? idleAccrued,
    int? tillLevel,
    DateTime? lastIncomeAt,
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
    idleAccrued: idleAccrued ?? this.idleAccrued,
    tillLevel: tillLevel ?? this.tillLevel,
    lastIncomeAt: lastIncomeAt ?? this.lastIncomeAt,
  );

  /// Partida nueva. No genera pedidos todavía: de eso se encarga el motor,
  /// que es quien tiene el generador y el RNG.
  static GameState initial({
    required EconomyConfig config,
    required DateTime now,
    required int rngSeed,
  }) => GameState(
    board: Board(
      columns: config.boardColumns,
      rows: config.boardRows,
      unlockedRows: config.startingRows,
    ),
    orders: const <CustomerOrder>[],
    coins: config.startingCoins,
    xp: 0,
    shopLevel: 1,
    nextItemId: 1,
    nextOrderId: 1,
    settings: const GameSettings(),
    tutorialStep: TutorialStep.merge,
    lastSeenAt: now,
    lastIncomeAt: now,
    rngSeed: rngSeed,
    economyVersion: config.version,
  );
}
