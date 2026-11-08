import 'dart:math';
import 'package:flutter/material.dart';

class WaterGlassPainter extends CustomPainter {
  final double fillLevel;    // 0.0 → 1.0
  final double wavePhase;    // 0.0 → 2*pi, animated
  final bool isDark;

  const WaterGlassPainter({
    required this.fillLevel,
    required this.wavePhase,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = fillLevel.clamp(0.0, 1.0);

    // ── Glass silhouette (trapezoid, slightly rounded bottom) ────
    final tL = w * 0.06;   // top-left x
    final tR = w * 0.94;   // top-right x
    final bL = w * 0.14;   // bottom-left x
    final bR = w * 0.86;   // bottom-right x
    final top = h * 0.02;
    final bot = h * 0.96;
    final rimY = top + h * 0.045;

    final glassPath = Path()
      ..moveTo(tL, top)
      ..lineTo(tR, top)
      ..lineTo(bR, bot - 12)
      ..quadraticBezierTo(bR, bot, bR - 8, bot)
      ..lineTo(bL + 8, bot)
      ..quadraticBezierTo(bL, bot, bL, bot - 12)
      ..lineTo(tL, top)
      ..close();

    // ── Water fill ───────────────────────────────────────────────
    if (fill > 0.001) {
      canvas.save();
      canvas.clipPath(glassPath);

      final waterTop = top + (bot - top) * (1.0 - fill);
      final waveAmp = fill > 0.97 ? 2.0 : 7.0;

      final waterPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF4DD0E1), Color(0xFF0277BD)],
        ).createShader(Rect.fromLTWH(0, waterTop, w, h - waterTop));

      final wavePath = Path()..moveTo(0, h);
      wavePath.lineTo(0, waterTop + waveAmp);
      for (double x = 0; x <= w; x++) {
        final y = waterTop +
            sin((x / w * 2 * pi * 2.5) + wavePhase) * waveAmp +
            sin((x / w * pi) + wavePhase * 0.6) * (waveAmp * 0.4);
        wavePath.lineTo(x, y);
      }
      wavePath.lineTo(w, h);
      wavePath.close();
      canvas.drawPath(wavePath, waterPaint);

      // Bubbles inside water
      if (fill < 0.98) {
        final bubblePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..style = PaintingStyle.fill;
        final bubblePositions = [
          (0.28, 0.75), (0.55, 0.45), (0.70, 0.80), (0.42, 0.60),
        ];
        for (int i = 0; i < bubblePositions.length; i++) {
          final (bxFrac, byFrac) = bubblePositions[i];
          final phase = ((wavePhase / (2 * pi)) + i * 0.25) % 1.0;
          final bx = tL + (tR - tL) * bxFrac;
          final waterHeight = bot - waterTop;
          final by = waterTop + waterHeight * byFrac * (1.0 - phase * 0.5);
          if (by > waterTop + 4 && by < bot - 8) {
            canvas.drawCircle(Offset(bx, by), 2.5 + i * 0.4, bubblePaint);
          }
        }
      }

      canvas.restore();
    }

    // ── Glass body overlay ────────────────────────────────────────
    // En light mode: tinte azul visible. En dark: más sutil.
    final tintColor = isDark
        ? const Color(0xFFB3E5FC).withValues(alpha: 0.06)
        : const Color(0xFF4DD0E1).withValues(alpha: 0.10);
    canvas.drawPath(glassPath, Paint()..color = tintColor);

    // ── Rim ───────────────────────────────────────────────────────
    final rimColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFF4DD0E1).withValues(alpha: 0.25);
    final rimPath = Path()
      ..moveTo(tL - 4, top)
      ..lineTo(tR + 4, top)
      ..lineTo(tR, rimY)
      ..lineTo(tL, rimY)
      ..close();
    canvas.drawPath(rimPath, Paint()..color = rimColor);

    // ── Glass border ──────────────────────────────────────────────
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : const Color(0xFF00ACC1).withValues(alpha: 0.70);
    canvas.drawPath(
      glassPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    // Rim accent line
    canvas.drawLine(
      Offset(tL - 5, top),
      Offset(tR + 5, top),
      Paint()
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.60)
            : const Color(0xFF00ACC1).withValues(alpha: 0.80)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round,
    );

    // ── Highlights ────────────────────────────────────────────────
    final hlColor1 = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.70);
    final hlColor2 = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.45);

    canvas.drawPath(
      Path()
        ..moveTo(tL + 7, top + 10)
        ..lineTo(tL + 18, top + 10)
        ..lineTo(bL + 11, bot * 0.72)
        ..lineTo(bL + 2, bot * 0.72)
        ..close(),
      Paint()..color = hlColor1,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tL + 22, top + 14)
        ..lineTo(tL + 29, top + 14)
        ..lineTo(bL + 18, bot * 0.52)
        ..lineTo(bL + 12, bot * 0.52)
        ..close(),
      Paint()..color = hlColor2,
    );
  }

  @override
  bool shouldRepaint(WaterGlassPainter old) =>
      old.fillLevel != fillLevel ||
      old.wavePhase != wavePhase ||
      old.isDark != isDark;
}
