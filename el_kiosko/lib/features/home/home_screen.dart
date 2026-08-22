import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../game/board/board_ops.dart';
import '../../game/economy/economy.dart';
import '../../game/economy/economy_config.dart';
import '../../game/game_controller.dart';
import '../../game/game_events.dart';
import '../../game/models/board_item.dart';
import '../../game/models/game_state.dart';
import '../../game/models/order.dart';
import '../../l10n/app_localizations.dart';
import '../common/game_strings.dart';
import '../../services/haptics.dart';
import 'widgets/board_view.dart';
import 'widgets/generator_bar.dart';
import 'widgets/offline_earnings_sheet.dart';
import 'widgets/onboarding_overlay.dart';
import 'widgets/order_panel.dart';
import 'widgets/storefront.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
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
      case AppLifecycleState.resumed:
        controller.resumeFromBackground();
      case AppLifecycleState.inactive:
        break;
    }
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
      sound: state.settings.soundEnabled,
    );
    final AppLocalizations l = AppLocalizations.of(context);

    for (final GameEvent event in events) {
      switch (event) {
        case ItemGenerated():
          feedback.light();
        case MergeCompleted():
          feedback.selection();
        case OrderCompleted(:final int reward):
          feedback.success();
          _toast(l.toastOrderDelivered(reward));
        case ShopUpgraded(:final int newLevel):
          feedback.heavy();
          _toast(
            l.toastShopUpgraded(l.shopTierName(newLevel)),
            level: newLevel,
          );
        case PlayerLeveledUp(:final int newLevel):
          _toast(l.toastLevelUp(newLevel));
        case ChainUnlocked(:final String chainId):
          _toast(l.toastChainUnlocked(l.chainName(chainId)));
        case ItemSold(:final int value):
          feedback.light();
          _toast(l.toastSold(value));
        case OrderRerolled():
          feedback.light();
        case EmergencyRelief(:final int amount):
          _toast(l.toastRelief(amount));
        case OfflineEarningsClaimed(:final int amount):
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(OfflineEarningsSheet.show(context, amount));
          });
        case ActionRejected(:final RejectReason reason):
          _toast(switch (reason) {
            RejectReason.notEnoughCoins => l.toastNotEnoughCoins,
            RejectReason.boardFull => l.toastBoardFull,
            RejectReason.orderNotReady => l.toastOrderNotReady,
            RejectReason.maxShopLevel => l.toastMaxShopLevel,
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
    final EconomyConfig config = ref.read(economyConfigProvider);
    final GameController controller = ref.read(gameControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TopBar(
              coins: state.coins,
              playerLevel: state.playerLevel(economy),
              levelProgress: economy.levelProgress(state.xp),
              onOpenShop: () => AppRouter.openShop(context),
              onOpenCollection: () => AppRouter.openCollection(context),
              onOpenSettings: () => AppRouter.openSettings(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: () => AppRouter.openShop(context),
                child: Storefront(
                  tier: state.shopTier,
                  height: 96,
                  animate: !state.settings.reducedMotion,
                ),
              ),
            ),
            const SizedBox(height: 8),
            OrderPanel(
              orders: state.orders,
              board: state.board,
              coins: state.coins,
              rerollCostOf: (CustomerOrder o) => economy.rerollCost(o.reward),
              onDeliver: (CustomerOrder o) =>
                  controller.completeOrder(o.id, withBonus: o.isSpecial),
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
                  onTapItem: (int index) {
                    if (_sellMode) controller.sell(index);
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (state.tutorialStep.isActive)
              OnboardingBanner(
                step: state.tutorialStep,
                onSkip: controller.skipTutorial,
              ),
            GeneratorBar(
              cost: config.generateCost,
              canAfford: state.coins >= config.generateCost,
              boardFull: state.board.isFull,
              sellMode: _sellMode,
              onGenerate: controller.generate,
              onToggleSell: () => setState(() => _sellMode = !_sellMode),
            ),
          ],
        ),
      ),
    );
  }
}
