import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../game/game_controller.dart';
import '../../game/models/game_state.dart';
import '../../game/models/settings.dart';

/// Ajustes. Todo se guarda local; nada de esto sale del dispositivo.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState? state = ref.watch(gameControllerProvider).state;
    if (state == null) return const Scaffold();

    final GameController controller = ref.read(gameControllerProvider.notifier);
    final GameSettings settings = state.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          SwitchListTile(
            value: settings.soundEnabled,
            onChanged: (bool v) =>
                controller.updateSettings(settings.copyWith(soundEnabled: v)),
            title: const Text('Sonido'),
            subtitle: const Text('Efectos al completar acciones'),
          ),
          SwitchListTile(
            value: settings.hapticsEnabled,
            onChanged: (bool v) =>
                controller.updateSettings(settings.copyWith(hapticsEnabled: v)),
            title: const Text('Vibración'),
            subtitle: const Text('Respuesta táctil al juntar y cobrar'),
          ),
          SwitchListTile(
            value: settings.reducedMotion,
            onChanged: (bool v) =>
                controller.updateSettings(settings.copyWith(reducedMotion: v)),
            title: const Text('Reducir animaciones'),
            subtitle: const Text('Recomendado en teléfonos más lentos'),
          ),
          SwitchListTile(
            value: settings.showIdleHints,
            onChanged: (bool v) =>
                controller.updateSettings(settings.copyWith(showIdleHints: v)),
            title: const Text('Sugerencias'),
            subtitle: const Text('Marcar una jugada posible si te detienes'),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: const Text('Club del Barrio'),
            subtitle: const Text('Opciones sin anuncios (próximamente)'),
            onTap: () => AppRouter.openPremium(context),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre el juego'),
            subtitle: Text(
              'Pedidos completados: ${state.totalOrdersCompleted} · '
              'Productos juntados: ${state.totalMerges}',
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Text(
              'Esta versión funciona completamente sin conexión y no recolecta '
              'datos personales.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
