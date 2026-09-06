import '../../game/models/board_item.dart';
import '../../game/models/order.dart';
import '../../game/models/product.dart';
import '../../game/progression/achievements.dart';
import '../../game/progression/missions.dart';
import '../../game/progression/shop_tiers.dart';
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
    'shop_7' => achShop7,
    'shop_12' => achShop12,
    'shop_17' => achShop17,
    'shop_22' => achShop22,
    'shop_27' => achShop27,
    'album_1' => achAlbum1,
    'album_2' => achAlbum2,
    'album_3' => achAlbum3,
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

  /// Nombre de la mascota elegida. 0 es "ninguna".
  String petName(int petId) => switch (petId) {
    1 => petName1,
    2 => petName2,
    3 => petName3,
    4 => petName4,
    _ => petNone,
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
    ProductCatalog.mascotas => chainPets,
    ProductCatalog.frutas => chainFruit,
    ProductCatalog.lacteos => chainDairy,
    ProductCatalog.congelados => chainFrozen,
    ProductCatalog.libreria => chainStationery,
    _ => chainId,
  };

  /// Nombre de una misión diaria.
  String missionName(String id) => switch (id) {
    'daily_merges' => mDailyMerges,
    'daily_merges_big' => mDailyMergesBig,
    'daily_orders' => mDailyOrders,
    'daily_orders_big' => mDailyOrdersBig,
    'daily_generate' => mDailyGenerate,
    'daily_high_level' => mDailyHighLevel,
    'daily_coins' => mDailyCoins,
    'daily_till' => mDailyTill,
    _ => id,
  };

  /// Qué pide una misión, con su meta ya calculada para este jugador.
  String missionDescription(MissionMetric metric, int target) =>
      switch (metric) {
        MissionMetric.merges => mDescMerges(target),
        MissionMetric.orders => mDescOrders(target),
        MissionMetric.generated => mDescGenerate(target),
        MissionMetric.highLevelMerges => mDescHighLevel(target),
        MissionMetric.coinsEarned => mDescCoins(target),
        MissionMetric.tillCollections => mDescTill(target),
      };

  /// Nombre del producto de una cadena en un nivel dado.
  String productName(String chainId, int level) => switch ((chainId, level)) {
    (ProductCatalog.panaderia, 1) => bakery1,
    (ProductCatalog.panaderia, 2) => bakery2,
    (ProductCatalog.panaderia, 3) => bakery3,
    (ProductCatalog.panaderia, 4) => bakery4,
    (ProductCatalog.panaderia, 5) => bakery5,
    (ProductCatalog.panaderia, 6) => bakery6,
    (ProductCatalog.bebidas, 1) => drinks1,
    (ProductCatalog.bebidas, 2) => drinks2,
    (ProductCatalog.bebidas, 3) => drinks3,
    (ProductCatalog.bebidas, 4) => drinks4,
    (ProductCatalog.bebidas, 5) => drinks5,
    (ProductCatalog.bebidas, 6) => drinks6,
    (ProductCatalog.snacks, 1) => snacks1,
    (ProductCatalog.snacks, 2) => snacks2,
    (ProductCatalog.snacks, 3) => snacks3,
    (ProductCatalog.snacks, 4) => snacks4,
    (ProductCatalog.snacks, 5) => snacks5,
    (ProductCatalog.snacks, 6) => snacks6,
    (ProductCatalog.huevos, 1) => eggs1,
    (ProductCatalog.huevos, 2) => eggs2,
    (ProductCatalog.huevos, 3) => eggs3,
    (ProductCatalog.aseo, 1) => cleaning1,
    (ProductCatalog.aseo, 2) => cleaning2,
    (ProductCatalog.aseo, 3) => cleaning3,
    (ProductCatalog.aseo, 4) => cleaning4,
    (ProductCatalog.aseo, 5) => cleaning5,
    (ProductCatalog.mascotas, 1) => pets1,
    (ProductCatalog.mascotas, 2) => pets2,
    (ProductCatalog.mascotas, 3) => pets3,
    (ProductCatalog.mascotas, 4) => pets4,
    (ProductCatalog.mascotas, 5) => pets5,
    (ProductCatalog.frutas, 1) => fruit1,
    (ProductCatalog.frutas, 2) => fruit2,
    (ProductCatalog.frutas, 3) => fruit3,
    (ProductCatalog.frutas, 4) => fruit4,
    (ProductCatalog.lacteos, 1) => dairy1,
    (ProductCatalog.lacteos, 2) => dairy2,
    (ProductCatalog.lacteos, 3) => dairy3,
    (ProductCatalog.lacteos, 4) => dairy4,
    (ProductCatalog.lacteos, 5) => dairy5,
    (ProductCatalog.lacteos, 6) => dairy6,
    (ProductCatalog.lacteos, 7) => dairy7,
    (ProductCatalog.congelados, 1) => frozen1,
    (ProductCatalog.congelados, 2) => frozen2,
    (ProductCatalog.congelados, 3) => frozen3,
    (ProductCatalog.congelados, 4) => frozen4,
    (ProductCatalog.congelados, 5) => frozen5,
    (ProductCatalog.congelados, 6) => frozen6,
    (ProductCatalog.congelados, 7) => frozen7,
    (ProductCatalog.congelados, 8) => frozen8,
    (ProductCatalog.libreria, 1) => stationery1,
    (ProductCatalog.libreria, 2) => stationery2,
    (ProductCatalog.libreria, 3) => stationery3,
    (ProductCatalog.libreria, 4) => stationery4,
    (ProductCatalog.libreria, 5) => stationery5,
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
  /// Nombre del local con su estrella: "Kiosko ★2".
  ///
  /// Las treinta subidas de nivel comparten siete fachadas, así que cuatro de
  /// cada cinco no cambian el dibujo. La estrella es lo que hace que igual se
  /// note: sin ella, la mayoría de las subidas serían invisibles y subir de
  /// nivel dejaría de sentirse como algo.
  String shopName(ShopTier tier) => tier.starWithinTier <= 1
      ? shopTierName(tier.visualTier)
      : '${shopTierName(tier.visualTier)} ★${tier.starWithinTier}';

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
