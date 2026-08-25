import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../game/board/board_ops.dart';
import '../../game/economy/economy.dart';
import '../../game/economy/economy_config.dart';
import '../../game/game_controller.dart';
import '../../game/game_engine.dart';
import '../../game/game_events.dart';
import '../../game/models/board_item.dart';
import '../../game/models/game_state.dart';
import '../../game/models/order.dart';
import '../../game/models/product.dart';
import '../../game/progression/shop_tiers.dart';
import '../../l10n/app_localizations.dart';
import '../common/game_strings.dart';
import '../../services/audio/sound_service.dart';
import '../../services/haptics.dart';
import 'widgets/action_sheets.dart';
import 'widgets/coin_burst.dart';
import 'widgets/board_view.dart';
import 'widgets/generator_bar.dart';
import 'widgets/offline_earnings_sheet.dart';
import 'widgets/onboarding_overlay.dart';
import 'widgets/order_panel.dart';
import 'widgets/storefront.dart';
import 'widgets/till_chip.dart';
import 'widgets/top_bar.dart';

/// Pantalla principal: es el tablero. Todo lo demás son hojas o pantallas
/// secundarias, para que el juego arranque en una sola pantalla.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _sellMode = false;
  (int, int)? _hint;
  Timer? _idleTimer;

  /// Cada "+N" activo sobre el contador de monedas, con una key propia para
  /// que varios seguidos convivan sin pisarse.
  final List<({int id, int amount})> _bursts = <({int id, int amount})>[];
  int _nextBurstId = 0;

  /// Late una vez por segundo: acredita la ganancia pasiva y refresca los
  /// contadores de bonificación de los pedidos.
  Timer? _incomeTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Deja los efectos en caché para que el primer toque no tenga lag.
    unawaited(ref.read(soundPlayerProvider).preload());
    _incomeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      ref.read(gameControllerProvider.notifier).tickIncome();
      setState(() => _now = DateTime.now());
    });
  }

  void _addBurst(int amount) {
    if (amount <= 0 || !mounted) return;
    setState(() => _bursts.add((id: _nextBurstId++, amount: amount)));
  }

  @override
  void dispose() {
    _incomeTimer?.cancel();
    _idleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final GameController controller = ref.read(gameControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Guardado inmediato: el sistema puede matar la app en cualquier momento.
        unawaited(controller.flushSave());
        unawaited(_scheduleTillNotification());
      case AppLifecycleState.resumed:
        controller.resumeFromBackground();
        // Si el jugador ya está adentro, avisarle no tiene sentido.
        unawaited(ref.read(notificationServiceProvider).cancelAll());
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// Programa el aviso de "caja llena" para cuando corresponda.
  ///
  /// Se hace al salir de la app y no antes: hasta ese momento el jugador está
  /// jugando y la hora estimada sigue cambiando.
  Future<void> _scheduleTillNotification() async {
    final GameState? state = ref.read(gameControllerProvider).state;
    if (state == null || !state.settings.notificationsEnabled) return;
    if (!mounted) return;

    final GameEngine engine = ref.read(gameEngineProvider);
    final DateTime? when = engine.tillFullAt(state);
    if (when == null) return;

    final AppLocalizations l = AppLocalizations.of(context);
    await ref
        .read(notificationServiceProvider)
        .scheduleTillFull(
          when: when,
          title: l.notificationTillFullTitle,
          body: l.notificationTillFullBody,
        );
  }

  void _restartIdleTimer(GameState state) {
    _idleTimer?.cancel();
    if (_hint != null) setState(() => _hint = null);
    if (!state.settings.showIdleHints) return;

    final EconomyConfig config = ref.read(economyConfigProvider);
    _idleTimer = Timer(Duration(seconds: config.idleHintSeconds), () {
      final GameState? current = ref.read(gameControllerProvider).state;
      if (current == null || !mounted) return;
      final (int, int)? hint = BoardOps.findMergeHint(current.board);
      if (hint != null) setState(() => _hint = hint);
    });
  }

  /// Traduce eventos del motor en feedback: háptico, sonido y avisos cortos.
  void _handleEvents(List<GameEvent> events, GameState state) {
    final GameFeedback feedback = GameFeedback(
      haptics: state.settings.hapticsEnabled,
    );
    final SoundPlayer sounds = ref.read(soundPlayerProvider);
    final bool soundOn = state.settings.soundEnabled;
    void playSound(GameSound sound) {
      if (soundOn) sounds.play(sound);
    }

    final AppLocalizations l = AppLocalizations.of(context);

    for (final GameEvent event in events) {
      switch (event) {
        case ItemGenerated():
          feedback.light();
          playSound(GameSound.spawn);
        case MergeCompleted(:final String chainId, :final int newLevel):
          feedback.selection();
          // Al llegar al tope de la cadena suena distinto: es un logro, no
          // una fusión más.
          final bool isMax = newLevel >= ProductCatalog.byId(chainId).maxLevel;
          playSound(
            isMax ? GameSound.maxLevel : GameSound.forMergeLevel(newLevel),
          );
        case OrderCompleted(:final int reward, :final bool withTimeBonus):
          feedback.success();
          playSound(GameSound.coin);
          _addBurst(reward);
          _toast(
            withTimeBonus
                ? l.toastTimeBonus(reward)
                : l.toastOrderDelivered(reward),
          );
        case ShopUpgraded(:final int newLevel):
          feedback.heavy();
          playSound(GameSound.upgrade);
          _toast(
            l.toastShopUpgraded(l.shopTierName(newLevel)),
            level: newLevel,
          );
        case PlayerLeveledUp(:final int newLevel):
          _toast(l.toastLevelUp(newLevel));
        case ChainUnlocked(:final String chainId):
          _toast(l.toastChainUnlocked(l.chainName(chainId)));
        case ProductBought(:final int price):
          feedback.light();
          playSound(GameSound.spawn);
          _toast(l.toastBought(price));
        case ItemSplit(:final int cost):
          feedback.selection();
          playSound(GameSound.pick);
          _toast(l.toastSplit(cost));
        case BoardExpanded():
          feedback.heavy();
          playSound(GameSound.upgrade);
          _toast(l.toastExpanded);
        case ItemSold(:final int value):
          feedback.light();
          playSound(GameSound.sell);
          _addBurst(value);
          _toast(l.toastSold(value));
        case OrderPartiallyCompleted(:final int reward):
          feedback.light();
          playSound(GameSound.coin);
          _addBurst(reward);
          _toast(l.toastPartial(reward));
        case OrderRerolled():
          feedback.light();
        case EmergencyRelief(:final int amount):
          _addBurst(amount);
          _toast(l.toastRelief(amount));
        case TillCollected(:final int amount):
          feedback.success();
          playSound(GameSound.coin);
          _addBurst(amount);
          _toast(l.toastTillCollected(amount));
        case TillUpgraded():
          feedback.heavy();
          playSound(GameSound.upgrade);
          _toast(l.toastTillUpgraded);
        case OfflineEarningsClaimed(:final int earned, :final int total):
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            unawaited(
              OfflineEarningsSheet.show(
                context,
                earned: earned,
                total: total,
                onCollect: ref
                    .read(gameControllerProvider.notifier)
                    .collectTill,
              ),
            );
          });
        case ActionRejected(:final RejectReason reason):
          _toast(switch (reason) {
            RejectReason.notEnoughCoins => l.toastNotEnoughCoins,
            RejectReason.boardFull => l.toastBoardFull,
            RejectReason.orderNotReady => l.toastOrderNotReady,
            RejectReason.maxShopLevel => l.toastMaxShopLevel,
            RejectReason.boardAtMaxSize => l.boardMaxSize,
            RejectReason.cannotSplit => l.toastCannotSplit,
            RejectReason.partialNotAvailable => l.toastOrderNotReady,
            RejectReason.tillAtMaxLevel => l.tillAtMax,
          });
        default:
          break;
      }
    }
  }

  void _toast(String message, {int? level}) {
    if (!mounted) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          key: ValueKey<String>('$message$level'),
          content: Text(message),
          duration: const Duration(milliseconds: 1700),
        ),
      );
  }

  Future<void> _openExpandSheet(GameState state, EconomyConfig config) {
    final int nextRow = state.board.unlockedRows + 1;
    final int cost = config.expandCost(nextRow);
    return ExpandSheet.show(
      context,
      cost: cost,
      columns: state.board.columns,
      affordable: state.coins >= cost,
      atMaxSize: !state.board.canExpand,
      onExpand: () => ref.read(gameControllerProvider.notifier).expandBoard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameSession>(gameControllerProvider, (
      GameSession? previous,
      GameSession next,
    ) {
      final GameState? state = next.state;
      if (state == null) return;
      if (previous?.eventTicket != next.eventTicket && next.events.isNotEmpty) {
        _handleEvents(next.events, state);
      }
      _restartIdleTimer(state);
    });

    final GameSession session = ref.watch(gameControllerProvider);
    final GameState? state = session.state;

    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Economy economy = ref.read(economyProvider);
    final GameEngine engine = ref.read(gameEngineProvider);
    final EconomyConfig config = ref.read(economyConfigProvider);
    final GameController controller = ref.read(gameControllerProvider.notifier);

    final ShopTier? nextTier = state.nextShopTier;
    final bool upgradeAvailable =
        nextTier != null && state.coins >= nextTier.upgradeCost;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                TopBar(
                  coins: state.coins,
                  playerLevel: state.playerLevel(economy),
                  levelProgress: economy.levelProgress(state.xp),
                  upgradeAvailable: upgradeAvailable,
                  onOpenShop: () => AppRouter.openShop(context),
                  onOpenCollection: () => AppRouter.openCollection(context),
                  onOpenSettings: () => AppRouter.openSettings(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => AppRouter.openShop(context),
                        child: Storefront(
                          tier: state.shopTier,
                          height: 96,
                          animate: !state.settings.reducedMotion,
                        ),
                      ),
                      // La caja va sobre la fachada: ahí es donde está en la
                      // ficción, y la barra superior ya está llena.
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: TillChip(
                          amount: state.idleAccrued,
                          capacity: engine.tillCapacity(state),
                          onCollect: controller.collectTill,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                OrderPanel(
                  orders: state.orders,
                  board: state.board,
                  coins: state.coins,
                  now: _now,
                  rerollCostOf: (CustomerOrder o) =>
                      economy.rerollCost(o.reward),
                  partialUnlocked:
                      state.playerLevel(economy) >=
                      config.partialDeliveryPlayerLevel,
                  onDeliver: (CustomerOrder o) =>
                      controller.completeOrder(o.id, withBonus: o.isSpecial),
                  onDeliverPartial: (CustomerOrder o) =>
                      controller.completeOrderPartially(o.id),
                  onReroll: (CustomerOrder o) => controller.rerollOrder(o.id),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: BoardView(
                      board: state.board,
                      hint: _hint,
                      sellMode: _sellMode,
                      sellValueOf: (BoardItem item) =>
                          economy.sellValue(item.level),
                      onDrop: (int from, int to) => controller.drop(from, to),
                      onPickUp: () {
                        if (state.settings.hapticsEnabled) {
                          HapticFeedback.selectionClick();
                        }
                        if (state.settings.soundEnabled) {
                          ref.read(soundPlayerProvider).play(GameSound.pick);
                        }
                      },
                      onTapLocked: () => _openExpandSheet(state, config),
                      onTapItem: (int index) {
                        if (_sellMode) {
                          controller.sell(index);
                          return;
                        }
                        final BoardItem? item = state.board.at(index);
                        if (item == null) return;
                        unawaited(
                          ItemActionsSheet.show(
                            context,
                            item: item,
                            economy: economy,
                            coins: state.coins,
                            hasFreeCell: state.board.freeCells > 0,
                            onSplit: () => controller.splitItem(index),
                            onSell: () => controller.sell(index),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (state.tutorialStep.isActive)
                  OnboardingBanner(
                    step: state.tutorialStep,
                    onSkip: controller.skipTutorial,
                    onNext: controller.advanceTutorial,
                  ),
                GeneratorBar(
                  cost: config.generateCost,
                  canAfford: state.coins >= config.generateCost,
                  boardFull: state.board.isFull,
                  sellMode: _sellMode,
                  onGenerate: controller.generate,
                  onToggleSell: () => setState(() => _sellMode = !_sellMode),
                  onOpenMarket: () => unawaited(
                    MarketSheet.show(
                      context,
                      state: state,
                      economy: economy,
                      onBuy: controller.buyProduct,
                    ),
                  ),
                ),
              ],
            ),
            // Los "+N" van sobre el contador de monedas y no interceptan
            // toques, para no estorbar al jugador.
            Positioned(
              left: 22,
              top: 54,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final ({int id, int amount}) burst in _bursts)
                      CoinBurst(
                        key: ValueKey<int>(burst.id),
                        amount: burst.amount,
                        reducedMotion: state.settings.reducedMotion,
                        onDone: () {
                          if (!mounted) return;
                          setState(
                            () => _bursts.removeWhere(
                              (({int id, int amount}) b) => b.id == burst.id,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
