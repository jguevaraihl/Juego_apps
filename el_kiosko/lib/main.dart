import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // El juego es vertical y se usa con una mano (PLAN_FINAL §6).
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Con targetSdk 36, Android 15 y superiores dibujan la app **detrás** de las
  // barras del sistema, se pida o no. Se declara explícitamente para que el
  // comportamiento sea el mismo en todas las versiones, y se fuerzan íconos
  // oscuros: sobre el crema del juego, los íconos blancos por defecto quedan
  // invisibles.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: AlmacenApp()));
}
