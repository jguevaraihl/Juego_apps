import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/router.dart';
import '../../game/game_controller.dart';
import '../../game/models/game_state.dart';
import '../../game/models/settings.dart';
import '../../l10n/app_localizations.dart';
import '../common/game_strings.dart';
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
          _SectionHeader(l.settingsSectionLook),
          ListTile(
            leading: const Icon(Icons.storefront),
            title: Text(l.settingsStoreName),
            subtitle: Text(
              settings.storeName ?? l.settingsStoreNameDefault,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editStoreName(context, controller, settings),
          ),
          _AwningPicker(settings: settings, controller: controller),
          ListTile(
            leading: const Icon(Icons.pets),
            title: Text(l.settingsPet),
            subtitle: Text(l.settingsPetSub),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l.petName(settings.petId),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _pickPet(context, controller, settings),
          ),
          const Divider(height: 24),

          _SectionHeader(l.settingsSectionPlay),
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

          _SectionHeader(l.settingsSectionAccess),
          ListTile(
            leading: const Icon(Icons.contrast),
            title: Text(l.settingsTheme),
            subtitle: Text(switch (settings.themeMode) {
              AppThemeMode.system => l.settingsThemeSystem,
              AppThemeMode.light => l.settingsThemeLight,
              AppThemeMode.dark => l.settingsThemeDark,
            }),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickTheme(context, controller, settings),
          ),
          _TextSizeTile(settings: settings, controller: controller),
          SwitchListTile(
            value: settings.reducedMotion,
            onChanged: (bool v) =>
                controller.updateSettings(settings.copyWith(reducedMotion: v)),
            title: Text(l.settingsReducedMotion),
            subtitle: Text(l.settingsReducedMotionSub),
          ),
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

  /// Pide el nombre del local en un diálogo, no en un campo suelto en la
  /// lista: escribir dentro de una lista que hace scroll con el teclado
  /// abierto es incómodo, y así el cambio se confirma explícitamente.
  Future<void> _editStoreName(
    BuildContext context,
    GameController controller,
    GameSettings settings,
  ) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextEditingController field = TextEditingController(
      text: settings.storeName ?? '',
    );

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l.settingsStoreName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: field,
              autofocus: true,
              maxLength: GameSettings.maxStoreNameLength,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l.settingsStoreNameHint,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (String v) => Navigator.of(context).pop(v),
            ),
            Text(
              l.settingsStoreNameHelp(GameSettings.maxStoreNameLength),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(field.text),
            child: Text(l.save),
          ),
        ],
      ),
    );
    field.dispose();
    if (result == null) return;

    final String? clean = GameSettings.sanitizeStoreName(result);
    controller.updateSettings(
      clean == null
          ? settings.copyWith(clearStoreName: true)
          : settings.copyWith(storeName: clean),
    );
  }

  Future<void> _pickTheme(
    BuildContext context,
    GameController controller,
    GameSettings settings,
  ) async {
    final AppLocalizations l = AppLocalizations.of(context);

    // Misma hoja que el selector de idioma, para que dos ajustes de la misma
    // familia se elijan de la misma forma.
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: RadioGroup<AppThemeMode>(
          groupValue: settings.themeMode,
          onChanged: (AppThemeMode? value) {
            if (value != null) {
              controller.updateSettings(settings.copyWith(themeMode: value));
            }
            Navigator.of(sheetContext).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final (AppThemeMode mode, String label)
                  in <(AppThemeMode, String)>[
                    (AppThemeMode.system, l.settingsThemeSystem),
                    (AppThemeMode.light, l.settingsThemeLight),
                    (AppThemeMode.dark, l.settingsThemeDark),
                  ])
                RadioListTile<AppThemeMode>(value: mode, title: Text(label)),
            ],
          ),
        ),
      ),
    );
  }

  /// Elegir mascota. La hoja dice qué gana el jugador además del adorno,
  /// porque si no parecería una decisión puramente estética.
  Future<void> _pickPet(
    BuildContext context,
    GameController controller,
    GameSettings settings,
  ) async {
    final AppLocalizations l = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: RadioGroup<int>(
          groupValue: settings.petId,
          onChanged: (int? value) {
            if (value != null) {
              controller.updateSettings(settings.copyWith(petId: value));
            }
            Navigator.of(sheetContext).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l.settingsPetSub,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              for (int i = 0; i <= GameSettings.petCount; i++)
                RadioListTile<int>(value: i, title: Text(l.petName(i))),
            ],
          ),
        ),
      ),
    );
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

/// Encabezado de sección. Agrupar es lo que hace que una lista de ajustes que
/// creció siga siendo navegable: sin esto son once interruptores en fila.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: context.palette.wood,
      ),
    ),
  );
}

/// Elige la tela del toldo.
///
/// La opción activa se marca con un visto además del color: si dependiera sólo
/// del color, quien no distingue matices no sabría cuál eligió. Es la misma
/// regla que rige el resto del juego —ninguna información esencial en un color
/// y nada más— aplicada al propio selector de colores.
class _AwningPicker extends StatelessWidget {
  const _AwningPicker({required this.settings, required this.controller});

  final GameSettings settings;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l.settingsAwning,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            l.settingsAwningSub,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (int i = 0; i < AppTheme.awningPalette.length; i++)
                Semantics(
                  button: true,
                  selected: settings.awningColor == i,
                  label: l.awningColorName(i + 1),
                  child: InkWell(
                    onTap: () => controller.updateSettings(
                      settings.copyWith(awningColor: i),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: AppTheme.minTouchTarget,
                      height: AppTheme.minTouchTarget,
                      decoration: BoxDecoration(
                        color: AppTheme.awningPalette[i],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: settings.awningColor == i
                              ? context.palette.ink
                              : context.palette.wood.withValues(alpha: 0.25),
                          width: settings.awningColor == i ? 3 : 1,
                        ),
                      ),
                      child: settings.awningColor == i
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tamaño de texto propio de la app.
///
/// Existe además del ajuste de Android porque mucha gente no sabe que ese
/// ajuste existe, y porque acá se puede acotar para que el tablero de 6
/// columnas siga cabiendo con las etiquetas de los pedidos adentro.
class _TextSizeTile extends StatelessWidget {
  const _TextSizeTile({required this.settings, required this.controller});

  final GameSettings settings;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l.settingsTextSize,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            l.settingsTextSizeSub,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: <Widget>[
              const Text('A', style: TextStyle(fontSize: 13)),
              Expanded(
                child: Slider(
                  value: settings.textScale,
                  min: GameSettings.minTextScale,
                  max: GameSettings.maxTextScale,
                  // Pasos de 5%: suficientes para notar la diferencia sin que
                  // el control exija puntería.
                  divisions: 8,
                  label: '${(settings.textScale * 100).round()}%',
                  onChanged: (double v) => controller.updateSettings(
                    settings.copyWith(textScale: v),
                  ),
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }
}
