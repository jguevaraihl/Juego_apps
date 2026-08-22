import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';
import 'router.dart';
import 'theme.dart';

class AlmacenApp extends ConsumerWidget {
  const AlmacenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Idioma elegido a mano en Ajustes; si no hay ninguno, manda el sistema.
    final String? languageCode = ref.watch(
      gameControllerProvider.select(
        (GameSession s) => s.state?.settings.languageCode,
      ),
    );

    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: languageCode == null ? null : Locale(languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (BuildContext context, Widget? child) {
        // Se respeta el tamaño de fuente del sistema, con un techo para que
        // el tablero siga cabiendo en pantallas chicas (PLAN_FINAL §6).
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 1,
              maxScaleFactor: 1.4,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
