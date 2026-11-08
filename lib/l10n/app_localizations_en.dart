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
  String get appSlogan => 'More fruits, more vitality, more life.';

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
  String get noFavoritesHint =>
      'Explore the recipes and mark\nthe ones you like the most.';

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
  String get deleteReminders => 'Delete all';

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
  String get recipeDayNotifTitle => '🥤 Your smoothie of the day';

  @override
  String get recipeDayNotifBody =>
      'Open the app and make your healthy smoothie today.';

  @override
  String get recipeDayCardTitle => 'Recipe of the day';

  @override
  String get recipeDayCardSubtitle => 'Get a new recipe every morning at 8am';

  @override
  String get recipeDayActivate => 'Activate daily notification';

  @override
  String get recipeDayActive => 'Daily notification active';

  @override
  String get shareEnjoy => 'Enjoy this healthy smoothie!';

  @override
  String get shareDownloadApp =>
      '\n🥤 Recipe from *Healthy Smoothies* — 144 natural juice and smoothie recipes, free for Android:\nhttps://play.google.com/store/apps/details?id=com.slisapps.batidossalud&utm_source=share&utm_medium=app&utm_campaign=recipe_share';

  @override
  String shareSubject(String recipeName) {
    return 'Recipe: $recipeName';
  }

  @override
  String get shareIngredients => '📝 *Ingredients:*';

  @override
  String get sharePreparation => '👨‍🍳 *Preparation:*';

  @override
  String get cat1 => 'Detox Smoothies';

  @override
  String get cat2 => 'For Constipation';

  @override
  String get cat3 => 'For Stress & Anxiety';

  @override
  String get cat4 => 'For Water Retention';

  @override
  String get cat5 => 'For Better Circulation';

  @override
  String get cat6 => 'For Better Skin';

  @override
  String get cat7 => 'For Muscle Mass';

  @override
  String get cat8 => 'For Abdominal Fat';

  @override
  String get cat9 => 'For Headaches';

  @override
  String get cat10 => 'For Diabetes';

  @override
  String get cat11 => 'For Hypertension';

  @override
  String get cat12 => 'For Hemorrhoids';

  @override
  String get cat13 => 'For Menstrual Pain';

  @override
  String get cat14 => 'For Hangovers';

  @override
  String get cat15 => 'For the Flu';

  @override
  String get cat16 => 'For Fatty Liver';

  @override
  String get cat17 => 'For Colon Inflammation';

  @override
  String get cat18 => 'For Gastritis';

  @override
  String get cat19 => 'Teas for Weight Loss';

  @override
  String get cat20 => 'Laxative Teas';

  @override
  String get cat21 => 'Teas for Headaches';

  @override
  String get cat22 => 'Rejuvenating Smoothies';

  @override
  String get cat23 => 'Immunity Smoothies for Kids';

  @override
  String get tabSetup => 'Setup';

  @override
  String get tabReminders => 'Reminders';

  @override
  String get tabToday => 'Today';

  @override
  String get kimoSetupGuide =>
      'Hello! Set up your daily hydration to get started.';

  @override
  String get kimoSetupConfigured => 'All set! Your reminders are active.';

  @override
  String get noRemindersInfo =>
      'No reminders yet. Go to Setup to configure them.';

  @override
  String get goToSetupButton => 'Go to Setup';

  @override
  String get reconfigurarButton => 'Reconfigure';

  @override
  String get todayProgressTitle => 'TODAY\'S PROGRESS';

  @override
  String get kimoComment0pct => 'Start your hydration today! 💧';

  @override
  String get kimoComment25pct => 'Come on! You need more water 💪';

  @override
  String get kimoComment50pct => 'Great pace! You\'re halfway there ⭐';

  @override
  String get kimoComment75pct => 'Almost there! Just a bit more 🌟';

  @override
  String get kimoComment100pct => 'Goal achieved! You\'re amazing! 🎉';

  @override
  String get addWaterTitle => 'LOG WATER';

  @override
  String get resetDayButton => 'Reset day';

  @override
  String get reminderLabelMorning => 'Morning hydration';

  @override
  String get reminderLabelMidMorning => 'Mid-morning';

  @override
  String get reminderLabelMidday => 'Midday hydration';

  @override
  String get reminderLabelAfternoon => 'Afternoon recharge';

  @override
  String get reminderLabelEvening => 'Evening hydration';

  @override
  String get reminderLabelNight => 'Before sleep';

  @override
  String get editReminderRoutine => 'Change routine';
}
