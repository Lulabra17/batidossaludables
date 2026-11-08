import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final _plugin = FlutterLocalNotificationsPlugin();

const _channelId   = 'water_reminders_v3';
const _channelName = 'Recordatorios de agua';

// IDs basados en la hora: hora*100 + minuto + 2000
int _waterId(int hour, int minute) => hour * 100 + minute + 2000;

/// Inicializar el plugin. No usa MethodChannel aquí para evitar problemas
/// de timing con la Activity en startup. Las alarmas usan UTC explícito.
Future<void> initWaterNotifications() async {
  tz.initializeTimeZones();
  const androidInit = AndroidInitializationSettings('ic_notification');
  const initSettings = InitializationSettings(android: androidInit);
  await _plugin.initialize(initSettings);

  // Crear el canal explícitamente con el sonido personalizado.
  // Android fija el sonido al crear el canal — no al enviar la notificación.
  // Borramos versiones anteriores para asegurar sonido correcto.
  final ap = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await ap?.deleteNotificationChannel('water_reminders_v1');
  await ap?.deleteNotificationChannel('water_reminders_v2');
  await ap?.createNotificationChannel(
    const AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Recordatorios de hidratación diarios',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notif_batidos'),
    ),
  );
}

/// Verifica permiso de alarma exacta (Android 12+).
/// Devuelve true si está concedido.
/// Si no, abre la pantalla de ajustes y devuelve false.
Future<bool> ensureExactAlarmPermission() async {
  final ap = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (ap == null) return true;
  final ok = await ap.canScheduleExactNotifications();
  if (ok ?? true) return true;
  await ap.requestExactAlarmsPermission();
  return false;
}

/// Envía una notificación de prueba que llega en ~10 segundos.
Future<void> scheduleTestNotification() async {
  final spanish = _isSpanish();
  // Usamos UTC explícito: +10s desde ahora en UTC es correcto en cualquier timezone
  final now = DateTime.now().toUtc();
  final when = tz.TZDateTime.fromMillisecondsSinceEpoch(
    tz.UTC,
    now.add(const Duration(seconds: 10)).millisecondsSinceEpoch,
  );
  try {
    await _plugin.zonedSchedule(
      9999,
      spanish ? '🧪 Prueba de notificación' : '🧪 Notification test',
      spanish
          ? 'Las notificaciones funcionan correctamente ✓'
          : 'Water notifications are working correctly ✓',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Recordatorios de hidratación diarios',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
          sound: RawResourceAndroidNotificationSound('notif_batidos'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('✅ Notificación de prueba a las $when (UTC)');
  } catch (e) {
    debugPrint('⚠️ Prueba exacta falló ($e), intentando inexacta');
    try {
      await _plugin.zonedSchedule(
        9999,
        spanish ? '🧪 Prueba (modo inexacto)' : '🧪 Test (inexact)',
        spanish
            ? 'Notificación recibida (modo inexacto) ✓'
            : 'Notification received (inexact mode) ✓',
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
            sound: RawResourceAndroidNotificationSound('notif_batidos'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ Notificación de prueba (inexacta) programada');
    } catch (e2) {
      debugPrint('❌ Fallo total en prueba: $e2');
    }
  }
}

bool _isSpanish() {
  final saved = Hive.box('prefs').get('app_locale') as String?;
  if (saved != null) return saved == 'es';
  return PlatformDispatcher.instance.locale.languageCode == 'es';
}

/// Programa los recordatorios diarios de agua.
/// Estrategia UTC: DateTime local → toUtc() → TZDateTime en UTC.
/// matchDateTimeComponents:time con UTC dispara a la hora UTC equivalente
/// a la hora local elegida, correcto en cualquier zona horaria sin DST.
Future<void> scheduleDailyAlarms(List<Duration> alarmTimes) async {
  // 1. Cancelar recordatorios previos
  final rawPrev = Hive.box('alarms').get('alarm_list');
  if (rawPrev != null) {
    for (final s in List<String>.from(rawPrev as List)) {
      final d  = Duration(minutes: int.parse(s));
      final id = _waterId(d.inHours, d.inMinutes % 60);
      try { await _plugin.cancel(id); } catch (_) {}
    }
  }

  // 2. Guardar nueva lista en Hive
  await Hive.box('alarms').put(
    'alarm_list',
    alarmTimes.map((d) => d.inMinutes.toString()).toList(),
  );

  final now     = DateTime.now();          // tiempo local del dispositivo
  final spanish = _isSpanish();
  final phrases = spanish ? _phrasesEs : _phrasesEn;

  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Recordatorios de hidratación diarios',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    ),
  );

  for (final d in alarmTimes) {
    final hour   = d.inHours;
    final minute = d.inMinutes % 60;
    final id     = _waterId(hour, minute);

    // Próxima ocurrencia de esta hora LOCAL, nunca en el pasado
    var localWhen = DateTime(now.year, now.month, now.day, hour, minute);
    if (!localWhen.isAfter(now)) {
      localWhen = localWhen.add(const Duration(days: 1));
    }

    // Convertir a TZDateTime UTC — matchDateTimeComponents usa la hora UTC
    // para repetir diariamente, que es la hora local correcta (sin DST)
    final tzWhen = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.UTC,
      localWhen.toUtc().millisecondsSinceEpoch,
    );

    final body = phrases[id % phrases.length];
    debugPrint('📅 Alarma $hour:$minute → próxima: $localWhen (local) / $tzWhen (UTC)');

    // 3. Exacta con fallback a inexacta
    try {
      await _plugin.zonedSchedule(
        id,
        spanish ? '¡Recordatorio!' : 'Reminder!',
        body,
        tzWhen,
        details,
        payload: '$hour:$minute',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ $hour:$minute programada (exacta)');
    } catch (e) {
      debugPrint('⚠️ Exacta falló para $hour:$minute: $e → usando inexacta');
      try {
        await _plugin.zonedSchedule(
          id,
          spanish ? '¡Recordatorio!' : 'Reminder!',
          body,
          tzWhen,
          details,
          payload: '$hour:$minute',
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('✅ $hour:$minute programada (inexacta)');
      } catch (e2) {
        debugPrint('❌ Fallo total $hour:$minute: $e2');
      }
    }
  }
}

/// Carga alarmas guardadas en Hive y las reprograma al arrancar la app.
Future<void> loadAndScheduleAlarms() async {
  final raw = Hive.box('alarms').get('alarm_list');
  if (raw == null) return;
  try {
    final saved = List<String>.from(raw as List);
    if (saved.isEmpty) return;
    final times = saved.map((s) => Duration(minutes: int.parse(s))).toList();
    await scheduleDailyAlarms(times);
  } catch (_) {
    await Hive.box('alarms').delete('alarm_list');
  }
}

/// Cancela todos los recordatorios de agua activos.
Future<void> cancelAllWaterAlarms() async {
  final raw = Hive.box('alarms').get('alarm_list');
  if (raw == null) return;
  try {
    for (final s in List<String>.from(raw as List)) {
      final d  = Duration(minutes: int.parse(s));
      final id = _waterId(d.inHours, d.inMinutes % 60);
      try { await _plugin.cancel(id); } catch (_) {}
    }
  } catch (_) {}
}

// ── Frases ───────────────────────────────────────────────────────────────────

final _phrasesEs = [
  'Es hora de tomar tu vaso de agua.',
  '¡Hora de hidratarte! Toma un vaso de agua ahora.',
  'Tu cuerpo te lo agradecerá, bebe un vaso de agua.',
  'Pausa lo que haces y toma un vaso de agua fresca.',
  '¡Vamos! Un sorbo no basta, toma un vaso completo de agua.',
  'Mantente en forma, toma tu vaso de agua ahora.',
  '¡Recarga tu cuerpo! Es momento de beber un vaso de agua.',
  'Tu salud es primero, hidrátate con un vaso de agua.',
  '¡Tómate un break saludable! Bebe un vaso de agua.',
  'Dale a tu cuerpo lo que necesita: un buen vaso de agua.',
];

final _phrasesEn = [
  'Time to drink your glass of water.',
  'Time to hydrate! Drink a glass of water now.',
  'Your body will thank you, drink a glass of water.',
  'Take a break and drink a glass of fresh water.',
  'Come on! A sip is not enough, drink a full glass of water.',
  'Stay fit, drink your glass of water now.',
  'Recharge your body! It\'s time to drink a glass of water.',
  'Your health comes first, hydrate with a glass of water.',
  'Take a healthy break! Drink a glass of water.',
  'Give your body what it needs: a good glass of water.',
];

String phraseRandom() {
  final phrases = _isSpanish() ? _phrasesEs : _phrasesEn;
  return phrases[Random().nextInt(phrases.length)];
}
