import 'package:alarm/alarm.dart';
import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import '../alarms_functions.dart';

class ReminderWater extends StatefulWidget {
  const ReminderWater({super.key});

  @override
  State<ReminderWater> createState() => _ReminderWaterState();
}

class _ReminderWaterState extends State<ReminderWater> {
  var listAlarms = Hive.box('listAlarms');
  var box = Hive.box('alarms');
  final TextEditingController _weightController = TextEditingController();
  String _waterIntake = "";
  Duration wakeUpTime = Duration(hours: 7, minutes: 0);
  Duration getUpTime = Duration(hours: 21, minutes: 30);
  int reminderLength = 0;
  Duration reminderDuring = Duration(hours: 0, minutes: 0);
  double waterAmountLow = 0;
  double waterAmountHigh = 0;
  List<Duration> listReminders = [];


  // ── Colores de la app ──────────────────────────────────────
  static const _teal       = Color(0xFF2BBFAA);
  static const _tealDark   = Color(0xFF008776);
  static const _background = Color(0xFFE8E8DE);
  static const _dark       = Color(0xFF1A1A2E);

  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      if (!await Permission.notification.request().isGranted) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: context.l10n.notificationPermissionRequired,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.orange,
          );
        }
      }
    }
  }

  List<Duration> _generatorReminders() {
    int newReminderLength =
    ((waterAmountHigh / 255).toInt()).clamp(1, double.infinity).toInt();
    Duration newReminderDuring = Duration(
      minutes: ((timeActive(getUpTime, wakeUpTime) / newReminderLength)
          .toInt())
          .clamp(1, double.infinity)
          .toInt(),
    );

    List<Duration> newListReminders = [];
    for (int i = 0; i < newReminderLength; i++) {
      newListReminders.add(wakeUpTime + newReminderDuring * i);
    }

    setState(() {
      listReminders = newListReminders;
      reminderLength = newReminderLength;
      reminderDuring = newReminderDuring;
    });

    return listReminders;
  }

  String _calculateWaterIntake() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    waterAmountLow = weight * 30;
    waterAmountHigh = weight * 35;
    if (weight <= 0) {
      Fluttertoast.showToast(
        msg: context.l10n.invalidWeightError,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
      );
      return '';
    } else {
      setState(() {
        _waterIntake =
        '${waterAmountLow.toStringAsFixed(0)} – ${waterAmountHigh.toStringAsFixed(0)} ml';
      });
      return _waterIntake;
    }
  }

  void _showWakeUpTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: Colors.white,
        child: CupertinoTimerPicker(
          minuteInterval: 5,
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: wakeUpTime,
          onTimerDurationChanged: (duration) =>
              setState(() => wakeUpTime = duration),
        ),
      ),
    );
  }

  void _showGetUpTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: Colors.white,
        child: CupertinoTimerPicker(
          minuteInterval: 5,
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: getUpTime,
          onTimerDurationChanged: (duration) =>
              setState(() => getUpTime = duration),
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours.remainder(24))}:${twoDigits(duration.inMinutes.remainder(60))}";
  }

  int timeActive(Duration f, Duration i) {
    return ((f.inHours.remainder(24) * 60) + f.inMinutes.remainder(60)) -
        ((i.inHours.remainder(24) * 60) + i.inMinutes.remainder(60));
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }


  // ── Helpers de UI ──────────────────────────────────────────

  // Card de resultado (litros/ml)
  Widget _buildGoalCard() {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 122),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_tealDark, _teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.dailyGoalLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              _waterIntake.isEmpty
                  ? Text(
                l10n.enterWeightPrompt,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              )
                  : Text(
                _waterIntake,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (_waterIntake.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.perDayByWeight,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
          // Emoji decorativo
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.water_drop,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card de cálculo por peso
  Widget _buildInputCard() {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.calculateByWeightLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  cursorColor: _teal,
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: l10n.weightHint,
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _calculateWaterIntake,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dark,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.calculateButton,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card de rutina de recordatorios
  Widget _buildScheduleCard(List<String> myAlarms) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            l10n.reminderRoutineTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 14),

          // Horas
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showWakeUpTimePicker(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.wakeUpLabel,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDuration(wakeUpTime),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showGetUpTimePicker(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.sleepLabel,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDuration(getUpTime),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Info de frecuencia (solo si hay alarmas creadas)
          if (myAlarms.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7F5),
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active,
                      color: _teal, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.remindersCount(myAlarms.length),
                      style: const TextStyle(
                        fontSize: 12,
                        color: _teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Botón principal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final l10n = context.l10n;
                if (waterAmountHigh == 0) {
                  Fluttertoast.showToast(
                    msg: l10n.calculateWaterFirstError,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.red,
                  );
                } else if (getUpTime <= wakeUpTime) {
                  Fluttertoast.showToast(
                    msg: l10n.sleepAfterWakeError,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.red,
                  );
                } else {
                  List<Duration> newReminders = _generatorReminders();
                  scheduleDailyAlarms(newReminders);
                  List<String> formattedAlarms = newReminders
                      .map((r) => formatDuration(r))
                      .toList();
                  await listAlarms.put('Alarms', formattedAlarms);
                  setState(() {});
                }
              },
              icon: const Icon(Icons.notifications, size: 18),
              label: Text(
                l10n.activateReminders,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

          // Borrar — link de texto discreto
          if (myAlarms.isNotEmpty)
            Center(
              child: TextButton(
                onPressed: () async {
                  await listAlarms.clear();
                  await box.clear();
                  await Alarm.stopAll();
                  setState(() {});
                },
                child: Text(
                  l10n.deleteReminders,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Lista de alarmas programadas
  Widget _buildAlarmsList(List<String> myAlarms) {
    if (myAlarms.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            l10n.scheduledRemindersLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
              letterSpacing: 1,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: myAlarms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.water_drop, color: _teal, size: 18),
                ),
                title: Text(
                  l10n.drinkWaterAt(myAlarms[index]),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
                trailing: const Icon(Icons.alarm, color: _teal, size: 18),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> myAlarms =
    listAlarms.get('Alarms', defaultValue: <String>[]).cast<String>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _background,

      // ── AppBar ───────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.l10n.reminderScreenTitle,
          style: GoogleFonts.nunito(
            textStyle: const TextStyle(
              color: _dark,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalCard(),
            const SizedBox(height: 12),
            _buildInputCard(),
            const SizedBox(height: 12),
            _buildScheduleCard(myAlarms),
            const SizedBox(height: 16),
            _buildAlarmsList(myAlarms),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}