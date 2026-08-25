import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../game/game_controller.dart';
import '../../game/models/game_state.dart';
import '../../game/models/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notifications/notification_service.dart';

/// Ajustes. Todo se guarda local; nada de esto sale del dispositivo.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Idiomas ofrecidos, con su nombre en su propio idioma (endónimo): un
  /// usuario que abrió el juego en el idioma equivocado igual reconoce el suyo.
  static const Map<String, String> languageNames = <String, String>{
    'es': 'Español',
    'en': 'English',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState? state = ref.watch(gameControllerProvider).state;
    if (state == null) return const Scaffold();

    final AppLocalizations l = AppLocalizations.of(context);
    final GameController controller = ref.read(gameControllerProvider.notifier);
    final GameSettings settings = state.settings;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          SwitchListTile(
            value: settings.soundEnabled,
            onChanged: (bool v) =>
                controller.updateSettings(settings.copyWith(soundEnabled: v)),
            title: Text(l.settingsSound),
            subtitle: Text(l.settingsSoundSub),
          ),
          SwitchListTile(
            value: settings.hapticsEnabled,
            onChanged: (bool v) =>
                controller.updateSettings(settings.copyWith(hapticsEnabled: v)),
            title: Text(l.settingsHaptics),
            subtitle: Text(l.settingsHapticsSub),
          ),
          SwitchListTile(
            value: settings.reducedMotion,
            onChanged: (bool v) =>
                controller.updateSettings(settings.copyWith(reducedMotion: v)),
            title: Text(l.settingsReducedMotion),
            subtitle: Text(l.settingsReducedMotionSub),
          ),
          SwitchListTile(
            value: settings.showIdleHints,
            onChanged: (bool v) =>
                controller.updateSettings(settings.copyWith(showIdleHints: v)),
            title: Text(l.settingsHints),
            subtitle: Text(l.settingsHintsSub),
          ),
          SwitchListTile(
            value: settings.notificationsEnabled,
            onChanged: (bool v) => _toggleNotifications(context, ref, v),
            title: Text(l.notificationsTitle),
            subtitle: Text(l.notificationsSub),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.settingsLanguage),
            subtitle: Text(
              settings.languageCode == null
                  ? l.settingsLanguageSystem
                  : languageNames[settings.languageCode] ??
                        settings.languageCode!,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickLanguage(context, controller, settings),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: Text(l.settingsPremium),
            subtitle: Text(l.settingsPremiumSub),
            onTap: () => AppRouter.openPremium(context),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.settingsAbout),
            subtitle: Text(
              l.settingsStats(state.totalOrdersCompleted, state.totalMerges),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Text(
              l.settingsPrivacyNote,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// Encender los avisos pide el permiso del sistema primero.
  ///
  /// Si el usuario lo niega, el interruptor **no** queda encendido: dejarlo
  /// prendido cuando Android no va a mostrar nada sería mentirle.
  Future<void> _toggleNotifications(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final GameController controller = ref.read(gameControllerProvider.notifier);
    final GameSettings settings = ref
        .read(gameControllerProvider)
        .state!
        .settings;

    if (!enabled) {
      controller.updateSettings(settings.copyWith(notificationsEnabled: false));
      await ref.read(notificationServiceProvider).cancelAll();
      return;
    }

    final NotificationService service = ref.read(notificationServiceProvider);
    final bool granted = await service.requestPermission();
    if (!context.mounted) return;

    controller.updateSettings(settings.copyWith(notificationsEnabled: granted));
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).notificationsBlocked),
        ),
      );
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    GameController controller,
    GameSettings settings,
  ) async {
    final AppLocalizations l = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: RadioGroup<String?>(
          groupValue: settings.languageCode,
          onChanged: (String? value) {
            controller.updateSettings(
              value == null
                  ? settings.copyWith(clearLanguage: true)
                  : settings.copyWith(languageCode: value),
            );
            Navigator.of(sheetContext).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String?>(
                value: null,
                title: Text(l.settingsLanguageSystem),
              ),
              for (final MapEntry<String, String> entry
                  in languageNames.entries)
                RadioListTile<String?>(
                  value: entry.key,
                  title: Text(entry.value),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
