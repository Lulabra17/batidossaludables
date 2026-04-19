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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Healthy Smoothies'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Here you\'ll find natural and nutritious drinks to take care of your body and mind.\n\nAnd the best part!!!\n\nYou can make them at home.'**
  String get welcomeMessage;

  /// No description provided for @welcomeButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get welcomeButton;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Healthy Drinks from Home'**
  String get homeTitle;

  /// No description provided for @smoothiesCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Smoothies {categoryName}'**
  String smoothiesCategoryTitle(String categoryName);

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorite recipes'**
  String get noFavorites;

  /// No description provided for @ingredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsTitle;

  /// No description provided for @preparationTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get preparationTitle;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get addedToFavorites;

  /// No description provided for @removeFromFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'From the Favorites section you can remove it.'**
  String get removeFromFavoritesHint;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by word or ingredient...'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter text to start searching...'**
  String get searchPrompt;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matches found.'**
  String get noResults;

  /// No description provided for @reminderScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember to drink water'**
  String get reminderScreenTitle;

  /// No description provided for @dailyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR DAILY GOAL'**
  String get dailyGoalLabel;

  /// No description provided for @enterWeightPrompt.
  ///
  /// In en, this message translates to:
  /// **'\nEnter your weight to calculate'**
  String get enterWeightPrompt;

  /// No description provided for @perDayByWeight.
  ///
  /// In en, this message translates to:
  /// **'per day based on your weight'**
  String get perDayByWeight;

  /// No description provided for @calculateByWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'CALCULATE BY YOUR WEIGHT'**
  String get calculateByWeightLabel;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'Your weight in kg'**
  String get weightHint;

  /// No description provided for @calculateButton.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculateButton;

  /// No description provided for @reminderRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder routine'**
  String get reminderRoutineTitle;

  /// No description provided for @wakeUpLabel.
  ///
  /// In en, this message translates to:
  /// **'🌅  I wake up'**
  String get wakeUpLabel;

  /// No description provided for @sleepLabel.
  ///
  /// In en, this message translates to:
  /// **'🌙  I go to sleep'**
  String get sleepLabel;

  /// No description provided for @remindersCount.
  ///
  /// In en, this message translates to:
  /// **'You have {count} reminders set'**
  String remindersCount(int count);

  /// No description provided for @activateReminders.
  ///
  /// In en, this message translates to:
  /// **'Activate reminders'**
  String get activateReminders;

  /// No description provided for @deleteReminders.
  ///
  /// In en, this message translates to:
  /// **'Delete existing reminders'**
  String get deleteReminders;

  /// No description provided for @scheduledRemindersLabel.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED REMINDERS'**
  String get scheduledRemindersLabel;

  /// No description provided for @drinkWaterAt.
  ///
  /// In en, this message translates to:
  /// **'Drink water at {time}'**
  String drinkWaterAt(String time);

  /// No description provided for @invalidWeightError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight.'**
  String get invalidWeightError;

  /// No description provided for @calculateWaterFirstError.
  ///
  /// In en, this message translates to:
  /// **'Please calculate the water amount first.'**
  String get calculateWaterFirstError;

  /// No description provided for @sleepAfterWakeError.
  ///
  /// In en, this message translates to:
  /// **'Sleep time must be after wake time.'**
  String get sleepAfterWakeError;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required for reminders.'**
  String get notificationPermissionRequired;

  /// No description provided for @alarmNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder!'**
  String get alarmNotificationTitle;

  /// No description provided for @alarmNotificationStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get alarmNotificationStop;

  /// No description provided for @waterPhrase0.
  ///
  /// In en, this message translates to:
  /// **'Time to drink your glass of water.'**
  String get waterPhrase0;

  /// No description provided for @waterPhrase1.
  ///
  /// In en, this message translates to:
  /// **'Time to hydrate! Drink a glass of water now.'**
  String get waterPhrase1;

  /// No description provided for @waterPhrase2.
  ///
  /// In en, this message translates to:
  /// **'Your body will thank you, drink a glass of water.'**
  String get waterPhrase2;

  /// No description provided for @waterPhrase3.
  ///
  /// In en, this message translates to:
  /// **'Take a break and drink a glass of fresh water.'**
  String get waterPhrase3;

  /// No description provided for @waterPhrase4.
  ///
  /// In en, this message translates to:
  /// **'Come on! A sip is not enough, drink a full glass of water.'**
  String get waterPhrase4;

  /// No description provided for @waterPhrase5.
  ///
  /// In en, this message translates to:
  /// **'Stay fit, drink your glass of water now.'**
  String get waterPhrase5;

  /// No description provided for @waterPhrase6.
  ///
  /// In en, this message translates to:
  /// **'Recharge your body! It\'s time to drink a glass of water.'**
  String get waterPhrase6;

  /// No description provided for @waterPhrase7.
  ///
  /// In en, this message translates to:
  /// **'Your health comes first, hydrate with a glass of water.'**
  String get waterPhrase7;

  /// No description provided for @waterPhrase8.
  ///
  /// In en, this message translates to:
  /// **'Take a healthy break! Drink a glass of water.'**
  String get waterPhrase8;

  /// No description provided for @waterPhrase9.
  ///
  /// In en, this message translates to:
  /// **'Give your body what it needs: a good glass of water.'**
  String get waterPhrase9;

  /// No description provided for @recipeDayNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'🥤 Your smoothie of the day'**
  String get recipeDayNotifTitle;

  /// No description provided for @recipeDayNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Open the app and make your healthy smoothie today.'**
  String get recipeDayNotifBody;

  /// No description provided for @recipeDayCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe of the day'**
  String get recipeDayCardTitle;

  /// No description provided for @recipeDayCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a new recipe every morning at 8am'**
  String get recipeDayCardSubtitle;

  /// No description provided for @recipeDayActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate daily notification'**
  String get recipeDayActivate;

  /// No description provided for @recipeDayActive.
  ///
  /// In en, this message translates to:
  /// **'Daily notification active'**
  String get recipeDayActive;

  /// No description provided for @shareEnjoy.
  ///
  /// In en, this message translates to:
  /// **'Enjoy this healthy smoothie!'**
  String get shareEnjoy;

  /// No description provided for @shareDownloadApp.
  ///
  /// In en, this message translates to:
  /// **'\n🥤 Recipe from *Healthy Smoothies* — 144 natural juice and smoothie recipes, free for Android:\nhttps://play.google.com/store/apps/details?id=com.slisapps.batidossalud&utm_source=share&utm_medium=app&utm_campaign=recipe_share'**
  String get shareDownloadApp;

  /// No description provided for @shareSubject.
  ///
  /// In en, this message translates to:
  /// **'Recipe: {recipeName}'**
  String shareSubject(String recipeName);

  /// No description provided for @shareIngredients.
  ///
  /// In en, this message translates to:
  /// **'📝 *Ingredients:*'**
  String get shareIngredients;

  /// No description provided for @sharePreparation.
  ///
  /// In en, this message translates to:
  /// **'👨‍🍳 *Preparation:*'**
  String get sharePreparation;
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
      'that was used.');
}
