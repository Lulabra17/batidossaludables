import 'dart:math';
import 'dart:ui';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Detecta si el dispositivo usa español (funciona también en background sin BuildContext)
bool _isSpanish() =>
    PlatformDispatcher.instance.locale.languageCode == 'es';


// Configurar las alarmas desde la lista de recordatorios
Future<void> scheduleDailyAlarms(List<Duration> alarmTimes) async {
  var box = Hive.box('alarms');
  List<String> alarmStrings =
  alarmTimes.map((d) => d.inMinutes.toString()).toList();
  await box.put('alarm_list', alarmStrings);
  await Alarm.stopAll();

  for (int i = 0; i < alarmTimes.length; i++) {
    int alarmId = i + 1;
    Duration alarmDuration = alarmTimes[i];
    DateTime now = DateTime.now();
    DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarmDuration.inHours,
      alarmDuration.inMinutes % 60,
    );

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(Duration(days: 1));
    }

    // Configurar la alarma con la nueva dependencia
    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: alarmTime,
      assetAudioPath: 'assets/alarm_sound.mp3',
      loopAudio: false,
      vibrate: true,
      warningNotificationOnKill: false,
      androidFullScreenIntent: true,
      allowAlarmOverlap: true,
      notificationSettings: NotificationSettings(
          title: _isSpanish() ? '¡Recordatorio!' : 'Reminder!',
          body: phraseRandom(),
          icon: 'ic_notification',
          iconColor: Colors.teal,
          stopButton: _isSpanish() ? 'Detener' : 'Stop'),
      volumeSettings: VolumeSettings.fixed(
      volume: 0.9,
      volumeEnforced: true,
    ));

    try {
      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('✅ Alarma $alarmId programada para $alarmTime');
    } catch (e) {
      debugPrint('⚠️ No se pudo programar alarma $alarmId: $e');
    }
  }
}

// Cargar y reprogramar alarmas almacenadas en Hive
Future<void> loadAndScheduleAlarms() async {
  var box = Hive.box('alarms');
  List<String>? alarmStrings = box.get('alarm_list')?.cast<String>();

  if (alarmStrings != null) {
    List<Duration> alarmTimes =
    alarmStrings.map((s) => Duration(minutes: int.parse(s))).toList();
    await scheduleDailyAlarms(alarmTimes);
  }
}



// Frases para recordatorios según idioma
final List<String> _phrasesEs = [
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

final List<String> _phrasesEn = [
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

// Retorna una frase aleatoria en el idioma actual del dispositivo
String phraseRandom() {
  final phrases = _isSpanish() ? _phrasesEs : _phrasesEn;
  return phrases[Random().nextInt(phrases.length)];
}


