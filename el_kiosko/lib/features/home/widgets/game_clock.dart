import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Un reloj que late una vez por segundo y al que se suscriben **sólo** los
/// widgets que muestran tiempo.
///
/// Antes la pantalla principal guardaba la hora en su propio estado y llamaba
/// `setState` cada segundo, lo que rehacía el árbol entero —barra superior,
/// fachada, tres tarjetas de pedido y cuarenta y ocho casillas— para mover un
/// contador. En una sesión larga eso es lo que iba dejando el juego lento.
///
/// Con esto el latido es un `ValueNotifier`: repinta la caja y los
/// cronómetros de los pedidos, y nada más.
class GameClock extends StatefulWidget {
  const GameClock({required this.child, super.key});

  final Widget child;

  /// El reloj más cercano. Devuelve null fuera de un [GameClock], para que un
  /// widget suelto en un test no reviente.
  static ValueListenable<DateTime>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GameClockScope>()?.notifier;

  @override
  State<GameClock> createState() => _GameClockState();
}

class _GameClockState extends State<GameClock> {
  final ValueNotifier<DateTime> _notifier = ValueNotifier<DateTime>(
    DateTime.now(),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _notifier.value = DateTime.now(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _GameClockScope(notifier: _notifier, child: widget.child);
}

class _GameClockScope extends InheritedWidget {
  const _GameClockScope({required this.notifier, required super.child});

  final ValueNotifier<DateTime> notifier;

  @override
  bool updateShouldNotify(_GameClockScope oldWidget) =>
      oldWidget.notifier != notifier;
}

/// Reconstruye su contenido una vez por segundo, y sólo su contenido.
///
/// Si no hay [GameClock] arriba, pinta una vez con la hora actual y se queda
/// quieto: preferible a reventar en un test de widget suelto.
class ClockBuilder extends StatelessWidget {
  const ClockBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  Widget build(BuildContext context) {
    final ValueListenable<DateTime>? clock = GameClock.maybeOf(context);
    if (clock == null) return builder(context, DateTime.now());
    return ValueListenableBuilder<DateTime>(
      valueListenable: clock,
      builder: (BuildContext context, DateTime now, _) => builder(context, now),
    );
  }
}
