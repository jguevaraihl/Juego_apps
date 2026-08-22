import 'package:flutter/foundation.dart';

/// Nombres de evento del plan de medición (PLAN_FINAL §13).
///
/// Se centralizan aquí para que Fase 2 conecte Firebase Analytics sin tocar
/// el juego, y para que no se dupliquen strings sueltos por el código.
class AnalyticsEvents {
  const AnalyticsEvents._();

  static const String firstOpenGame = 'first_open_game';
  static const String tutorialStart = 'tutorial_start';
  static const String tutorialComplete = 'tutorial_complete';
  static const String itemGenerated = 'item_generated';
  static const String mergeCompleted = 'merge_completed';
  static const String orderCompleted = 'order_completed';
  static const String upgradePurchased = 'upgrade_purchased';
  static const String sessionCheckpoint = 'session_checkpoint';

  // Reservados para Fase 3 (ads y billing). Todavía no se emiten.
  static const String rewardedOfferShown = 'rewarded_offer_shown';
  static const String rewardedStarted = 'rewarded_started';
  static const String rewardedCompleted = 'rewarded_completed';
  static const String interstitialShown = 'interstitial_shown';
  static const String adImpression = 'ad_impression';
  static const String premiumViewed = 'premium_viewed';
  static const String purchaseStarted = 'purchase_started';
  static const String purchaseCompleted = 'purchase_completed';
  static const String purchaseRestored = 'purchase_restored';
}

/// Destino de los eventos. En Fase 1 no sale nada del dispositivo.
///
/// Regla: los parámetros nunca llevan PII (PLAN_FINAL §13). Siempre se envía
/// `economy_version` para poder comparar cohortes cuando cambie el balance.
abstract class AnalyticsSink {
  void log(
    String name, [
    Map<String, Object?> params = const <String, Object?>{},
  ]);
}

/// No-op. Es el sink por defecto: la app funciona sin recolectar nada.
class NoopAnalytics implements AnalyticsSink {
  const NoopAnalytics();

  @override
  void log(
    String name, [
    Map<String, Object?> params = const <String, Object?>{},
  ]) {}
}

/// Imprime en consola en debug. Sirve para verificar el taxonomy antes de
/// conectar Firebase, sin enviar nada a ningún servidor.
class DebugAnalytics implements AnalyticsSink {
  const DebugAnalytics();

  @override
  void log(
    String name, [
    Map<String, Object?> params = const <String, Object?>{},
  ]) {
    if (!kDebugMode) return;
    debugPrint('[analytics] $name $params');
  }
}
