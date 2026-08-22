import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// App name shown in the task switcher
  ///
  /// In en, this message translates to:
  /// **'Corner Store'**
  String get appTitle;

  /// No description provided for @chainBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get chainBakery;

  /// No description provided for @chainDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get chainDrinks;

  /// No description provided for @chainSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get chainSnacks;

  /// No description provided for @bakery1.
  ///
  /// In en, this message translates to:
  /// **'Bread Roll'**
  String get bakery1;

  /// No description provided for @bakery2.
  ///
  /// In en, this message translates to:
  /// **'Bag of Bread'**
  String get bakery2;

  /// No description provided for @bakery3.
  ///
  /// In en, this message translates to:
  /// **'Bread Basket'**
  String get bakery3;

  /// No description provided for @bakery4.
  ///
  /// In en, this message translates to:
  /// **'Assorted Tray'**
  String get bakery4;

  /// No description provided for @bakery5.
  ///
  /// In en, this message translates to:
  /// **'Bakery Display'**
  String get bakery5;

  /// No description provided for @drinks1.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get drinks1;

  /// No description provided for @drinks2.
  ///
  /// In en, this message translates to:
  /// **'Small Bottle'**
  String get drinks2;

  /// No description provided for @drinks3.
  ///
  /// In en, this message translates to:
  /// **'Large Bottle'**
  String get drinks3;

  /// No description provided for @drinks4.
  ///
  /// In en, this message translates to:
  /// **'Six-Pack'**
  String get drinks4;

  /// No description provided for @drinks5.
  ///
  /// In en, this message translates to:
  /// **'Drinks Fridge'**
  String get drinks5;

  /// No description provided for @snacks1.
  ///
  /// In en, this message translates to:
  /// **'Candy'**
  String get snacks1;

  /// No description provided for @snacks2.
  ///
  /// In en, this message translates to:
  /// **'Small Bag'**
  String get snacks2;

  /// No description provided for @snacks3.
  ///
  /// In en, this message translates to:
  /// **'Snack Pack'**
  String get snacks3;

  /// No description provided for @snacks4.
  ///
  /// In en, this message translates to:
  /// **'Assorted Box'**
  String get snacks4;

  /// No description provided for @snacks5.
  ///
  /// In en, this message translates to:
  /// **'Snack Shelf'**
  String get snacks5;

  /// No description provided for @customer0.
  ///
  /// In en, this message translates to:
  /// **'The Bus Driver'**
  String get customer0;

  /// No description provided for @customer1.
  ///
  /// In en, this message translates to:
  /// **'The Neighbor'**
  String get customer1;

  /// No description provided for @customer2.
  ///
  /// In en, this message translates to:
  /// **'Evening Student'**
  String get customer2;

  /// No description provided for @customer3.
  ///
  /// In en, this message translates to:
  /// **'The Kiosk Owner'**
  String get customer3;

  /// No description provided for @customer4.
  ///
  /// In en, this message translates to:
  /// **'Market Vendor'**
  String get customer4;

  /// No description provided for @customer5.
  ///
  /// In en, this message translates to:
  /// **'Night Shift'**
  String get customer5;

  /// No description provided for @customer6.
  ///
  /// In en, this message translates to:
  /// **'Delivery Rider'**
  String get customer6;

  /// No description provided for @customer7.
  ///
  /// In en, this message translates to:
  /// **'The Retiree'**
  String get customer7;

  /// No description provided for @customer8.
  ///
  /// In en, this message translates to:
  /// **'The Teacher'**
  String get customer8;

  /// No description provided for @customer9.
  ///
  /// In en, this message translates to:
  /// **'Office Worker'**
  String get customer9;

  /// No description provided for @customer10.
  ///
  /// In en, this message translates to:
  /// **'The Entrepreneur'**
  String get customer10;

  /// No description provided for @customer11.
  ///
  /// In en, this message translates to:
  /// **'The Builder'**
  String get customer11;

  /// No description provided for @shopTier1.
  ///
  /// In en, this message translates to:
  /// **'Makeshift Counter'**
  String get shopTier1;

  /// No description provided for @shopTier2.
  ///
  /// In en, this message translates to:
  /// **'Kiosk'**
  String get shopTier2;

  /// No description provided for @shopTier3.
  ///
  /// In en, this message translates to:
  /// **'Small Shop'**
  String get shopTier3;

  /// No description provided for @shopTier4.
  ///
  /// In en, this message translates to:
  /// **'Corner Store'**
  String get shopTier4;

  /// No description provided for @shopTier5.
  ///
  /// In en, this message translates to:
  /// **'Minimarket'**
  String get shopTier5;

  /// No description provided for @shopTier6.
  ///
  /// In en, this message translates to:
  /// **'Renovated Store'**
  String get shopTier6;

  /// No description provided for @shopTier7.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood Chain'**
  String get shopTier7;

  /// No description provided for @shopTagline1.
  ///
  /// In en, this message translates to:
  /// **'A plank, two crates and plenty of hope.'**
  String get shopTagline1;

  /// No description provided for @shopTagline2.
  ///
  /// In en, this message translates to:
  /// **'You have a roof and a service window now.'**
  String get shopTagline2;

  /// No description provided for @shopTagline3.
  ///
  /// In en, this message translates to:
  /// **'One customer at a time, but they come in.'**
  String get shopTagline3;

  /// No description provided for @shopTagline4.
  ///
  /// In en, this message translates to:
  /// **'People greet you by name.'**
  String get shopTagline4;

  /// No description provided for @shopTagline5.
  ///
  /// In en, this message translates to:
  /// **'Your own fridge and a lit-up sign.'**
  String get shopTagline5;

  /// No description provided for @shopTagline6.
  ///
  /// In en, this message translates to:
  /// **'New floor, display cases and a queue at the till.'**
  String get shopTagline6;

  /// No description provided for @shopTagline7.
  ///
  /// In en, this message translates to:
  /// **'The most loved store in the area.'**
  String get shopTagline7;

  /// No description provided for @playerLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String playerLevel(int level);

  /// No description provided for @coinsLabel.
  ///
  /// In en, this message translates to:
  /// **'{coins} coins'**
  String coinsLabel(int coins);

  /// No description provided for @tooltipCollection.
  ///
  /// In en, this message translates to:
  /// **'Product album'**
  String get tooltipCollection;

  /// No description provided for @tooltipShop.
  ///
  /// In en, this message translates to:
  /// **'Upgrade your store'**
  String get tooltipShop;

  /// No description provided for @tooltipSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltipSettings;

  /// No description provided for @shopUpgradeReady.
  ///
  /// In en, this message translates to:
  /// **'You can upgrade your store'**
  String get shopUpgradeReady;

  /// No description provided for @supplierBox.
  ///
  /// In en, this message translates to:
  /// **'Supplier\'s box'**
  String get supplierBox;

  /// No description provided for @supplierCost.
  ///
  /// In en, this message translates to:
  /// **'Costs {cost}'**
  String supplierCost(int cost);

  /// No description provided for @boardFull.
  ///
  /// In en, this message translates to:
  /// **'Board is full'**
  String get boardFull;

  /// No description provided for @notEnoughCoinsShort.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins'**
  String get notEnoughCoinsShort;

  /// No description provided for @supplierSemantics.
  ///
  /// In en, this message translates to:
  /// **'Supplier\'s box. {hint}'**
  String supplierSemantics(String hint);

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @sellDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sellDone;

  /// No description provided for @deliver.
  ///
  /// In en, this message translates to:
  /// **'Deliver'**
  String get deliver;

  /// No description provided for @missing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get missing;

  /// No description provided for @rerollTooltip.
  ///
  /// In en, this message translates to:
  /// **'Swap this order for {cost}'**
  String rerollTooltip(int cost);

  /// No description provided for @orderSemantics.
  ///
  /// In en, this message translates to:
  /// **'Order from {customer}. {status}. Pays {reward}.'**
  String orderSemantics(String customer, String status, int reward);

  /// No description provided for @orderReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to deliver'**
  String get orderReady;

  /// No description provided for @orderNotReady.
  ///
  /// In en, this message translates to:
  /// **'Still missing items'**
  String get orderNotReady;

  /// No description provided for @tutorialStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 3'**
  String tutorialStepOf(int step);

  /// No description provided for @tutorialMerge.
  ///
  /// In en, this message translates to:
  /// **'Drag two matching products together.'**
  String get tutorialMerge;

  /// No description provided for @tutorialOrder.
  ///
  /// In en, this message translates to:
  /// **'Now complete an order and get paid.'**
  String get tutorialOrder;

  /// No description provided for @tutorialUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Use your coins to upgrade the store.'**
  String get tutorialUpgrade;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Your store kept selling'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'While you were away, {amount} coins piled up in the till.'**
  String offlineBody(int amount);

  /// No description provided for @offlineContinue.
  ///
  /// In en, this message translates to:
  /// **'Back to work'**
  String get offlineContinue;

  /// No description provided for @toastOrderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Order delivered! +{reward}'**
  String toastOrderDelivered(int reward);

  /// No description provided for @toastShopUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Your store is now a {name}'**
  String toastShopUpgraded(String name);

  /// No description provided for @toastLevelUp.
  ///
  /// In en, this message translates to:
  /// **'You reached level {level}'**
  String toastLevelUp(int level);

  /// No description provided for @toastChainUnlocked.
  ///
  /// In en, this message translates to:
  /// **'New product in the store: {chain}'**
  String toastChainUnlocked(String chain);

  /// No description provided for @toastSold.
  ///
  /// In en, this message translates to:
  /// **'Sold for {value}'**
  String toastSold(int value);

  /// No description provided for @toastRelief.
  ///
  /// In en, this message translates to:
  /// **'The supplier fronts you {amount} to keep going.'**
  String toastRelief(int amount);

  /// No description provided for @toastNotEnoughCoins.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins.'**
  String get toastNotEnoughCoins;

  /// No description provided for @toastBoardFull.
  ///
  /// In en, this message translates to:
  /// **'The board is full. Sell or deliver something.'**
  String get toastBoardFull;

  /// No description provided for @toastOrderNotReady.
  ///
  /// In en, this message translates to:
  /// **'You are still missing items.'**
  String get toastOrderNotReady;

  /// No description provided for @toastMaxShopLevel.
  ///
  /// In en, this message translates to:
  /// **'Your store is already at the top level.'**
  String get toastMaxShopLevel;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Your store'**
  String get shopTitle;

  /// No description provided for @shopIncomePerHour.
  ///
  /// In en, this message translates to:
  /// **'Earns {amount} per hour while you are away.'**
  String shopIncomePerHour(int amount);

  /// No description provided for @shopNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String shopNext(String name);

  /// No description provided for @shopShelves.
  ///
  /// In en, this message translates to:
  /// **'Shelves'**
  String get shopShelves;

  /// No description provided for @shopCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get shopCustomers;

  /// No description provided for @shopIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income per hour'**
  String get shopIncomeLabel;

  /// No description provided for @shopUpgradeFor.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for {cost}'**
  String shopUpgradeFor(int cost);

  /// No description provided for @shopMissingCoins.
  ///
  /// In en, this message translates to:
  /// **'{amount} coins short'**
  String shopMissingCoins(int amount);

  /// No description provided for @shopAllLevels.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get shopAllLevels;

  /// No description provided for @shopStartingPoint.
  ///
  /// In en, this message translates to:
  /// **'Starting point'**
  String get shopStartingPoint;

  /// No description provided for @shopCosts.
  ///
  /// In en, this message translates to:
  /// **'Costs {cost}'**
  String shopCosts(int cost);

  /// No description provided for @shopMaxedOut.
  ///
  /// In en, this message translates to:
  /// **'You have reached the highest level for now. More levels are coming in future updates.'**
  String get shopMaxedOut;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Store album'**
  String get collectionTitle;

  /// No description provided for @collectionProgress.
  ///
  /// In en, this message translates to:
  /// **'Discovered {found} of {total}'**
  String collectionProgress(int found, int total);

  /// No description provided for @collectionUnknown.
  ///
  /// In en, this message translates to:
  /// **'???'**
  String get collectionUnknown;

  /// No description provided for @collectionLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String collectionLevel(int level);

  /// No description provided for @collectionFoundSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, discovered'**
  String collectionFoundSemantics(String name);

  /// No description provided for @collectionMissingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Level {level} product, not discovered yet'**
  String collectionMissingSemantics(int level);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsSoundSub.
  ///
  /// In en, this message translates to:
  /// **'Effects when you complete actions'**
  String get settingsSoundSub;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsHaptics;

  /// No description provided for @settingsHapticsSub.
  ///
  /// In en, this message translates to:
  /// **'Touch feedback when merging and getting paid'**
  String get settingsHapticsSub;

  /// No description provided for @settingsReducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce animations'**
  String get settingsReducedMotion;

  /// No description provided for @settingsReducedMotionSub.
  ///
  /// In en, this message translates to:
  /// **'Recommended on slower phones'**
  String get settingsReducedMotionSub;

  /// No description provided for @settingsHints.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get settingsHints;

  /// No description provided for @settingsHintsSub.
  ///
  /// In en, this message translates to:
  /// **'Highlight a possible move if you pause'**
  String get settingsHintsSub;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsPremium.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood Club'**
  String get settingsPremium;

  /// No description provided for @settingsPremiumSub.
  ///
  /// In en, this message translates to:
  /// **'Ad-free options (coming soon)'**
  String get settingsPremiumSub;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About the game'**
  String get settingsAbout;

  /// No description provided for @settingsStats.
  ///
  /// In en, this message translates to:
  /// **'Orders completed: {orders} · Products merged: {merges}'**
  String settingsStats(int orders, int merges);

  /// No description provided for @settingsPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'This version works fully offline and collects no personal data.'**
  String get settingsPrivacyNote;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood Club'**
  String get premiumTitle;

  /// No description provided for @premiumNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get premiumNotAvailable;

  /// No description provided for @premiumBody.
  ///
  /// In en, this message translates to:
  /// **'This version has no ads and no purchases. We are testing the game first. When paid options exist, they will show up here with their real store price.'**
  String get premiumBody;

  /// No description provided for @premiumEvaluating.
  ///
  /// In en, this message translates to:
  /// **'What we are considering'**
  String get premiumEvaluating;

  /// No description provided for @premiumBullet1.
  ///
  /// In en, this message translates to:
  /// **'A one-time purchase to remove forced ads.'**
  String get premiumBullet1;

  /// No description provided for @premiumBullet2.
  ///
  /// In en, this message translates to:
  /// **'A monthly club with decorations and a daily bonus, plus no forced ads.'**
  String get premiumBullet2;

  /// No description provided for @premiumBullet3.
  ///
  /// In en, this message translates to:
  /// **'Rewarded ads will always be optional: the game can be played without watching any.'**
  String get premiumBullet3;

  /// No description provided for @itemSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, level {level}'**
  String itemSemantics(String name, int level);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
