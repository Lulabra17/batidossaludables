// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Healthy Smoothies';

  @override
  String get welcomeMessage =>
      'Welcome! Here you\'ll find natural and nutritious drinks to take care of your body and mind.\n\nAnd the best part!!!\n\nYou can make them at home.';

  @override
  String get welcomeButton => 'Let\'s go!';

  @override
  String get homeTitle => 'Healthy Drinks from Home';

  @override
  String smoothiesCategoryTitle(String categoryName) {
    return 'Smoothies $categoryName';
  }

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get noFavorites => 'No favorite recipes';

  @override
  String get ingredientsTitle => 'Ingredients';

  @override
  String get preparationTitle => 'Preparation';

  @override
  String get addedToFavorites => 'Added to Favorites';

  @override
  String get removeFromFavoritesHint =>
      'From the Favorites section you can remove it.';

  @override
  String get searchHint => 'Search by word or ingredient...';

  @override
  String get searchPrompt => 'Enter text to start searching...';

  @override
  String get noResults => 'No matches found.';

  @override
  String get reminderScreenTitle => 'Remember to drink water';

  @override
  String get dailyGoalLabel => 'YOUR DAILY GOAL';

  @override
  String get enterWeightPrompt => '\nEnter your weight to calculate';

  @override
  String get perDayByWeight => 'per day based on your weight';

  @override
  String get calculateByWeightLabel => 'CALCULATE BY YOUR WEIGHT';

  @override
  String get weightHint => 'Your weight in kg';

  @override
  String get calculateButton => 'Calculate';

  @override
  String get reminderRoutineTitle => 'Reminder routine';

  @override
  String get wakeUpLabel => '🌅  I wake up';

  @override
  String get sleepLabel => '🌙  I go to sleep';

  @override
  String remindersCount(int count) {
    return 'You have $count reminders set';
  }

  @override
  String get activateReminders => 'Activate reminders';

  @override
  String get deleteReminders => 'Delete existing reminders';

  @override
  String get scheduledRemindersLabel => 'SCHEDULED REMINDERS';

  @override
  String drinkWaterAt(String time) {
    return 'Drink water at $time';
  }

  @override
  String get invalidWeightError => 'Please enter a valid weight.';

  @override
  String get calculateWaterFirstError =>
      'Please calculate the water amount first.';

  @override
  String get sleepAfterWakeError => 'Sleep time must be after wake time.';

  @override
  String get notificationPermissionRequired =>
      'Notification permission is required for reminders.';

  @override
  String get alarmNotificationTitle => 'Reminder!';

  @override
  String get alarmNotificationStop => 'Stop';

  @override
  String get waterPhrase0 => 'Time to drink your glass of water.';

  @override
  String get waterPhrase1 => 'Time to hydrate! Drink a glass of water now.';

  @override
  String get waterPhrase2 =>
      'Your body will thank you, drink a glass of water.';

  @override
  String get waterPhrase3 => 'Take a break and drink a glass of fresh water.';

  @override
  String get waterPhrase4 =>
      'Come on! A sip is not enough, drink a full glass of water.';

  @override
  String get waterPhrase5 => 'Stay fit, drink your glass of water now.';

  @override
  String get waterPhrase6 =>
      'Recharge your body! It\'s time to drink a glass of water.';

  @override
  String get waterPhrase7 =>
      'Your health comes first, hydrate with a glass of water.';

  @override
  String get waterPhrase8 => 'Take a healthy break! Drink a glass of water.';

  @override
  String get waterPhrase9 =>
      'Give your body what it needs: a good glass of water.';

  @override
  String get shareEnjoy => 'Enjoy this healthy smoothie!';

  @override
  String get shareDownloadApp =>
      '\nIf you haven\'t downloaded our app yet, you can do so at https://play.google.com/store/apps/details?id=com.slisapps.batidossalud';

  @override
  String shareSubject(String recipeName) {
    return 'Recipe: $recipeName';
  }

  @override
  String get shareIngredients => '📝 *Ingredients:*';

  @override
  String get sharePreparation => '👨‍🍳 *Preparation:*';
}
