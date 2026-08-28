import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';
import '../game/models/settings.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';
import 'router.dart';
import 'theme.dart';

class AlmacenApp extends ConsumerWidget {
  const AlmacenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Las preferencias de presentación se miran una por una con `select`
    // para que cambiar de tema no reconstruya la app en cada fusión.
    final String? languageCode = ref.watch(
      gameControllerProvider.select(
        (GameSession s) => s.state?.settings.languageCode,
      ),
    );
    final AppThemeMode themeMode = ref.watch(
      gameControllerProvider.select(
        (GameSession s) => s.state?.settings.themeMode ?? AppThemeMode.system,
      ),
    );
    final double textScale = ref.watch(
      gameControllerProvider.select(
        (GameSession s) => s.state?.settings.textScale ?? 1.0,
      ),
    );

    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
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
        // el tablero siga cabiendo en pantallas chicas (PLAN_FINAL §6), y
        // encima se aplica el ajuste propio de la app.
        //
        // El techo se calcula sobre el producto de los dos y no sobre cada uno
        // por separado: quien ya tiene el teléfono en letra grande y además
        // sube el de la app llegaría a un tamaño donde el tablero expulsa las
        // etiquetas de los pedidos.
        final MediaQueryData media = MediaQuery.of(context);
        final double systemScale = media.textScaler.scale(1);
        // Los íconos de la barra de estado se pintan al revés del fondo. Va
        // acá y no una sola vez al arrancar porque el tema puede cambiar en
        // caliente, y con el valor fijo la barra quedaba ilegible en oscuro.
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(
                (systemScale * textScale).clamp(GameSettings.minTextScale, 1.4),
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
