import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/services/analytics_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

import '../alarms_functions.dart';
import 'water_glass_painter.dart';
import 'weight_ruler_picker.dart';

class ReminderWater extends StatefulWidget {
  const ReminderWater({super.key});

  @override
  State<ReminderWater> createState() => _ReminderWaterState();
}

class _ReminderWaterState extends State<ReminderWater>
    with TickerProviderStateMixin {
  // ── Tabs ────────────────────────────────────────────────────────
  late final TabController _tabCtrl;

  // ── Alarm state ──────────────────────────────────────────────────
  final _listAlarmsBox = Hive.box('listAlarms');
  final _alarmsBox = Hive.box('alarms');
  List<String> _myAlarms = [];

  // ── Setup form state ─────────────────────────────────────────────
  double _selectedWeight = 70.0;
  Duration wakeUpTime = const Duration(hours: 7);
  Duration getUpTime = const Duration(hours: 21, minutes: 30);
  double _waterAmountHigh = 0;
  bool _isEditing = false;

  // ── Water log state ──────────────────────────────────────────────
  final _prefsBox = Hive.box('prefs');
  int _todayMl = 0;
  int _goalMl = 2000;

  // ── Audio ────────────────────────────────────────────────────────
  final _audioPlayer = AudioPlayer();

  // ── Animations ───────────────────────────────────────────────────
  late final AnimationController _waveCtrl;
  late final AnimationController _btnPressCtrl;
  late final Animation<double> _btnScaleAnim;

  static const _gradientStart = Color(0xFF008776);
  static const _gradientEnd = Color(0xFF2BBFAA);

  // ── Lifecycle ────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _btnPressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 400),
    );
    _btnScaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _btnPressCtrl,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
    _tabCtrl.addListener(() {
      if (_tabCtrl.index == 2 && !_tabCtrl.indexIsChanging && _todayMl > 0) {
        _playWaterSound();
      }
    });
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _refreshAlarms();
    _loadWaterLog();
    requestNotificationPermission();

    // Cargar peso guardado y pre-calcular meta
    _selectedWeight = (_prefsBox.get('user_weight_kg') as double?) ?? 70.0;
    _waterAmountHigh = _selectedWeight * 35;
    if (_prefsBox.get('water_goal_ml') == null) {
      final count = (_waterAmountHigh / 250).toInt().clamp(1, 48);
      _goalMl = count * 250;
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _waveCtrl.dispose();
    _btnPressCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playWaterSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/agua.mp3'), volume: 0.6);
    } catch (_) {}
  }

  // ── Helpers ──────────────────────────────────────────────────────
  void _refreshAlarms() {
    _myAlarms = (_listAlarmsBox.get('Alarms', defaultValue: <String>[]) as List)
        .cast<String>();
  }

  void _loadWaterLog() {
    final today = _todayKey();
    final savedDate = _prefsBox.get('water_date') as String?;
    if (savedDate == today) {
      _todayMl = (_prefsBox.get('water_ml') as int?) ?? 0;
    } else {
      _todayMl = 0;
      _prefsBox.put('water_date', today);
      _prefsBox.put('water_ml', 0);
    }
    _goalMl = (_prefsBox.get('water_goal_ml') as int?) ?? 2000;
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  double get _fillLevel => (_todayMl / _goalMl).clamp(0.0, 1.0);

  void _logWater(int ml) {
    setState(() {
      _todayMl = (_todayMl + ml).clamp(0, _goalMl * 3);
    });
    _prefsBox.put('water_ml', _todayMl);
    _prefsBox.put('water_date', _todayKey());
    _playWaterSound();
  }

  void _resetDay() {
    setState(() => _todayMl = 0);
    _prefsBox.put('water_ml', 0);
    _prefsBox.put('water_date', _todayKey());
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
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

  List<Duration> _generateReminders() {
    final count = ((_waterAmountHigh / 250).toInt()).clamp(1, 48);
    final interval = Duration(
      minutes: ((timeActive(getUpTime, wakeUpTime) / count).toInt())
          .clamp(1, 1440),
    );
    return List.generate(count, (i) => wakeUpTime + interval * i);
  }

  void _calculateWaterIntakeFromWeight(double weight) {
    _waterAmountHigh = weight * 35;
    final count = (_waterAmountHigh / 250).toInt().clamp(1, 48);
    setState(() {
      _selectedWeight = weight;
      _goalMl = count * 250;
    });
  }

  int timeActive(Duration f, Duration i) =>
      (f.inHours.remainder(24) * 60 + f.inMinutes.remainder(60)) -
      (i.inHours.remainder(24) * 60 + i.inMinutes.remainder(60));

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours.remainder(24))}:${two(d.inMinutes.remainder(60))}';
  }

  String _reminderLabel(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final l10n = context.l10n;
    if (hour >= 5 && hour < 10) return l10n.reminderLabelMorning;
    if (hour >= 10 && hour < 12) return l10n.reminderLabelMidMorning;
    if (hour >= 12 && hour < 15) return l10n.reminderLabelMidday;
    if (hour >= 15 && hour < 19) return l10n.reminderLabelAfternoon;
    if (hour >= 19 && hour < 22) return l10n.reminderLabelEvening;
    return l10n.reminderLabelNight;
  }

  String _kimoTodayComment() {
    final l10n = context.l10n;
    if (_fillLevel == 0) return l10n.kimoComment0pct;
    if (_fillLevel < 0.25) return l10n.kimoComment25pct;
    if (_fillLevel < 0.50) return l10n.kimoComment50pct;
    if (_fillLevel < 1.0) return l10n.kimoComment75pct;
    return l10n.kimoComment100pct;
  }

  // ── Shared widgets ────────────────────────────────────────────────

  Widget _kimoWithBubble({
    required String imagePath,
    required String message,
    double imageSize = 90,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(imagePath, height: imageSize, fit: BoxFit.contain),
        const SizedBox(width: 12),
        Expanded(
          child: CustomPaint(
            painter: _ComicBubblePainter(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Text(
                message,
                style: GoogleFonts.nunito(
                  textStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTimePicker(
    BuildContext ctx,
    Duration initial,
    ValueChanged<Duration> onChanged,
  ) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Container(
        height: 250,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: CupertinoTimerPicker(
          minuteInterval: 5,
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: initial,
          onTimerDurationChanged: onChanged,
        ),
      ),
    );
  }

  Widget _timeTile({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
    final onSurf = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  fontSize: 10,
                  color: onSurf.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: onSurf,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 1: Setup ─────────────────────────────────────────────────

  Widget _buildSetupTab() {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurf = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final configured = _myAlarms.isNotEmpty && !_isEditing;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KIMO section
          _kimoWithBubble(
            imagePath: configured
                ? 'assets/images/kimo_agua_activo.png'
                : 'assets/images/kimo_agua_setup.png',
            message: configured
                ? l10n.kimoSetupConfigured
                : l10n.kimoSetupGuide,
            imageSize: 62,
          ),
          const SizedBox(height: 8),

          if (configured) ...[
            // ── Configured summary ───────────────────────────────
            _goalCard(),
            const SizedBox(height: 8),
            _summaryCard(l10n, primary, onSurf, surface),
            const SizedBox(height: 10),
            _pillButton(
              label: l10n.reconfigurarButton,
              icon: Icons.edit,
              color: primary,
              onTap: () => setState(() => _isEditing = true),
            ),
          ] else ...[
            // ── Form ─────────────────────────────────────────────
            _weightRulerCard(l10n, primary, onSurf, surface),
            const SizedBox(height: 8),
            _goalCard(),
            const SizedBox(height: 8),
            _scheduleFormCard(l10n, primary, onSurf, surface),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _goalCard() {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_gradientStart, _gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _gradientEnd.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyGoalLabel,
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _goalMl > 0 ? '$_goalMl ml' : '– ml',
                  style: GoogleFonts.nunito(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  l10n.perDayByWeight,
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
      AppLocalizations l10n, Color primary, Color onSurf, Color surface) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: primary, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.remindersCount(_myAlarms.length),
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    fontSize: 13,
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  label: l10n.wakeUpLabel,
                  value: formatDuration(wakeUpTime),
                  color: onSurf,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoTile(
                  label: l10n.sleepLabel,
                  value: formatDuration(getUpTime),
                  color: onSurf,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
      {required String label, required String value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _weightRulerCard(
      AppLocalizations l10n, Color primary, Color onSurf, Color surface) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEFF1);
    final rulerBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.calculateByWeightLabel,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: onSurf.withValues(alpha: 0.45),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          WeightRulerPicker(
            initialValue: _selectedWeight,
            onChanged: _calculateWaterIntakeFromWeight,
            rulerBackground: rulerBg,
          ),
        ],
      ),
    );
  }

  Widget _scheduleFormCard(
      AppLocalizations l10n, Color primary, Color onSurf, Color surface) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reminderRoutineTitle,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: onSurf,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _timeTile(
                  label: l10n.wakeUpLabel,
                  time: formatDuration(wakeUpTime),
                  onTap: () => _showTimePicker(
                    context,
                    wakeUpTime,
                    (d) => setState(() => wakeUpTime = d),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _timeTile(
                  label: l10n.sleepLabel,
                  time: formatDuration(getUpTime),
                  onTap: () => _showTimePicker(
                    context,
                    getUpTime,
                    (d) => setState(() => getUpTime = d),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (getUpTime <= wakeUpTime) {
                  Fluttertoast.showToast(
                    msg: l10n.sleepAfterWakeError,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.red,
                  );
                  return;
                }
                // Solicitar permiso de alarma exacta en segundo plano (Android 12+).
                // No bloqueamos el flujo — scheduleDailyAlarms tiene fallback a inexacta.
                await ensureExactAlarmPermission();
                try {
                  final reminders = _generateReminders();
                  await scheduleDailyAlarms(reminders);
                  final formatted =
                      reminders.map((r) => formatDuration(r)).toList();
                  await _listAlarmsBox.put('Alarms', formatted);
                  await _prefsBox.put('user_weight_kg', _selectedWeight);
                  // Meta = vasos programados × 250ml → 100% siempre alcanzable
                  await _prefsBox.put(
                      'water_goal_ml', reminders.length * 250);
                  final intervalMin = reminders.length > 1
                      ? (reminders[1] - reminders[0]).inMinutes
                      : 60;
                  setState(() {
                    _goalMl = reminders.length * 250;
                    _isEditing = false;
                    _refreshAlarms();
                  });
                  AnalyticsService.instance.logWaterReminderSet(
                    reminderCount: reminders.length,
                    intervalMinutes: intervalMin,
                  );
                  // Switch to reminders tab to show result
                  _tabCtrl.animateTo(1);
                } catch (e) {
                  debugPrint('⚠️ Error al programar recordatorios: $e');
                  Fluttertoast.showToast(
                    msg: 'Error al programar recordatorios',
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.red,
                  );
                }
              },
              icon: const Icon(Icons.notifications, size: 18),
              label: Text(
                l10n.activateReminders,
                style: GoogleFonts.nunito(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 2: Reminders ─────────────────────────────────────────────

  Widget _buildRemindersTab() {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurf = Theme.of(context).colorScheme.onSurface;

    if (_myAlarms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/kimo_agua_vacio.png',
                  height: 130),
              const SizedBox(height: 20),
              Text(
                l10n.noRemindersInfo,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    fontSize: 15,
                    color: onSurf.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _tabCtrl.animateTo(0),
                icon: const Icon(Icons.settings, size: 16),
                label: Text(
                  l10n.goToSetupButton,
                  style: GoogleFonts.nunito(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header chip
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_gradientStart, _gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.notifications_active,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.remindersCount(_myAlarms.length),
                  style: GoogleFonts.nunito(
                    textStyle: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await scheduleTestNotification();
                  Fluttertoast.showToast(
                    msg: '🧪 Notificación de prueba en ~10 segundos',
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.blueGrey,
                    toastLength: Toast.LENGTH_LONG,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.send, color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Test',
                        style: GoogleFonts.nunito(
                          textStyle: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Botones de acción ARRIBA de la lista ─────────────────
        Row(
          children: [
            Expanded(
              child: _pillButton(
                label: l10n.editReminderRoutine,
                icon: Icons.edit,
                color: primary,
                onTap: () => _tabCtrl.animateTo(0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _pillButton(
                label: l10n.deleteReminders,
                icon: Icons.delete_outline,
                color: Colors.red.shade600,
                onTap: () async {
                  await cancelAllWaterAlarms();
                  await _listAlarmsBox.clear();
                  await _alarmsBox.clear();
                  setState(() => _refreshAlarms());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Text(
          l10n.scheduledRemindersLabel,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: onSurf.withValues(alpha: 0.45),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Alarms list
        ...List.generate(_myAlarms.length, (i) {
          final timeStr = _myAlarms[i];
          final label = _reminderLabel(timeStr);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_gradientStart, _gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.water_drop,
                    color: Colors.white, size: 20),
              ),
              title: Text(
                timeStr,
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: onSurf,
                  ),
                ),
              ),
              subtitle: Text(
                label,
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    fontSize: 11,
                    color: onSurf.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing: Icon(Icons.alarm, color: primary, size: 18),
            ),
          );
        }),

        const SizedBox(height: 16),
      ],
    );
  }

  // ── TAB 3: Today ─────────────────────────────────────────────────

  Widget _buildTodayTab() {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurf = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (_fillLevel * 100).toInt();

    final kimoImage = _fillLevel >= 0.5
        ? 'assets/images/kimo_agua_hidratado.png'
        : 'assets/images/kimo_agua_sed.png';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // KIMO comment — compacto
          _kimoWithBubble(
            imagePath: kimoImage,
            message: _kimoTodayComment(),
            imageSize: 72,
          ),
          const SizedBox(height: 10),

          // Progress label
          Text(
            l10n.todayProgressTitle,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: onSurf.withValues(alpha: 0.45),
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Vaso + botón circular en Stack
          SizedBox(
            width: double.infinity,
            height: 290,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Vaso ocupa todo menos espacio del botón a la derecha
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _fillLevel),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (ctx, fill, _) {
                    return AnimatedBuilder(
                      animation: _waveCtrl,
                      builder: (_, __) => Positioned.fill(
                        right: 50,
                        child: CustomPaint(
                          painter: WaterGlassPainter(
                            fillLevel: fill,
                            wavePhase: _waveCtrl.value * 2 * pi,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Porcentaje centrado sobre el vaso
                Positioned.fill(
                  right: 50,
                  child: Center(
                    child: Text(
                      '$pct%',
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: _fillLevel > 0.45
                              ? Colors.white
                              : primary,
                          shadows: _fillLevel > 0.45
                              ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),

                // Botón circular +250 ml
                Positioned(
                  right: 0,
                  bottom: 30,
                  child: _circularAddButton(primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Contador ml
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_todayMl',
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: primary,
                    height: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4),
                child: Text(
                  ' / $_goalMl ml',
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: onSurf.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Reset
          TextButton.icon(
            onPressed: _resetDay,
            icon: const Icon(Icons.refresh, size: 14, color: Colors.red),
            label: Text(
              l10n.resetDayButton,
              style: GoogleFonts.nunito(
                textStyle: const TextStyle(
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

  Widget _pillButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 15),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circularAddButton(Color primary) {
    return AnimatedBuilder(
      animation: _btnScaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _btnScaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          _btnPressCtrl.value = 1.0; // salto instantáneo a 0.85
          _btnPressCtrl.reverse();   // rebote elástico de vuelta
        },
        onTapUp: (_) => _logWater(250),
        onTapCancel: () {},
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_gradientStart, _gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _gradientEnd.withValues(alpha: 0.5),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(
                '+250',
                style: GoogleFonts.nunito(
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              Text(
                'ml',
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg =
        isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarBg,
        title: Row(
          children: [
            Image.asset('assets/images/logo_batidos.png', height: 34),
            const SizedBox(width: 10),
            Text(
              l10n.reminderScreenTitle,
              style: GoogleFonts.nunito(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          indicatorColor: primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.nunito(
            textStyle: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700),
          ),
          unselectedLabelStyle: GoogleFonts.nunito(
            textStyle: const TextStyle(fontSize: 11),
          ),
          tabs: const [
            Tab(icon: Icon(Icons.tune, size: 22)),
            Tab(icon: Icon(Icons.notifications_outlined, size: 22)),
            Tab(icon: Icon(Icons.water_drop_outlined, size: 22)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildSetupTab(),
          _buildRemindersTab(),
          _buildTodayTab(),
        ],
      ),
    );
  }
}

// ── Comic speech bubble ───────────────────────────────────────────────────────

class _ComicBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const r = 14.0;      // border radius
    const tailW = 14.0;  // ancho de la cola
    const tailH = 12.0;  // alto de la cola
    const tailX = 10.0;  // posición X de la cola (desde la izquierda)

    final path = Path();
    // Esquina superior izquierda
    path.moveTo(tailX + tailW, 0);
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: const Radius.circular(r));
    // Lado derecho
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: const Radius.circular(r));
    // Lado inferior
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: const Radius.circular(r));
    // Lado izquierdo hasta la cola
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: const Radius.circular(r));
    path.lineTo(tailX, 0);
    // Cola hacia abajo-izquierda (apunta a KIMO)
    path.lineTo(tailX - tailW, -tailH);
    path.lineTo(tailX + tailW, 0);
    path.close();

    // Fondo blanco
    canvas.drawPath(path, Paint()..color = Colors.white);

    // Borde estilo cómic — teal oscuro, más fino
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF004D40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ComicBubblePainter _) => false;
}
