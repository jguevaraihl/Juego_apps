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
  /// **'Step {step} of {total}'**
  String tutorialStepOf(int step, int total);

  /// No description provided for @tutorialMerge.
  ///
  /// In en, this message translates to:
  /// **'Drag a product onto a matching one: the two become a better one.'**
  String get tutorialMerge;

  /// No description provided for @tutorialOrder.
  ///
  /// In en, this message translates to:
  /// **'Once you have what a customer wants, hand it over and get paid.'**
  String get tutorialOrder;

  /// No description provided for @tutorialUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Coins upgrade your shop: it earns more per hour, and every few levels it gets a new look.'**
  String get tutorialUpgrade;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @undoSell.
  ///
  /// In en, this message translates to:
  /// **'Undo sale'**
  String get undoSell;

  /// No description provided for @undoSplit.
  ///
  /// In en, this message translates to:
  /// **'Undo split'**
  String get undoSplit;

  /// No description provided for @undoBuy.
  ///
  /// In en, this message translates to:
  /// **'Undo purchase'**
  String get undoBuy;

  /// No description provided for @undoReroll.
  ///
  /// In en, this message translates to:
  /// **'Undo swap'**
  String get undoReroll;

  /// No description provided for @toastUndone.
  ///
  /// In en, this message translates to:
  /// **'Done, back the way it was'**
  String get toastUndone;

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

  /// No description provided for @offlineTotal.
  ///
  /// In en, this message translates to:
  /// **'With what you hadn\'t collected, the till adds up to {amount}.'**
  String offlineTotal(int amount);

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

  /// No description provided for @settingsSectionLook.
  ///
  /// In en, this message translates to:
  /// **'Your store'**
  String get settingsSectionLook;

  /// No description provided for @settingsSectionPlay.
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get settingsSectionPlay;

  /// No description provided for @settingsSectionAccess.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsSectionAccess;

  /// No description provided for @settingsStoreName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get settingsStoreName;

  /// No description provided for @settingsStoreNameSub.
  ///
  /// In en, this message translates to:
  /// **'Shown on the storefront sign'**
  String get settingsStoreNameSub;

  /// No description provided for @settingsStoreNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The Corner Shop'**
  String get settingsStoreNameHint;

  /// No description provided for @settingsStoreNameDefault.
  ///
  /// In en, this message translates to:
  /// **'No custom name'**
  String get settingsStoreNameDefault;

  /// No description provided for @settingsStoreNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Up to {max} characters. Leave it empty to use the level name.'**
  String settingsStoreNameHelp(int max);

  /// No description provided for @settingsAwning.
  ///
  /// In en, this message translates to:
  /// **'Awning colour'**
  String get settingsAwning;

  /// No description provided for @settingsAwningSub.
  ///
  /// In en, this message translates to:
  /// **'Pick your store\'s fabric'**
  String get settingsAwningSub;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match the phone'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextSize;

  /// No description provided for @settingsTextSizeSub.
  ///
  /// In en, this message translates to:
  /// **'Adds to your phone\'s own text size'**
  String get settingsTextSizeSub;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @awningColorName1.
  ///
  /// In en, this message translates to:
  /// **'Terracotta'**
  String get awningColorName1;

  /// No description provided for @awningColorName2.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get awningColorName2;

  /// No description provided for @awningColorName3.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get awningColorName3;

  /// No description provided for @awningColorName4.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get awningColorName4;

  /// No description provided for @awningColorName5.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get awningColorName5;

  /// No description provided for @awningColorName6.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get awningColorName6;

  /// No description provided for @awningColorName7.
  ///
  /// In en, this message translates to:
  /// **'Mustard'**
  String get awningColorName7;

  /// No description provided for @awningColorName8.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get awningColorName8;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Tidy up'**
  String get sort;

  /// No description provided for @sortFree.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get sortFree;

  /// No description provided for @toastSorted.
  ///
  /// In en, this message translates to:
  /// **'Shelves tidied up'**
  String get toastSorted;

  /// No description provided for @toastSortedFree.
  ///
  /// In en, this message translates to:
  /// **'Shelves tidied up, no charge'**
  String get toastSortedFree;

  /// No description provided for @toastAlreadySorted.
  ///
  /// In en, this message translates to:
  /// **'Already tidy'**
  String get toastAlreadySorted;

  /// No description provided for @toastAlreadyOwned.
  ///
  /// In en, this message translates to:
  /// **'You already own it'**
  String get toastAlreadyOwned;

  /// No description provided for @toastUndoneCost.
  ///
  /// In en, this message translates to:
  /// **'Done, back the way it was (-{cost})'**
  String toastUndoneCost(int cost);

  /// No description provided for @undoCost.
  ///
  /// In en, this message translates to:
  /// **'{cost}'**
  String undoCost(int cost);

  /// No description provided for @freeSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Always tidy for free'**
  String get freeSortTitle;

  /// No description provided for @freeSortBody.
  ///
  /// In en, this message translates to:
  /// **'Tidying up your shelves stops costing coins, forever.'**
  String get freeSortBody;

  /// No description provided for @freeSortBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy for {cost}'**
  String freeSortBuy(int cost);

  /// No description provided for @freeSortOwned.
  ///
  /// In en, this message translates to:
  /// **'Already owned'**
  String get freeSortOwned;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'For {customer}'**
  String deliverTo(String customer);

  /// No description provided for @deliveryThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks, neighbour!'**
  String get deliveryThanks;

  /// No description provided for @bigOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Wholesale order!'**
  String get bigOrderTitle;

  /// No description provided for @bigOrderSub.
  ///
  /// In en, this message translates to:
  /// **'Leaves in {time}'**
  String bigOrderSub(String time);

  /// No description provided for @bigOrderGone.
  ///
  /// In en, this message translates to:
  /// **'The wholesaler left. Another one will come.'**
  String get bigOrderGone;

  /// No description provided for @bigOrderArrived.
  ///
  /// In en, this message translates to:
  /// **'A big order arrived: pays {reward}'**
  String bigOrderArrived(int reward);

  /// No description provided for @bigOrderBadge.
  ///
  /// In en, this message translates to:
  /// **'WHOLESALE'**
  String get bigOrderBadge;

  /// No description provided for @toastCannotRerollBig.
  ///
  /// In en, this message translates to:
  /// **'The wholesale order cannot be swapped'**
  String get toastCannotRerollBig;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementsSub.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} unlocked'**
  String achievementsSub(int done, int total);

  /// No description provided for @achievementClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim {reward}'**
  String achievementClaim(int reward);

  /// No description provided for @achievementClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get achievementClaimed;

  /// No description provided for @achievementProgress.
  ///
  /// In en, this message translates to:
  /// **'{have} / {target}'**
  String achievementProgress(int have, int target);

  /// No description provided for @toastAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement claimed! +{reward}'**
  String toastAchievement(int reward);

  /// No description provided for @toastAchievementNotDone.
  ///
  /// In en, this message translates to:
  /// **'Not there yet'**
  String get toastAchievementNotDone;

  /// No description provided for @achMerges1.
  ///
  /// In en, this message translates to:
  /// **'Getting started'**
  String get achMerges1;

  /// No description provided for @achMerges2.
  ///
  /// In en, this message translates to:
  /// **'Good eye'**
  String get achMerges2;

  /// No description provided for @achMerges3.
  ///
  /// In en, this message translates to:
  /// **'Master of the counter'**
  String get achMerges3;

  /// No description provided for @achStreak1.
  ///
  /// In en, this message translates to:
  /// **'Five in a row'**
  String get achStreak1;

  /// No description provided for @achStreak2.
  ///
  /// In en, this message translates to:
  /// **'On a roll'**
  String get achStreak2;

  /// No description provided for @achOrders1.
  ///
  /// In en, this message translates to:
  /// **'First customers'**
  String get achOrders1;

  /// No description provided for @achOrders2.
  ///
  /// In en, this message translates to:
  /// **'Regulars'**
  String get achOrders2;

  /// No description provided for @achOrders3.
  ///
  /// In en, this message translates to:
  /// **'The neighbourhood store'**
  String get achOrders3;

  /// No description provided for @achWholesale1.
  ///
  /// In en, this message translates to:
  /// **'Wholesale deal'**
  String get achWholesale1;

  /// No description provided for @achWholesale2.
  ///
  /// In en, this message translates to:
  /// **'Trusted supplier'**
  String get achWholesale2;

  /// No description provided for @achShop3.
  ///
  /// In en, this message translates to:
  /// **'A real shop'**
  String get achShop3;

  /// No description provided for @achShop7.
  ///
  /// In en, this message translates to:
  /// **'Your own shop window'**
  String get achShop7;

  /// No description provided for @achAlbum1.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get achAlbum1;

  /// No description provided for @achAlbum2.
  ///
  /// In en, this message translates to:
  /// **'Half the collection'**
  String get achAlbum2;

  /// No description provided for @achTill1.
  ///
  /// In en, this message translates to:
  /// **'First till'**
  String get achTill1;

  /// No description provided for @achTill2.
  ///
  /// In en, this message translates to:
  /// **'Full till'**
  String get achTill2;

  /// No description provided for @achMergesDesc.
  ///
  /// In en, this message translates to:
  /// **'Merge {n} products'**
  String achMergesDesc(int n);

  /// No description provided for @achStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Merge {n} times in a row, without doing anything else'**
  String achStreakDesc(int n);

  /// No description provided for @achOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Deliver {n} orders'**
  String achOrdersDesc(int n);

  /// No description provided for @achWholesaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Deliver {n} wholesale orders'**
  String achWholesaleDesc(int n);

  /// No description provided for @achShopDesc.
  ///
  /// In en, this message translates to:
  /// **'Take your shop to level {n}'**
  String achShopDesc(int n);

  /// No description provided for @achAlbumDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover {n} different products'**
  String achAlbumDesc(int n);

  /// No description provided for @achTillDesc.
  ///
  /// In en, this message translates to:
  /// **'Collect {n} coins from the till'**
  String achTillDesc(int n);

  /// No description provided for @toastFilled.
  ///
  /// In en, this message translates to:
  /// **'{count} products came in'**
  String toastFilled(int count);

  /// No description provided for @supplierHold.
  ///
  /// In en, this message translates to:
  /// **'Hold to fill the board'**
  String get supplierHold;

  /// No description provided for @chainPets.
  ///
  /// In en, this message translates to:
  /// **'Pet food'**
  String get chainPets;

  /// No description provided for @pets1.
  ///
  /// In en, this message translates to:
  /// **'Food pouch'**
  String get pets1;

  /// No description provided for @pets2.
  ///
  /// In en, this message translates to:
  /// **'Kibble bag'**
  String get pets2;

  /// No description provided for @pets3.
  ///
  /// In en, this message translates to:
  /// **'Feed sack'**
  String get pets3;

  /// No description provided for @pets4.
  ///
  /// In en, this message translates to:
  /// **'Premium pack'**
  String get pets4;

  /// No description provided for @settingsPet.
  ///
  /// In en, this message translates to:
  /// **'Shop pet'**
  String get settingsPet;

  /// No description provided for @settingsPetSub.
  ///
  /// In en, this message translates to:
  /// **'Having one opens the pet-food aisle, which pays better'**
  String get settingsPetSub;

  /// No description provided for @petNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get petNone;

  /// No description provided for @petName1.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get petName1;

  /// No description provided for @petName2.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get petName2;

  /// No description provided for @petName3.
  ///
  /// In en, this message translates to:
  /// **'Parrot'**
  String get petName3;

  /// No description provided for @petName4.
  ///
  /// In en, this message translates to:
  /// **'Tortoise'**
  String get petName4;

  /// No description provided for @workerTitle.
  ///
  /// In en, this message translates to:
  /// **'Hire help'**
  String get workerTitle;

  /// No description provided for @workerSub.
  ///
  /// In en, this message translates to:
  /// **'Merges stock and restocks while you are away'**
  String get workerSub;

  /// No description provided for @workerLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level} helper'**
  String workerLevel(int level);

  /// No description provided for @workerDetail.
  ///
  /// In en, this message translates to:
  /// **'{hours} h · merges up to level {max} · {rate} actions per hour'**
  String workerDetail(int hours, int max, int rate);

  /// No description provided for @workerHire.
  ///
  /// In en, this message translates to:
  /// **'Hire for {cost}'**
  String workerHire(int cost);

  /// No description provided for @workerBusyUntil.
  ///
  /// In en, this message translates to:
  /// **'Working: {time} left'**
  String workerBusyUntil(String time);

  /// No description provided for @workerExtend.
  ///
  /// In en, this message translates to:
  /// **'Extend for {cost}'**
  String workerExtend(int cost);

  /// No description provided for @workerLockedMsg.
  ///
  /// In en, this message translates to:
  /// **'You need a bigger shop to hire'**
  String get workerLockedMsg;

  /// No description provided for @workerDone.
  ///
  /// In en, this message translates to:
  /// **'Your helper\'s shift is over'**
  String get workerDone;

  /// No description provided for @workerReport.
  ///
  /// In en, this message translates to:
  /// **'Your helper merged {merged} and restocked {bought}'**
  String workerReport(int merged, int bought);

  /// No description provided for @workerHiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Helper hired for {hours} h'**
  String workerHiredMsg(int hours);

  /// No description provided for @notificationWorkerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your helper left'**
  String get notificationWorkerTitle;

  /// No description provided for @notificationWorkerBody.
  ///
  /// In en, this message translates to:
  /// **'Their shift at the shop is over.'**
  String get notificationWorkerBody;

  /// No description provided for @notificationUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'You can upgrade the shop'**
  String get notificationUpgradeTitle;

  /// No description provided for @notificationUpgradeBody.
  ///
  /// In en, this message translates to:
  /// **'You saved up enough for the next level.'**
  String get notificationUpgradeBody;

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

  /// No description provided for @marketTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy stock'**
  String get marketTitle;

  /// No description provided for @marketNote.
  ///
  /// In en, this message translates to:
  /// **'Buying costs more than an order pays. It is a shortcut when you are one item short, not a way to make money.'**
  String get marketNote;

  /// No description provided for @marketLocked.
  ///
  /// In en, this message translates to:
  /// **'Reach a higher level to unlock'**
  String get marketLocked;

  /// No description provided for @buyFor.
  ///
  /// In en, this message translates to:
  /// **'Buy for {price}'**
  String buyFor(int price);

  /// No description provided for @itemActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}, level {level}'**
  String itemActionsTitle(String name, int level);

  /// No description provided for @splitAction.
  ///
  /// In en, this message translates to:
  /// **'Split into two'**
  String get splitAction;

  /// No description provided for @splitInto.
  ///
  /// In en, this message translates to:
  /// **'Split into two {name} for {cost}'**
  String splitInto(String name, int cost);

  /// No description provided for @splitNotPossible.
  ///
  /// In en, this message translates to:
  /// **'Level 1 products cannot be split'**
  String get splitNotPossible;

  /// No description provided for @expandTitle.
  ///
  /// In en, this message translates to:
  /// **'Expand the counter'**
  String get expandTitle;

  /// No description provided for @expandBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock one more row of {columns} slots.'**
  String expandBody(int columns);

  /// No description provided for @expandFor.
  ///
  /// In en, this message translates to:
  /// **'Expand for {cost}'**
  String expandFor(int cost);

  /// No description provided for @boardMaxSize.
  ///
  /// In en, this message translates to:
  /// **'The counter is already at full size.'**
  String get boardMaxSize;

  /// No description provided for @lockedRow.
  ///
  /// In en, this message translates to:
  /// **'Locked row. Tap to expand.'**
  String get lockedRow;

  /// No description provided for @timeBonusLab.
  ///
  /// In en, this message translates to:
  /// **'x1.5'**
  String get timeBonusLab;

  /// No description provided for @timeBonusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Deliver within {time} for a bonus'**
  String timeBonusTooltip(String time);

  /// No description provided for @toastBought.
  ///
  /// In en, this message translates to:
  /// **'Bought for {price}'**
  String toastBought(int price);

  /// No description provided for @toastSplit.
  ///
  /// In en, this message translates to:
  /// **'Split for {cost}'**
  String toastSplit(int cost);

  /// No description provided for @toastExpanded.
  ///
  /// In en, this message translates to:
  /// **'Counter expanded'**
  String get toastExpanded;

  /// No description provided for @toastCannotSplit.
  ///
  /// In en, this message translates to:
  /// **'That product cannot be split.'**
  String get toastCannotSplit;

  /// No description provided for @toastTimeBonus.
  ///
  /// In en, this message translates to:
  /// **'Fast delivery! +{reward}'**
  String toastTimeBonus(int reward);

  /// No description provided for @perHourShort.
  ///
  /// In en, this message translates to:
  /// **'{amount}/h'**
  String perHourShort(int amount);

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @chainEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get chainEggs;

  /// No description provided for @chainCleaning.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get chainCleaning;

  /// No description provided for @eggs1.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get eggs1;

  /// No description provided for @eggs2.
  ///
  /// In en, this message translates to:
  /// **'Half Dozen'**
  String get eggs2;

  /// No description provided for @eggs3.
  ///
  /// In en, this message translates to:
  /// **'Egg Tray'**
  String get eggs3;

  /// No description provided for @cleaning1.
  ///
  /// In en, this message translates to:
  /// **'Soap'**
  String get cleaning1;

  /// No description provided for @cleaning2.
  ///
  /// In en, this message translates to:
  /// **'Detergent'**
  String get cleaning2;

  /// No description provided for @cleaning3.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Pack'**
  String get cleaning3;

  /// No description provided for @cleaning4.
  ///
  /// In en, this message translates to:
  /// **'Household Shelf'**
  String get cleaning4;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @deliverPartial.
  ///
  /// In en, this message translates to:
  /// **'Deliver part'**
  String get deliverPartial;

  /// No description provided for @toastPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial delivery. +{reward}'**
  String toastPartial(int reward);

  /// No description provided for @tillLabel.
  ///
  /// In en, this message translates to:
  /// **'Till'**
  String get tillLabel;

  /// No description provided for @tillFull.
  ///
  /// In en, this message translates to:
  /// **'Till is full'**
  String get tillFull;

  /// No description provided for @tillSemantics.
  ///
  /// In en, this message translates to:
  /// **'Till: {amount} of {capacity} coins. Tap to collect.'**
  String tillSemantics(int amount, int capacity);

  /// No description provided for @tillCollect.
  ///
  /// In en, this message translates to:
  /// **'Collect {amount}'**
  String tillCollect(int amount);

  /// No description provided for @tillEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to collect yet'**
  String get tillEmpty;

  /// No description provided for @tillUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Bigger till'**
  String get tillUpgradeTitle;

  /// No description provided for @tillUpgradeBody.
  ///
  /// In en, this message translates to:
  /// **'Holds {hours}h of earnings. Upgraded, {next}h.'**
  String tillUpgradeBody(int hours, int next);

  /// No description provided for @tillUpgradeFor.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for {cost}'**
  String tillUpgradeFor(int cost);

  /// No description provided for @tillAtMax.
  ///
  /// In en, this message translates to:
  /// **'The till is already at its biggest.'**
  String get tillAtMax;

  /// No description provided for @toastTillCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected {amount}'**
  String toastTillCollected(int amount);

  /// No description provided for @toastTillUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Bigger till'**
  String get toastTillUpgraded;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Till full, helper\'s shift over, enough to upgrade'**
  String get notificationsSub;

  /// No description provided for @notificationTillFullTitle.
  ///
  /// In en, this message translates to:
  /// **'Your till is full'**
  String get notificationTillFullTitle;

  /// No description provided for @notificationTillFullBody.
  ///
  /// In en, this message translates to:
  /// **'Your store stopped selling. Come collect it.'**
  String get notificationTillFullBody;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off in Android settings'**
  String get notificationsBlocked;

  /// No description provided for @bakery6.
  ///
  /// In en, this message translates to:
  /// **'Birthday cake'**
  String get bakery6;

  /// No description provided for @drinks6.
  ///
  /// In en, this message translates to:
  /// **'Crate of drinks'**
  String get drinks6;

  /// No description provided for @snacks6.
  ///
  /// In en, this message translates to:
  /// **'Box of sweets'**
  String get snacks6;

  /// No description provided for @pets5.
  ///
  /// In en, this message translates to:
  /// **'Sack of pet food'**
  String get pets5;

  /// No description provided for @cleaning5.
  ///
  /// In en, this message translates to:
  /// **'Cleaning box'**
  String get cleaning5;

  /// No description provided for @fruit1.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get fruit1;

  /// No description provided for @fruit2.
  ///
  /// In en, this message translates to:
  /// **'Bag of apples'**
  String get fruit2;

  /// No description provided for @fruit3.
  ///
  /// In en, this message translates to:
  /// **'Crate of fruit'**
  String get fruit3;

  /// No description provided for @fruit4.
  ///
  /// In en, this message translates to:
  /// **'Pallet of fruit'**
  String get fruit4;

  /// No description provided for @dairy1.
  ///
  /// In en, this message translates to:
  /// **'Yoghurt'**
  String get dairy1;

  /// No description provided for @dairy2.
  ///
  /// In en, this message translates to:
  /// **'Pack of yoghurts'**
  String get dairy2;

  /// No description provided for @dairy3.
  ///
  /// In en, this message translates to:
  /// **'Litre of milk'**
  String get dairy3;

  /// No description provided for @dairy4.
  ///
  /// In en, this message translates to:
  /// **'Fresh cheese'**
  String get dairy4;

  /// No description provided for @dairy5.
  ///
  /// In en, this message translates to:
  /// **'Wheel of cheese'**
  String get dairy5;

  /// No description provided for @dairy6.
  ///
  /// In en, this message translates to:
  /// **'Dairy crate'**
  String get dairy6;

  /// No description provided for @dairy7.
  ///
  /// In en, this message translates to:
  /// **'Dairy cabinet'**
  String get dairy7;

  /// No description provided for @frozen1.
  ///
  /// In en, this message translates to:
  /// **'Ice lolly'**
  String get frozen1;

  /// No description provided for @frozen2.
  ///
  /// In en, this message translates to:
  /// **'Tub of ice cream'**
  String get frozen2;

  /// No description provided for @frozen3.
  ///
  /// In en, this message translates to:
  /// **'Bag of frozen veg'**
  String get frozen3;

  /// No description provided for @frozen4.
  ///
  /// In en, this message translates to:
  /// **'Frozen pizza'**
  String get frozen4;

  /// No description provided for @frozen5.
  ///
  /// In en, this message translates to:
  /// **'Box of frozen food'**
  String get frozen5;

  /// No description provided for @frozen6.
  ///
  /// In en, this message translates to:
  /// **'Stack of frozen food'**
  String get frozen6;

  /// No description provided for @frozen7.
  ///
  /// In en, this message translates to:
  /// **'Small freezer'**
  String get frozen7;

  /// No description provided for @frozen8.
  ///
  /// In en, this message translates to:
  /// **'Cold room'**
  String get frozen8;

  /// No description provided for @stationery1.
  ///
  /// In en, this message translates to:
  /// **'Pencil'**
  String get stationery1;

  /// No description provided for @stationery2.
  ///
  /// In en, this message translates to:
  /// **'Pencil case'**
  String get stationery2;

  /// No description provided for @stationery3.
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get stationery3;

  /// No description provided for @stationery4.
  ///
  /// In en, this message translates to:
  /// **'School set'**
  String get stationery4;

  /// No description provided for @stationery5.
  ///
  /// In en, this message translates to:
  /// **'Stationery box'**
  String get stationery5;

  /// No description provided for @chainFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit and veg'**
  String get chainFruit;

  /// No description provided for @chainDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get chainDairy;

  /// No description provided for @chainFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get chainFrozen;

  /// No description provided for @chainStationery.
  ///
  /// In en, this message translates to:
  /// **'Stationery'**
  String get chainStationery;

  /// No description provided for @achShop12.
  ///
  /// In en, this message translates to:
  /// **'The neighbourhood store'**
  String get achShop12;

  /// No description provided for @achShop17.
  ///
  /// In en, this message translates to:
  /// **'Minimarket'**
  String get achShop17;

  /// No description provided for @achShop22.
  ///
  /// In en, this message translates to:
  /// **'Fully renovated'**
  String get achShop22;

  /// No description provided for @achShop27.
  ///
  /// In en, this message translates to:
  /// **'Corner-shop empire'**
  String get achShop27;

  /// No description provided for @achAlbum3.
  ///
  /// In en, this message translates to:
  /// **'Full album'**
  String get achAlbum3;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// No description provided for @missionsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get missionsToday;

  /// No description provided for @missionsSub.
  ///
  /// In en, this message translates to:
  /// **'New ones tomorrow. Nothing is lost if you miss them.'**
  String get missionsSub;

  /// No description provided for @missionsLocked.
  ///
  /// In en, this message translates to:
  /// **'Daily missions open at level {level}'**
  String missionsLocked(int level);

  /// No description provided for @achievementsAll.
  ///
  /// In en, this message translates to:
  /// **'Lifetime achievements'**
  String get achievementsAll;

  /// No description provided for @missionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get missionDone;

  /// No description provided for @mDailyMerges.
  ///
  /// In en, this message translates to:
  /// **'Merge stock'**
  String get mDailyMerges;

  /// No description provided for @mDailyMergesBig.
  ///
  /// In en, this message translates to:
  /// **'A day at the counter'**
  String get mDailyMergesBig;

  /// No description provided for @mDailyOrders.
  ///
  /// In en, this message translates to:
  /// **'Serve your customers'**
  String get mDailyOrders;

  /// No description provided for @mDailyOrdersBig.
  ///
  /// In en, this message translates to:
  /// **'A busy day'**
  String get mDailyOrdersBig;

  /// No description provided for @mDailyGenerate.
  ///
  /// In en, this message translates to:
  /// **'Order from the supplier'**
  String get mDailyGenerate;

  /// No description provided for @mDailyHighLevel.
  ///
  /// In en, this message translates to:
  /// **'Premium stock'**
  String get mDailyHighLevel;

  /// No description provided for @mDailyCoins.
  ///
  /// In en, this message translates to:
  /// **'Take the money'**
  String get mDailyCoins;

  /// No description provided for @mDailyTill.
  ///
  /// In en, this message translates to:
  /// **'Empty the till'**
  String get mDailyTill;

  /// No description provided for @mDescMerges.
  ///
  /// In en, this message translates to:
  /// **'Merge {n} pairs today'**
  String mDescMerges(int n);

  /// No description provided for @mDescOrders.
  ///
  /// In en, this message translates to:
  /// **'Deliver {n} orders today'**
  String mDescOrders(int n);

  /// No description provided for @mDescGenerate.
  ///
  /// In en, this message translates to:
  /// **'Order {n} units from the supplier today'**
  String mDescGenerate(int n);

  /// No description provided for @mDescHighLevel.
  ///
  /// In en, this message translates to:
  /// **'Make {n} products of level 4 or higher today'**
  String mDescHighLevel(int n);

  /// No description provided for @mDescCoins.
  ///
  /// In en, this message translates to:
  /// **'Earn {n} coins today'**
  String mDescCoins(int n);

  /// No description provided for @mDescTill.
  ///
  /// In en, this message translates to:
  /// **'Empty the till {n} times today'**
  String mDescTill(int n);

  /// No description provided for @toastMissionsRefreshed.
  ///
  /// In en, this message translates to:
  /// **'New missions are up'**
  String get toastMissionsRefreshed;

  /// No description provided for @tutorialSupply.
  ///
  /// In en, this message translates to:
  /// **'Tap the supplier’s box to bring stock to the counter.'**
  String get tutorialSupply;

  /// No description provided for @tutorialReadOrder.
  ///
  /// In en, this message translates to:
  /// **'Each card up top is a customer. It shows which product they want and what level.'**
  String get tutorialReadOrder;

  /// No description provided for @tutorialTill.
  ///
  /// In en, this message translates to:
  /// **'Your shop keeps selling while you are away. Tap the till to collect — once it is full, it stops filling.'**
  String get tutorialTill;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get helpTitle;

  /// No description provided for @helpOpen.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get helpOpen;

  /// No description provided for @helpOpenSub.
  ///
  /// In en, this message translates to:
  /// **'Go over the rules any time'**
  String get helpOpenSub;

  /// No description provided for @helpLoopTitle.
  ///
  /// In en, this message translates to:
  /// **'The loop'**
  String get helpLoopTitle;

  /// No description provided for @helpLoopBody.
  ///
  /// In en, this message translates to:
  /// **'Order stock from the supplier, merge two matching items into a better one, and hand it to the customer who asked for it. Delivering is the only thing that gives experience.'**
  String get helpLoopBody;

  /// No description provided for @helpMergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merging'**
  String get helpMergeTitle;

  /// No description provided for @helpMergeBody.
  ///
  /// In en, this message translates to:
  /// **'Two matching products of the same level become one of the next level. It is worth more than the two apart, so merging always pays. While dragging, the target square turns green if they will merge and red if they will only swap.'**
  String get helpMergeBody;

  /// No description provided for @helpOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get helpOrdersTitle;

  /// No description provided for @helpOrdersBody.
  ///
  /// In en, this message translates to:
  /// **'Each card shows the product a customer wants and its level. Orders never expire: delivering in the first few minutes pays more, but after that they simply pay the normal amount. Nothing punishes you for putting the phone down.'**
  String get helpOrdersBody;

  /// No description provided for @helpTillTitle.
  ///
  /// In en, this message translates to:
  /// **'The till'**
  String get helpTillTitle;

  /// No description provided for @helpTillBody.
  ///
  /// In en, this message translates to:
  /// **'Your shop keeps selling while you are away and stores it in the till. Tap it to collect. It has a cap: once full it stops filling, so it is worth emptying. You can enlarge it in the shop.'**
  String get helpTillBody;

  /// No description provided for @helpShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrading the shop'**
  String get helpShopTitle;

  /// No description provided for @helpShopBody.
  ///
  /// In en, this message translates to:
  /// **'Coins upgrade your shop, up to level {max}. Each level earns more per hour, and every few levels the shop gets a new look. The stars in the name show how far you are within the current look.'**
  String helpShopBody(int max);

  /// No description provided for @helpGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get helpGoalsTitle;

  /// No description provided for @helpGoalsBody.
  ///
  /// In en, this message translates to:
  /// **'Every day brings three new missions: they are what you can do today. Missing them costs nothing — tomorrow brings three more. Achievements, in contrast, last the whole game.'**
  String get helpGoalsBody;

  /// No description provided for @helpHelpersTitle.
  ///
  /// In en, this message translates to:
  /// **'Helpers'**
  String get helpHelpersTitle;

  /// No description provided for @helpHelpersBody.
  ///
  /// In en, this message translates to:
  /// **'\"Tidy up\" arranges stock by type and level so you can see what can be merged. Holding the supplier’s box fills the counter in one go. From shop level {worker} you can hire someone by the hour who merges and restocks while you are away.'**
  String helpHelpersBody(int worker);
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
