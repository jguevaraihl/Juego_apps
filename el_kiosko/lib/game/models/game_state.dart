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
    this.freeSortUnlocked = false,
    this.nextBigOrderAt,
    this.mergeStreak = 0,
    this.bestMergeStreak = 0,
    this.bigOrdersDelivered = 0,
    this.tillCollectedTotal = 0,
    this.claimedAchievements = const <String>{},
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

  /// Fusiones encadenadas ahora mismo. Se corta con cualquier otra acción del
  /// jugador: generar, vender, comprar. Fusionar diez veces seguidas es una
  /// tanda de juego real, y eso es lo que premia el logro.
  final int mergeStreak;

  /// La racha más larga que llegó a hacer. El logro mira ésta y no la actual,
  /// para que conseguirlo no dependa de reclamarlo antes de romper la racha.
  final int bestMergeStreak;

  final int bigOrdersDelivered;

  /// Todo lo cobrado de la caja a lo largo de la partida.
  final int tillCollectedTotal;

  /// Logros ya cobrados. Se guardan los ids y no los índices para que agregar
  /// o reordenar logros no le devuelva a nadie un premio que ya recibió.
  final Set<String> claimedAchievements;

  /// A partir de cuándo puede aparecer el próximo pedido mayorista. null en
  /// una partida nueva: se fija la primera vez que se evalúa, para que nadie
  /// abra el juego y le caiga uno encima sin haber jugado nada.
  final DateTime? nextBigOrderAt;

  /// Mejora comprada una sola vez: a partir de ahí, ordenar no cuesta.
  final bool freeSortUnlocked;

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
    bool? freeSortUnlocked,
    DateTime? nextBigOrderAt,
    int? mergeStreak,
    int? bestMergeStreak,
    int? bigOrdersDelivered,
    int? tillCollectedTotal,
    Set<String>? claimedAchievements,
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
    freeSortUnlocked: freeSortUnlocked ?? this.freeSortUnlocked,
    nextBigOrderAt: nextBigOrderAt ?? this.nextBigOrderAt,
    mergeStreak: mergeStreak ?? this.mergeStreak,
    bestMergeStreak: bestMergeStreak ?? this.bestMergeStreak,
    bigOrdersDelivered: bigOrdersDelivered ?? this.bigOrdersDelivered,
    tillCollectedTotal: tillCollectedTotal ?? this.tillCollectedTotal,
    claimedAchievements: claimedAchievements ?? this.claimedAchievements,
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
