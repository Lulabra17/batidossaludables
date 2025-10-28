import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:hive/hive.dart';


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
          title: '¡Recordatorio!',
          body: phraseRandom(),
          icon: 'ic_notification',
          iconColor: Colors.teal,
          stopButton: 'Detener'),
      volumeSettings: VolumeSettings.fixed(
      volume: 0.9,
      volumeEnforced: true,
    ));

    await Alarm.set(alarmSettings: alarmSettings);
    print('✅ Alarma $alarmId programada para $alarmTime');
  }
}

// Cargar y reprogramar alarmas almacenadas en Hive
Future<void> loadAndScheduleAlarms() async {
  var box = Hive.box('alarms');
  List<String>? alarmStrings = box.get('alarm_list')?.cast<String>();

  if (alarmStrings != null) {
    List<Duration> alarmTimes =
    alarmStrings.map((s) => Duration(minutes: int.parse(s))).toList();
    scheduleDailyAlarms(alarmTimes);
  }
}



// Lista de frases para los recordatorios
final List<String> phrases = [
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


// Función para obtener una frase aleatoria de la lista
String phraseRandom() {
  final random = Random();
  return phrases[random.nextInt(phrases.length)];
}


