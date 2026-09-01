import '../../game/models/board_item.dart';
import '../../game/models/order.dart';
import '../../game/models/product.dart';
import '../../game/progression/achievements.dart';
import '../../l10n/app_localizations.dart';

/// Puente entre los identificadores del catálogo (Dart puro, sin textos) y los
/// textos traducidos de lib/l10n.
///
/// Vive en la capa de UI a propósito: el motor de juego nunca debe conocer un
/// idioma, para que el mismo save se lea igual en cualquier locale.
extension GameStrings on AppLocalizations {
  /// Nombre de un logro. El `switch` sobre ids fijos es a propósito: si
  /// alguien agrega un logro y olvida el texto, el analizador no avisa, pero
  /// hay un test que recorre el catálogo entero en los dos idiomas y falla.
  String achievementName(String id) => switch (id) {
    'merges_1' => achMerges1,
    'merges_2' => achMerges2,
    'merges_3' => achMerges3,
    'streak_1' => achStreak1,
    'streak_2' => achStreak2,
    'orders_1' => achOrders1,
    'orders_2' => achOrders2,
    'orders_3' => achOrders3,
    'wholesale_1' => achWholesale1,
    'wholesale_2' => achWholesale2,
    'shop_3' => achShop3,
    'shop_5' => achShop5,
    'shop_7' => achShop7,
    'album_1' => achAlbum1,
    'album_2' => achAlbum2,
    'till_1' => achTill1,
    'till_2' => achTill2,
    _ => id,
  };

  /// Qué hay que hacer, con la meta ya puesta en la frase.
  String achievementGoal(AchievementMetric metric, int target) =>
      switch (metric) {
        AchievementMetric.merges => achMergesDesc(target),
        AchievementMetric.mergeStreak => achStreakDesc(target),
        AchievementMetric.ordersDelivered => achOrdersDesc(target),
        AchievementMetric.bigOrdersDelivered => achWholesaleDesc(target),
        AchievementMetric.shopLevel => achShopDesc(target),
        AchievementMetric.discovered => achAlbumDesc(target),
        AchievementMetric.tillCollected => achTillDesc(target),
      };

  /// Nombre del color de toldo, 1-basado como en los .arb.
  ///
  /// Existe para que el selector no sea sólo un color: quien no distingue
  /// matices necesita poder oír o leer cuál es cada uno.
  String awningColorName(int oneBased) => switch (oneBased) {
    1 => awningColorName1,
    2 => awningColorName2,
    3 => awningColorName3,
    4 => awningColorName4,
    5 => awningColorName5,
    6 => awningColorName6,
    7 => awningColorName7,
    _ => awningColorName8,
  };

  /// Nombre de una cadena de productos.
  String chainName(String chainId) => switch (chainId) {
    ProductCatalog.panaderia => chainBakery,
    ProductCatalog.bebidas => chainDrinks,
    ProductCatalog.snacks => chainSnacks,
    ProductCatalog.huevos => chainEggs,
    ProductCatalog.aseo => chainCleaning,
    _ => chainId,
  };

  /// Nombre del producto de una cadena en un nivel dado.
  String productName(String chainId, int level) => switch ((chainId, level)) {
    (ProductCatalog.panaderia, 1) => bakery1,
    (ProductCatalog.panaderia, 2) => bakery2,
    (ProductCatalog.panaderia, 3) => bakery3,
    (ProductCatalog.panaderia, 4) => bakery4,
    (ProductCatalog.panaderia, 5) => bakery5,
    (ProductCatalog.bebidas, 1) => drinks1,
    (ProductCatalog.bebidas, 2) => drinks2,
    (ProductCatalog.bebidas, 3) => drinks3,
    (ProductCatalog.bebidas, 4) => drinks4,
    (ProductCatalog.bebidas, 5) => drinks5,
    (ProductCatalog.snacks, 1) => snacks1,
    (ProductCatalog.snacks, 2) => snacks2,
    (ProductCatalog.snacks, 3) => snacks3,
    (ProductCatalog.snacks, 4) => snacks4,
    (ProductCatalog.snacks, 5) => snacks5,
    (ProductCatalog.huevos, 1) => eggs1,
    (ProductCatalog.huevos, 2) => eggs2,
    (ProductCatalog.huevos, 3) => eggs3,
    (ProductCatalog.aseo, 1) => cleaning1,
    (ProductCatalog.aseo, 2) => cleaning2,
    (ProductCatalog.aseo, 3) => cleaning3,
    (ProductCatalog.aseo, 4) => cleaning4,
    _ => '$chainId $level',
  };

  String itemName(BoardItem item) => productName(item.chainId, item.level);

  String lineName(OrderLine line) => productName(line.chainId, line.level);

  /// Nombre del cliente. El índice se toma módulo la cantidad disponible para
  /// que un save de otra versión nunca provoque un índice fuera de rango.
  String customerName(int customerId) => switch (customerId % 12) {
    0 => customer0,
    1 => customer1,
    2 => customer2,
    3 => customer3,
    4 => customer4,
    5 => customer5,
    6 => customer6,
    7 => customer7,
    8 => customer8,
    9 => customer9,
    10 => customer10,
    _ => customer11,
  };

  /// Nombre del nivel del local.
  String shopTierName(int level) => switch (level) {
    1 => shopTier1,
    2 => shopTier2,
    3 => shopTier3,
    4 => shopTier4,
    5 => shopTier5,
    6 => shopTier6,
    _ => shopTier7,
  };

  /// Frase que acompaña al nivel del local.
  String shopTierTagline(int level) => switch (level) {
    1 => shopTagline1,
    2 => shopTagline2,
    3 => shopTagline3,
    4 => shopTagline4,
    5 => shopTagline5,
    6 => shopTagline6,
    _ => shopTagline7,
  };
}
