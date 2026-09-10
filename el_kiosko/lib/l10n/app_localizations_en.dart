// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Corner Store';

  @override
  String get chainBakery => 'Bakery';

  @override
  String get chainDrinks => 'Drinks';

  @override
  String get chainSnacks => 'Snacks';

  @override
  String get bakery1 => 'Bread Roll';

  @override
  String get bakery2 => 'Bag of Bread';

  @override
  String get bakery3 => 'Bread Basket';

  @override
  String get bakery4 => 'Assorted Tray';

  @override
  String get bakery5 => 'Bakery Display';

  @override
  String get drinks1 => 'Glass';

  @override
  String get drinks2 => 'Small Bottle';

  @override
  String get drinks3 => 'Large Bottle';

  @override
  String get drinks4 => 'Six-Pack';

  @override
  String get drinks5 => 'Drinks Fridge';

  @override
  String get snacks1 => 'Candy';

  @override
  String get snacks2 => 'Small Bag';

  @override
  String get snacks3 => 'Snack Pack';

  @override
  String get snacks4 => 'Assorted Box';

  @override
  String get snacks5 => 'Snack Shelf';

  @override
  String get customer0 => 'The Bus Driver';

  @override
  String get customer1 => 'The Neighbor';

  @override
  String get customer2 => 'Evening Student';

  @override
  String get customer3 => 'The Kiosk Owner';

  @override
  String get customer4 => 'Market Vendor';

  @override
  String get customer5 => 'Night Shift';

  @override
  String get customer6 => 'Delivery Rider';

  @override
  String get customer7 => 'The Retiree';

  @override
  String get customer8 => 'The Teacher';

  @override
  String get customer9 => 'Office Worker';

  @override
  String get customer10 => 'The Entrepreneur';

  @override
  String get customer11 => 'The Builder';

  @override
  String get shopTier1 => 'Makeshift Counter';

  @override
  String get shopTier2 => 'Kiosk';

  @override
  String get shopTier3 => 'Small Shop';

  @override
  String get shopTier4 => 'Corner Store';

  @override
  String get shopTier5 => 'Minimarket';

  @override
  String get shopTier6 => 'Renovated Store';

  @override
  String get shopTier7 => 'Neighborhood Chain';

  @override
  String get shopTagline1 => 'A plank, two crates and plenty of hope.';

  @override
  String get shopTagline2 => 'You have a roof and a service window now.';

  @override
  String get shopTagline3 => 'One customer at a time, but they come in.';

  @override
  String get shopTagline4 => 'People greet you by name.';

  @override
  String get shopTagline5 => 'Your own fridge and a lit-up sign.';

  @override
  String get shopTagline6 =>
      'New floor, display cases and a queue at the till.';

  @override
  String get shopTagline7 => 'The most loved store in the area.';

  @override
  String playerLevel(int level) {
    return 'Level $level';
  }

  @override
  String coinsLabel(int coins) {
    return '$coins coins';
  }

  @override
  String get tooltipCollection => 'Product album';

  @override
  String get tooltipShop => 'Upgrade your store';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get shopUpgradeReady => 'You can upgrade your store';

  @override
  String get supplierBox => 'Supplier\'s box';

  @override
  String supplierCost(int cost) {
    return 'Costs $cost';
  }

  @override
  String get boardFull => 'Board is full';

  @override
  String get notEnoughCoinsShort => 'Not enough coins';

  @override
  String supplierSemantics(String hint) {
    return 'Supplier\'s box. $hint';
  }

  @override
  String get sell => 'Sell';

  @override
  String get sellDone => 'Done';

  @override
  String get deliver => 'Deliver';

  @override
  String get missing => 'Missing';

  @override
  String rerollTooltip(int cost) {
    return 'Swap this order for $cost';
  }

  @override
  String orderSemantics(String customer, String status, int reward) {
    return 'Order from $customer. $status. Pays $reward.';
  }

  @override
  String get orderReady => 'Ready to deliver';

  @override
  String get orderNotReady => 'Still missing items';

  @override
  String tutorialStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get tutorialMerge =>
      'Drag a product onto a matching one: the two become a better one.';

  @override
  String get tutorialOrder =>
      'Once you have what a customer wants, hand it over and get paid.';

  @override
  String get tutorialUpgrade =>
      'Coins upgrade your shop: it earns more per hour, and every few levels it gets a new look.';

  @override
  String get skip => 'Skip';

  @override
  String get undoSell => 'Undo sale';

  @override
  String get undoSplit => 'Undo split';

  @override
  String get undoBuy => 'Undo purchase';

  @override
  String get undoReroll => 'Undo swap';

  @override
  String get toastUndone => 'Done, back the way it was';

  @override
  String get offlineTitle => 'Your store kept selling';

  @override
  String offlineBody(int amount) {
    return 'While you were away, $amount coins piled up in the till.';
  }

  @override
  String offlineTotal(int amount) {
    return 'With what you hadn\'t collected, the till adds up to $amount.';
  }

  @override
  String get offlineContinue => 'Back to work';

  @override
  String toastOrderDelivered(int reward) {
    return 'Order delivered! +$reward';
  }

  @override
  String toastShopUpgraded(String name) {
    return 'Your store is now a $name';
  }

  @override
  String toastLevelUp(int level) {
    return 'You reached level $level';
  }

  @override
  String toastChainUnlocked(String chain) {
    return 'New product in the store: $chain';
  }

  @override
  String toastSold(int value) {
    return 'Sold for $value';
  }

  @override
  String toastRelief(int amount) {
    return 'The supplier fronts you $amount to keep going.';
  }

  @override
  String get toastNotEnoughCoins => 'Not enough coins.';

  @override
  String get toastBoardFull => 'The board is full. Sell or deliver something.';

  @override
  String get toastOrderNotReady => 'You are still missing items.';

  @override
  String get toastMaxShopLevel => 'Your store is already at the top level.';

  @override
  String get shopTitle => 'Your store';

  @override
  String shopIncomePerHour(int amount) {
    return 'Earns $amount per hour while you are away.';
  }

  @override
  String shopNext(String name) {
    return 'Next: $name';
  }

  @override
  String get shopShelves => 'Shelves';

  @override
  String get shopCustomers => 'Customers';

  @override
  String get shopIncomeLabel => 'Income per hour';

  @override
  String shopUpgradeFor(int cost) {
    return 'Upgrade for $cost';
  }

  @override
  String shopMissingCoins(int amount) {
    return '$amount coins short';
  }

  @override
  String get shopAllLevels => 'All levels';

  @override
  String get shopStartingPoint => 'Starting point';

  @override
  String shopCosts(int cost) {
    return 'Costs $cost';
  }

  @override
  String get shopMaxedOut =>
      'You have reached the highest level for now. More levels are coming in future updates.';

  @override
  String get collectionTitle => 'Store album';

  @override
  String collectionProgress(int found, int total) {
    return 'Discovered $found of $total';
  }

  @override
  String get collectionUnknown => '???';

  @override
  String collectionLevel(int level) {
    return 'Level $level';
  }

  @override
  String collectionFoundSemantics(String name) {
    return '$name, discovered';
  }

  @override
  String collectionMissingSemantics(int level) {
    return 'Level $level product, not discovered yet';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionLook => 'Your store';

  @override
  String get settingsSectionPlay => 'Gameplay';

  @override
  String get settingsSectionAccess => 'Accessibility';

  @override
  String get settingsStoreName => 'Store name';

  @override
  String get settingsStoreNameSub => 'Shown on the storefront sign';

  @override
  String get settingsStoreNameHint => 'e.g. The Corner Shop';

  @override
  String get settingsStoreNameDefault => 'No custom name';

  @override
  String settingsStoreNameHelp(int max) {
    return 'Up to $max characters. Leave it empty to use the level name.';
  }

  @override
  String get settingsAwning => 'Awning colour';

  @override
  String get settingsAwningSub => 'Pick your store\'s fabric';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'Match the phone';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsTextSizeSub => 'Adds to your phone\'s own text size';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get awningColorName1 => 'Terracotta';

  @override
  String get awningColorName2 => 'Green';

  @override
  String get awningColorName3 => 'Blue';

  @override
  String get awningColorName4 => 'Purple';

  @override
  String get awningColorName5 => 'Red';

  @override
  String get awningColorName6 => 'Teal';

  @override
  String get awningColorName7 => 'Mustard';

  @override
  String get awningColorName8 => 'Slate';

  @override
  String get sort => 'Tidy up';

  @override
  String get sortFree => 'free';

  @override
  String get toastSorted => 'Shelves tidied up';

  @override
  String get toastSortedFree => 'Shelves tidied up, no charge';

  @override
  String get toastAlreadySorted => 'Already tidy';

  @override
  String get toastAlreadyOwned => 'You already own it';

  @override
  String toastUndoneCost(int cost) {
    return 'Done, back the way it was (-$cost)';
  }

  @override
  String undoCost(int cost) {
    return '$cost';
  }

  @override
  String get freeSortTitle => 'Always tidy for free';

  @override
  String get freeSortBody =>
      'Tidying up your shelves stops costing coins, forever.';

  @override
  String freeSortBuy(int cost) {
    return 'Buy for $cost';
  }

  @override
  String get freeSortOwned => 'Already owned';

  @override
  String deliverTo(String customer) {
    return 'For $customer';
  }

  @override
  String get deliveryThanks => 'Thanks, neighbour!';

  @override
  String get bigOrderTitle => 'Wholesale order!';

  @override
  String bigOrderSub(String time) {
    return 'Leaves in $time';
  }

  @override
  String get bigOrderGone => 'The wholesaler left. Another one will come.';

  @override
  String bigOrderArrived(int reward) {
    return 'A big order arrived: pays $reward';
  }

  @override
  String get bigOrderBadge => 'WHOLESALE';

  @override
  String get toastCannotRerollBig => 'The wholesale order cannot be swapped';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String achievementsSub(int done, int total) {
    return '$done of $total unlocked';
  }

  @override
  String achievementClaim(int reward) {
    return 'Claim $reward';
  }

  @override
  String get achievementClaimed => 'Claimed';

  @override
  String achievementProgress(int have, int target) {
    return '$have / $target';
  }

  @override
  String toastAchievement(int reward) {
    return 'Achievement claimed! +$reward';
  }

  @override
  String get toastAchievementNotDone => 'Not there yet';

  @override
  String get achMerges1 => 'Getting started';

  @override
  String get achMerges2 => 'Good eye';

  @override
  String get achMerges3 => 'Master of the counter';

  @override
  String get achStreak1 => 'Five in a row';

  @override
  String get achStreak2 => 'On a roll';

  @override
  String get achOrders1 => 'First customers';

  @override
  String get achOrders2 => 'Regulars';

  @override
  String get achOrders3 => 'The neighbourhood store';

  @override
  String get achWholesale1 => 'Wholesale deal';

  @override
  String get achWholesale2 => 'Trusted supplier';

  @override
  String get achShop3 => 'A real shop';

  @override
  String get achShop7 => 'Your own shop window';

  @override
  String get achAlbum1 => 'Collector';

  @override
  String get achAlbum2 => 'Half the collection';

  @override
  String get achTill1 => 'First till';

  @override
  String get achTill2 => 'Full till';

  @override
  String achMergesDesc(int n) {
    return 'Merge $n products';
  }

  @override
  String achStreakDesc(int n) {
    return 'Merge $n times in a row, without doing anything else';
  }

  @override
  String achOrdersDesc(int n) {
    return 'Deliver $n orders';
  }

  @override
  String achWholesaleDesc(int n) {
    return 'Deliver $n wholesale orders';
  }

  @override
  String achShopDesc(int n) {
    return 'Take your shop to level $n';
  }

  @override
  String achAlbumDesc(int n) {
    return 'Discover $n different products';
  }

  @override
  String achTillDesc(int n) {
    return 'Collect $n coins from the till';
  }

  @override
  String toastFilled(int count) {
    return '$count products came in';
  }

  @override
  String get supplierHold => 'Hold to fill the board';

  @override
  String get chainPets => 'Pet food';

  @override
  String get pets1 => 'Food pouch';

  @override
  String get pets2 => 'Kibble bag';

  @override
  String get pets3 => 'Feed sack';

  @override
  String get pets4 => 'Premium pack';

  @override
  String get settingsPet => 'Shop pet';

  @override
  String get settingsPetSub =>
      'Having one opens the pet-food aisle, which pays better';

  @override
  String get petNone => 'None';

  @override
  String get petName1 => 'Cat';

  @override
  String get petName2 => 'Dog';

  @override
  String get petName3 => 'Parrot';

  @override
  String get petName4 => 'Tortoise';

  @override
  String get workerTitle => 'Hire help';

  @override
  String get workerSub => 'Merges stock and restocks while you are away';

  @override
  String workerLevel(int level) {
    return 'Level $level helper';
  }

  @override
  String workerDetail(int hours, int max, int rate) {
    return '$hours h · merges up to level $max · $rate actions per hour';
  }

  @override
  String workerHire(int cost) {
    return 'Hire for $cost';
  }

  @override
  String workerBusyUntil(String time) {
    return 'Working: $time left';
  }

  @override
  String workerExtend(int cost) {
    return 'Extend for $cost';
  }

  @override
  String get workerLockedMsg => 'You need a bigger shop to hire';

  @override
  String get workerDone => 'Your helper\'s shift is over';

  @override
  String workerReport(int merged, int bought) {
    return 'Your helper merged $merged and restocked $bought';
  }

  @override
  String workerHiredMsg(int hours) {
    return 'Helper hired for $hours h';
  }

  @override
  String get notificationWorkerTitle => 'Your helper left';

  @override
  String get notificationWorkerBody => 'Their shift at the shop is over.';

  @override
  String get notificationUpgradeTitle => 'You can upgrade the shop';

  @override
  String get notificationUpgradeBody =>
      'You saved up enough for the next level.';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsSoundSub => 'Effects when you complete actions';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsHapticsSub =>
      'Touch feedback when merging and getting paid';

  @override
  String get settingsReducedMotion => 'Reduce animations';

  @override
  String get settingsReducedMotionSub => 'Recommended on slower phones';

  @override
  String get settingsHints => 'Hints';

  @override
  String get settingsHintsSub => 'Highlight a possible move if you pause';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System language';

  @override
  String get settingsPremium => 'Neighborhood Club';

  @override
  String get settingsPremiumSub => 'Ad-free options (coming soon)';

  @override
  String get settingsAbout => 'About the game';

  @override
  String settingsStats(int orders, int merges) {
    return 'Orders completed: $orders · Products merged: $merges';
  }

  @override
  String get settingsPrivacyNote =>
      'This version works fully offline and collects no personal data.';

  @override
  String get premiumTitle => 'Neighborhood Club';

  @override
  String get premiumNotAvailable => 'Not available yet';

  @override
  String get premiumBody =>
      'This version has no ads and no purchases. We are testing the game first. When paid options exist, they will show up here with their real store price.';

  @override
  String get premiumEvaluating => 'What we are considering';

  @override
  String get premiumBullet1 => 'A one-time purchase to remove forced ads.';

  @override
  String get premiumBullet2 =>
      'A monthly club with decorations and a daily bonus, plus no forced ads.';

  @override
  String get premiumBullet3 =>
      'Rewarded ads will always be optional: the game can be played without watching any.';

  @override
  String itemSemantics(String name, int level) {
    return '$name, level $level';
  }

  @override
  String get marketTitle => 'Buy stock';

  @override
  String get marketNote =>
      'Buying costs more than an order pays. It is a shortcut when you are one item short, not a way to make money.';

  @override
  String get marketLocked => 'Reach a higher level to unlock';

  @override
  String buyFor(int price) {
    return 'Buy for $price';
  }

  @override
  String itemActionsTitle(String name, int level) {
    return '$name, level $level';
  }

  @override
  String get splitAction => 'Split into two';

  @override
  String splitInto(String name, int cost) {
    return 'Split into two $name for $cost';
  }

  @override
  String get splitNotPossible => 'Level 1 products cannot be split';

  @override
  String get expandTitle => 'Expand the counter';

  @override
  String expandBody(int columns) {
    return 'Unlock one more row of $columns slots.';
  }

  @override
  String expandFor(int cost) {
    return 'Expand for $cost';
  }

  @override
  String get boardMaxSize => 'The counter is already at full size.';

  @override
  String get lockedRow => 'Locked row. Tap to expand.';

  @override
  String get timeBonusLab => 'x1.5';

  @override
  String timeBonusTooltip(String time) {
    return 'Deliver within $time for a bonus';
  }

  @override
  String toastBought(int price) {
    return 'Bought for $price';
  }

  @override
  String toastSplit(int cost) {
    return 'Split for $cost';
  }

  @override
  String get toastExpanded => 'Counter expanded';

  @override
  String get toastCannotSplit => 'That product cannot be split.';

  @override
  String toastTimeBonus(int reward) {
    return 'Fast delivery! +$reward';
  }

  @override
  String perHourShort(int amount) {
    return '$amount/h';
  }

  @override
  String get buy => 'Buy';

  @override
  String get chainEggs => 'Eggs';

  @override
  String get chainCleaning => 'Household';

  @override
  String get eggs1 => 'Egg';

  @override
  String get eggs2 => 'Half Dozen';

  @override
  String get eggs3 => 'Egg Tray';

  @override
  String get cleaning1 => 'Soap';

  @override
  String get cleaning2 => 'Detergent';

  @override
  String get cleaning3 => 'Cleaning Pack';

  @override
  String get cleaning4 => 'Household Shelf';

  @override
  String get next => 'Next';

  @override
  String get deliverPartial => 'Deliver part';

  @override
  String toastPartial(int reward) {
    return 'Partial delivery. +$reward';
  }

  @override
  String get tillLabel => 'Till';

  @override
  String get tillFull => 'Till is full';

  @override
  String tillSemantics(int amount, int capacity) {
    return 'Till: $amount of $capacity coins. Tap to collect.';
  }

  @override
  String tillCollect(int amount) {
    return 'Collect $amount';
  }

  @override
  String get tillEmpty => 'Nothing to collect yet';

  @override
  String get tillUpgradeTitle => 'Bigger till';

  @override
  String tillUpgradeBody(int hours, int next) {
    return 'Holds ${hours}h of earnings. Upgraded, ${next}h.';
  }

  @override
  String tillUpgradeFor(int cost) {
    return 'Upgrade for $cost';
  }

  @override
  String get tillAtMax => 'The till is already at its biggest.';

  @override
  String toastTillCollected(int amount) {
    return 'Collected $amount';
  }

  @override
  String get toastTillUpgraded => 'Bigger till';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSub =>
      'Till full, helper\'s shift over, enough to upgrade';

  @override
  String get notificationTillFullTitle => 'Your till is full';

  @override
  String get notificationTillFullBody =>
      'Your store stopped selling. Come collect it.';

  @override
  String get notificationsBlocked =>
      'Notifications are off in Android settings';

  @override
  String get bakery6 => 'Birthday cake';

  @override
  String get drinks6 => 'Crate of drinks';

  @override
  String get snacks6 => 'Box of sweets';

  @override
  String get pets5 => 'Sack of pet food';

  @override
  String get cleaning5 => 'Cleaning box';

  @override
  String get fruit1 => 'Apple';

  @override
  String get fruit2 => 'Bag of apples';

  @override
  String get fruit3 => 'Crate of fruit';

  @override
  String get fruit4 => 'Pallet of fruit';

  @override
  String get dairy1 => 'Yoghurt';

  @override
  String get dairy2 => 'Pack of yoghurts';

  @override
  String get dairy3 => 'Litre of milk';

  @override
  String get dairy4 => 'Fresh cheese';

  @override
  String get dairy5 => 'Wheel of cheese';

  @override
  String get dairy6 => 'Dairy crate';

  @override
  String get dairy7 => 'Dairy cabinet';

  @override
  String get frozen1 => 'Ice lolly';

  @override
  String get frozen2 => 'Tub of ice cream';

  @override
  String get frozen3 => 'Bag of frozen veg';

  @override
  String get frozen4 => 'Frozen pizza';

  @override
  String get frozen5 => 'Box of frozen food';

  @override
  String get frozen6 => 'Stack of frozen food';

  @override
  String get frozen7 => 'Small freezer';

  @override
  String get frozen8 => 'Cold room';

  @override
  String get stationery1 => 'Pencil';

  @override
  String get stationery2 => 'Pencil case';

  @override
  String get stationery3 => 'Notebook';

  @override
  String get stationery4 => 'School set';

  @override
  String get stationery5 => 'Stationery box';

  @override
  String get chainFruit => 'Fruit and veg';

  @override
  String get chainDairy => 'Dairy';

  @override
  String get chainFrozen => 'Frozen';

  @override
  String get chainStationery => 'Stationery';

  @override
  String get achShop12 => 'The neighbourhood store';

  @override
  String get achShop17 => 'Minimarket';

  @override
  String get achShop22 => 'Fully renovated';

  @override
  String get achShop27 => 'Corner-shop empire';

  @override
  String get achAlbum3 => 'Full album';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get missionsToday => 'Today';

  @override
  String get missionsSub =>
      'New ones tomorrow. Nothing is lost if you miss them.';

  @override
  String missionsLocked(int level) {
    return 'Daily missions open at level $level';
  }

  @override
  String get achievementsAll => 'Lifetime achievements';

  @override
  String get missionDone => 'Done';

  @override
  String get mDailyMerges => 'Merge stock';

  @override
  String get mDailyMergesBig => 'A day at the counter';

  @override
  String get mDailyOrders => 'Serve your customers';

  @override
  String get mDailyOrdersBig => 'A busy day';

  @override
  String get mDailyGenerate => 'Order from the supplier';

  @override
  String get mDailyHighLevel => 'Premium stock';

  @override
  String get mDailyCoins => 'Take the money';

  @override
  String get mDailyTill => 'Empty the till';

  @override
  String mDescMerges(int n) {
    return 'Merge $n pairs today';
  }

  @override
  String mDescOrders(int n) {
    return 'Deliver $n orders today';
  }

  @override
  String mDescGenerate(int n) {
    return 'Order $n units from the supplier today';
  }

  @override
  String mDescHighLevel(int n) {
    return 'Make $n products of level 4 or higher today';
  }

  @override
  String mDescCoins(int n) {
    return 'Earn $n coins today';
  }

  @override
  String mDescTill(int n) {
    return 'Empty the till $n times today';
  }

  @override
  String get toastMissionsRefreshed => 'New missions are up';

  @override
  String get tutorialSupply =>
      'Tap the supplier’s box to bring stock to the counter.';

  @override
  String get tutorialReadOrder =>
      'Each card up top is a customer. It shows which product they want and what level.';

  @override
  String get tutorialTill =>
      'Your shop keeps selling while you are away. Tap the till to collect — once it is full, it stops filling.';

  @override
  String get helpTitle => 'How to play';

  @override
  String get helpOpen => 'How to play';

  @override
  String get helpOpenSub => 'Go over the rules any time';

  @override
  String get helpLoopTitle => 'The loop';

  @override
  String get helpLoopBody =>
      'Order stock from the supplier, merge two matching items into a better one, and hand it to the customer who asked for it. Delivering is the only thing that gives experience.';

  @override
  String get helpMergeTitle => 'Merging';

  @override
  String get helpMergeBody =>
      'Two matching products of the same level become one of the next level. It is worth more than the two apart, so merging always pays. While dragging, the target square turns green if they will merge and red if they will only swap.';

  @override
  String get helpOrdersTitle => 'Orders';

  @override
  String get helpOrdersBody =>
      'Each card shows the product a customer wants and its level. Orders never expire: delivering in the first few minutes pays more, but after that they simply pay the normal amount. Nothing punishes you for putting the phone down.';

  @override
  String get helpTillTitle => 'The till';

  @override
  String get helpTillBody =>
      'Your shop keeps selling while you are away and stores it in the till. Tap it to collect. It has a cap: once full it stops filling, so it is worth emptying. You can enlarge it in the shop.';

  @override
  String get helpShopTitle => 'Upgrading the shop';

  @override
  String helpShopBody(int max) {
    return 'Coins upgrade your shop, up to level $max. Each level earns more per hour, and every few levels the shop gets a new look. The stars in the name show how far you are within the current look.';
  }

  @override
  String get helpGoalsTitle => 'Goals';

  @override
  String get helpGoalsBody =>
      'Every day brings three new missions: they are what you can do today. Missing them costs nothing — tomorrow brings three more. Achievements, in contrast, last the whole game.';

  @override
  String get helpHelpersTitle => 'Helpers';

  @override
  String helpHelpersBody(int worker) {
    return '\"Tidy up\" arranges stock by type and level so you can see what can be merged. Holding the supplier’s box fills the counter in one go. From shop level $worker you can hire someone by the hour who merges and restocks while you are away.';
  }

  @override
  String get settingsSectionVoice => 'Your feedback';

  @override
  String get feedbackSend => 'Send feedback';

  @override
  String get feedbackSendSub =>
      'Tell us what worked and what didn’t. We read everything.';

  @override
  String get feedbackSubject => 'Feedback about El Kiosko';

  @override
  String get feedbackIntro =>
      'Write your comment, idea or the problem you found here:';

  @override
  String get feedbackDiagnostics =>
      'Technical details (they help find the problem; feel free to delete)';

  @override
  String get feedbackRate => 'Rate on Google Play';

  @override
  String get feedbackRateSub => 'A rating helps others find it';

  @override
  String get feedbackNoMail => 'Couldn’t open your mail app';
}
