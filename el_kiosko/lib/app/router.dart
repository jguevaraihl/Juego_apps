import 'package:flutter/material.dart';

import '../features/collection/collection_screen.dart';
import '../features/home/home_screen.dart';
import '../features/premium/premium_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/achievements/achievements_screen.dart';

/// Navegación con rutas nombradas del Navigator estándar.
///
/// No se usa go_router: son cinco pantallas sin deep links todavía, y una
/// dependencia menos es una dependencia menos que mantener (ver DECISIONS.md).
class AppRouter {
  const AppRouter._();

  static const String home = '/';
  static const String shop = '/shop';
  static const String collection = '/collection';
  static const String achievements = '/achievements';
  static const String settings = '/settings';
  static const String premium = '/premium';

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    final WidgetBuilder builder = switch (routeSettings.name) {
      shop => (_) => const ShopScreen(),
      collection => (_) => const CollectionScreen(),
      achievements => (_) => const AchievementsScreen(),
      settings => (_) => const SettingsScreen(),
      premium => (_) => const PremiumScreen(),
      _ => (_) => const HomeScreen(),
    };
    return MaterialPageRoute<dynamic>(
      builder: builder,
      settings: routeSettings,
    );
  }

  static Future<void> openShop(BuildContext context) =>
      Navigator.of(context).pushNamed(shop);

  static Future<void> openCollection(BuildContext context) =>
      Navigator.of(context).pushNamed(collection);

  static Future<void> openAchievements(BuildContext context) =>
      Navigator.of(context).pushNamed(achievements);

  static Future<void> openSettings(BuildContext context) =>
      Navigator.of(context).pushNamed(settings);

  static Future<void> openPremium(BuildContext context) =>
      Navigator.of(context).pushNamed(premium);
}
