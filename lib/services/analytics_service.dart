import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logRecipeViewed({
    required String recipeId,
    required String recipeName,
    required String categoryId,
  }) =>
      _analytics.logEvent(
        name: 'recipe_viewed',
        parameters: {
          'recipe_id': recipeId,
          'recipe_name': recipeName,
          'category_id': categoryId,
        },
      );

  Future<void> logRecipeFavorited({
    required String recipeId,
    required String recipeName,
  }) =>
      _analytics.logEvent(
        name: 'recipe_favorited',
        parameters: {
          'recipe_id': recipeId,
          'recipe_name': recipeName,
        },
      );

  Future<void> logRecipeShared({
    required String recipeId,
    required String recipeName,
  }) =>
      _analytics.logEvent(
        name: 'recipe_shared',
        parameters: {
          'recipe_id': recipeId,
          'recipe_name': recipeName,
        },
      );

  Future<void> logWaterReminderSet({
    required int reminderCount,
    required int intervalMinutes,
  }) =>
      _analytics.logEvent(
        name: 'water_reminder_set',
        parameters: {
          'reminder_count': reminderCount,
          'interval_minutes': intervalMinutes,
        },
      );
}
