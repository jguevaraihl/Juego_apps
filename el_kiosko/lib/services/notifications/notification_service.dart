import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme.dart';

/// Aviso local cuando la caja del almacén se llena.
///
/// Es **local**: se programa en el propio teléfono, no hay servidor ni red ni
/// token de push (ver DATA_SAFETY.md). El único mensaje es funcional —"tu caja
/// está llena"— y nunca usa culpa, que el brief prohíbe explícitamente.
abstract class NotificationService {
  /// Prepara el plugin. Se puede llamar varias veces sin problema.
  Future<void> init();

  /// Pide permiso al usuario. Devuelve si quedó concedido.
  Future<bool> requestPermission();

  /// ¿El sistema tiene los avisos habilitados para esta app?
  Future<bool> isEnabled();

  /// Programa el aviso para [when]. Reemplaza cualquiera anterior.
  Future<void> scheduleTillFull({
    required DateTime when,
    required String title,
    required String body,
  });

  /// Cancela el aviso pendiente. Se llama al volver a la app: si el jugador ya
  /// está adentro, avisarle no tiene sentido.
  Future<void> cancelAll();
}

/// No hace nada. Es lo que se usa en tests.
class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> isEnabled() async => false;

  @override
  Future<void> scheduleTillFull({
    required DateTime when,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}

/// Implementación real sobre `flutter_local_notifications`.
///
/// Nada de esto puede tumbar el juego: si el sistema niega el permiso o el
/// plugin falla, se juega sin avisos.
class LocalNotificationService implements NotificationService {
  static const int _tillFullId = 1;
  static const String _channelId = 'till_full';

  /// Ícono de la barra de estado. Android lo dibuja como silueta —usa sólo el
  /// alfa y lo pinta de blanco—, así que tiene que ser un glifo monocromo y no
  /// el ícono del lanzador, que se vería como un cuadrado blanco.
  static const String _smallIcon = '@drawable/ic_notification';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  @override
  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_smallIcon),
        ),
      );
      _ready = true;
    } on Object catch (error) {
      debugPrint('Avisos no disponibles: $error');
      _ready = false;
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> requestPermission() async {
    await init();
    if (!_ready) return false;
    try {
      return await _android?.requestNotificationsPermission() ?? false;
    } on Object catch (error) {
      debugPrint('No se pudo pedir permiso de avisos: $error');
      return false;
    }
  }

  @override
  Future<bool> isEnabled() async {
    await init();
    if (!_ready) return false;
    try {
      return await _android?.areNotificationsEnabled() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> scheduleTillFull({
    required DateTime when,
    required String title,
    required String body,
  }) async {
    await init();
    if (!_ready) return;
    if (!when.isAfter(DateTime.now())) return;

    try {
      await _plugin.cancel(id: _tillFullId);
      await _plugin.zonedSchedule(
        id: _tillFullId,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Caja llena',
            channelDescription: 'Avisa cuando el almacén dejó de vender.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: _smallIcon,
            // El acento de la marca detrás del glifo blanco.
            color: AppTheme.brandWood,
          ),
        ),
        // Inexacto a propósito: los avisos exactos exigen un permiso que Play
        // restringe a alarmas y recordatorios, y para esto no hace falta que
        // llegue al segundo.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on Object catch (error) {
      debugPrint('No se pudo programar el aviso: $error');
    }
  }

  @override
  Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } on Object {
      // Si no se puede cancelar, el aviso llega de más: molesto, no grave.
    }
  }
}
