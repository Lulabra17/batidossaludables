// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Batidos Saludables';

  @override
  String get welcomeMessage =>
      'Bienvenid@, aqui encontraras bebidas naturales y nutritivas para cuidar tu cuerpo y tu mente.\n\nY lo mejor!!!\n\nPodrás hacerlas desde casa.';

  @override
  String get welcomeButton => '¡Adelante!';

  @override
  String get homeTitle => 'Bebidas Saludables desde Casa';

  @override
  String smoothiesCategoryTitle(String categoryName) {
    return 'Batidos $categoryName';
  }

  @override
  String get categoriesTitle => 'Categorias';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get noFavorites => 'No hay recetas favoritas';

  @override
  String get ingredientsTitle => 'Ingredientes';

  @override
  String get preparationTitle => 'Preparación';

  @override
  String get addedToFavorites => 'Agregado a Favoritos';

  @override
  String get removeFromFavoritesHint =>
      'Desde la sección de Favoritos podrás eliminarla.';

  @override
  String get searchHint => 'Busqueda por palabra o ingrediente...';

  @override
  String get searchPrompt => 'Introduce texto para iniciar la búsqueda...';

  @override
  String get noResults => 'No se encontraron coincidencias.';

  @override
  String get reminderScreenTitle => 'Recordar tomar agua';

  @override
  String get dailyGoalLabel => 'TU META DIARIA';

  @override
  String get enterWeightPrompt => '\nIngresa tu peso para calcular';

  @override
  String get perDayByWeight => 'al día según tu peso';

  @override
  String get calculateByWeightLabel => 'CALCULAR SEGÚN TU PESO';

  @override
  String get weightHint => 'Tu peso en kg';

  @override
  String get calculateButton => 'Calcular';

  @override
  String get reminderRoutineTitle => 'Rutina de recordatorios';

  @override
  String get wakeUpLabel => '🌅  Me despierto';

  @override
  String get sleepLabel => '🌙  Me duermo';

  @override
  String remindersCount(int count) {
    return 'Tienes $count recordatorios programados';
  }

  @override
  String get activateReminders => 'Activar recordatorios';

  @override
  String get deleteReminders => 'Borrar recordatorios existentes';

  @override
  String get scheduledRemindersLabel => 'RECORDATORIOS PROGRAMADOS';

  @override
  String drinkWaterAt(String time) {
    return 'Beber agua a las $time';
  }

  @override
  String get invalidWeightError => 'Por favor, ingresa un peso válido.';

  @override
  String get calculateWaterFirstError =>
      'Por favor, calcula la cantidad de agua primero.';

  @override
  String get sleepAfterWakeError =>
      'La hora de dormir debe ser después de la de despertar.';

  @override
  String get notificationPermissionRequired =>
      'El permiso de notificaciones es necesario para los recordatorios.';

  @override
  String get alarmNotificationTitle => '¡Recordatorio!';

  @override
  String get alarmNotificationStop => 'Detener';

  @override
  String get waterPhrase0 => 'Es hora de tomar tu vaso de agua.';

  @override
  String get waterPhrase1 => '¡Hora de hidratarte! Toma un vaso de agua ahora.';

  @override
  String get waterPhrase2 =>
      'Tu cuerpo te lo agradecerá, bebe un vaso de agua.';

  @override
  String get waterPhrase3 =>
      'Pausa lo que haces y toma un vaso de agua fresca.';

  @override
  String get waterPhrase4 =>
      '¡Vamos! Un sorbo no basta, toma un vaso completo de agua.';

  @override
  String get waterPhrase5 => 'Mantente en forma, toma tu vaso de agua ahora.';

  @override
  String get waterPhrase6 =>
      '¡Recarga tu cuerpo! Es momento de beber un vaso de agua.';

  @override
  String get waterPhrase7 =>
      'Tu salud es primero, hidrátate con un vaso de agua.';

  @override
  String get waterPhrase8 =>
      '¡Tómate un break saludable! Bebe un vaso de agua.';

  @override
  String get waterPhrase9 =>
      'Dale a tu cuerpo lo que necesita: un buen vaso de agua.';

  @override
  String get recipeDayNotifTitle => '🥤 Tu batido del día';

  @override
  String get recipeDayNotifBody =>
      'Abre la app y prepara tu batido saludable de hoy.';

  @override
  String get recipeDayCardTitle => 'Receta del día';

  @override
  String get recipeDayCardSubtitle =>
      'Recibe una receta nueva cada mañana a las 8am';

  @override
  String get recipeDayActivate => 'Activar notificación diaria';

  @override
  String get recipeDayActive => 'Notificación diaria activa';

  @override
  String get shareEnjoy => '¡Disfruta este batido saludable!';

  @override
  String get shareDownloadApp =>
      '\n🥤 Receta de *Batidos Saludables* — 144 recetas de jugos y batidos naturales, gratis para Android:\nhttps://play.google.com/store/apps/details?id=com.slisapps.batidossalud&utm_source=share&utm_medium=app&utm_campaign=recipe_share';

  @override
  String shareSubject(String recipeName) {
    return 'Receta: $recipeName';
  }

  @override
  String get shareIngredients => '📝 *Ingredientes:*';

  @override
  String get sharePreparation => '👨‍🍳 *Preparación:*';
}
