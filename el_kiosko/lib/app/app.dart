import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class AlmacenApp extends StatelessWidget {
  const AlmacenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Kiosko',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
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
