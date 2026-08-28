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
  String tutorialStepOf(int step) {
    return 'Step $step of 3';
  }

  @override
  String get tutorialMerge => 'Drag two matching products together.';

  @override
  String get tutorialOrder => 'Now complete an order and get paid.';

  @override
  String get tutorialUpgrade => 'Use your coins to upgrade the store.';

  @override
  String get skip => 'Skip';

  @override
  String get undoSell => 'Undo sale';

  @override
  String get undoMerge => 'Undo merge';

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
  String get notificationsSub => 'Tell me when the till is full';

  @override
  String get notificationTillFullTitle => 'Your till is full';

  @override
  String get notificationTillFullBody =>
      'Your store stopped selling. Come collect it.';

  @override
  String get notificationsBlocked =>
      'Notifications are off in Android settings';
}
