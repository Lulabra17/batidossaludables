import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Gestiona la notificación diaria "Receta del día" a las 8:00 am.
/// Calcula la hora local directamente con DateTime.now() sin depender de
/// flutter_timezone, y convierte a UTC para programar la notificación.
class RecipeNotificationService {
  static const int _notifId = 1001;
  static const String _channelId = 'recipe_of_day';
  static const String _prefKey = 'recipe_notif_enabled';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializar el servicio. Llamar en main() antes de runApp.
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
  }

  /// Devuelve true si el usuario tiene la notificación diaria activada.
  static bool isEnabled() {
    return Hive.box('Favoritos').get(_prefKey, defaultValue: true) as bool;
  }

  /// Activa la notificación la primera vez que se instala la app.
  /// En inicios posteriores, reprograma si el usuario la tiene activa
  /// (garantiza que siempre haya una notificación pendiente tras reiniciar la app).
  static Future<void> enableIfFirstTime() async {
    final box = Hive.box('Favoritos');
    final isSpanish =
        PlatformDispatcher.instance.locale.languageCode == 'es';
    final title =
        isSpanish ? '🥤 Tu batido del día' : '🥤 Your smoothie of the day';
    final body = isSpanish
        ? 'Abre la app y prepara tu batido saludable de hoy.'
        : 'Open the app and make your healthy smoothie today.';

    if (box.containsKey(_prefKey)) {
      // Ya configurado — reprogramar solo si está activo
      if (isEnabled()) {
        try {
          await _schedule(title: title, body: body);
        } catch (e) {
          debugPrint('⚠️ No se pudo reprogramar notificación de receta: $e');
        }
      }
      return;
    }

    // Primera instalación: activar por defecto
    await enable(title: title, body: body);
  }

  /// Activa la notificación diaria y guarda la preferencia en Hive.
  static Future<void> enable({
    required String title,
    required String body,
  }) async {
    await Hive.box('Favoritos').put(_prefKey, true);
    await _schedule(title: title, body: body);
  }

  /// Desactiva la notificación y elimina la programación existente.
  static Future<void> disable() async {
    await Hive.box('Favoritos').put(_prefKey, false);
    await _plugin.cancel(_notifId);
  }

  /// Programa la notificación diaria a las 8:00 am hora local.
  /// Convierte la hora local a UTC para que tz.UTC sea la referencia,
  /// lo que evita necesitar flutter_timezone para obtener el nombre del timezone.
  static Future<void> _schedule({
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();

    var next8am = DateTime(now.year, now.month, now.day, 8, 0);
    if (!next8am.isAfter(now)) {
      next8am = next8am.add(const Duration(days: 1));
    }

    // Convertir a UTC y envolver en TZDateTime para flutter_local_notifications
    final tzScheduled = tz.TZDateTime.from(next8am.toUtc(), tz.UTC);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Receta del día',
        channelDescription: 'Receta saludable diaria a las 8am',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: 'ic_notification',
      ),
    );

    try {
      await _plugin.zonedSchedule(
        _notifId, title, body, tzScheduled, details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      // SCHEDULE_EXACT_ALARM not granted — fall back to inexact scheduling.
      // The notification may arrive a few minutes late but will still fire.
      debugPrint('⚠️ Exact alarm not available ($e), falling back to inexact.');
      await _plugin.zonedSchedule(
        _notifId, title, body, tzScheduled, details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
