import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightRulerPicker extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color? rulerBackground;

  const WeightRulerPicker({
    super.key,
    required this.initialValue,
    this.min = 30,
    this.max = 200,
    required this.onChanged,
    this.rulerBackground,
  });

  @override
  State<WeightRulerPicker> createState() => _WeightRulerPickerState();
}

class _WeightRulerPickerState extends State<WeightRulerPicker> {
  late ScrollController _ctrl;
  static const _pxPerKg = 20.0;
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.min, widget.max);
    _ctrl = ScrollController(
      initialScrollOffset: (_currentValue - widget.min) * _pxPerKg,
    );
    _ctrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_ctrl.hasClients) return;
    final raw = widget.min + _ctrl.offset / _pxPerKg;
    final kg = raw.clamp(widget.min, widget.max).roundToDouble();
    if (kg != _currentValue) {
      HapticFeedback.selectionClick();
      setState(() => _currentValue = kg);
      widget.onChanged(kg);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onScroll);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rulerBg = widget.rulerBackground ?? Theme.of(context).colorScheme.surface;

    return Column(
      children: [
        // ── Valor del peso ────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _currentValue.toStringAsFixed(1),
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
              padding: const EdgeInsets.only(bottom: 5, left: 5),
              child: Text(
                'kg',
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primary.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Regla ────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: rulerBg,
            height: 56,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final halfW = constraints.maxWidth / 2;
                final totalW =
                    (widget.max - widget.min) * _pxPerKg + constraints.maxWidth;

                return Stack(
                  children: [
                    // Regla desplazable
                    SingleChildScrollView(
                      controller: _ctrl,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: totalW,
                        height: 56,
                        child: CustomPaint(
                          size: Size(totalW, 56),
                          painter: _RulerPainter(
                            min: widget.min,
                            max: widget.max,
                            pxPerKg: _pxPerKg,
                            halfWidth: halfW,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),

                    // Fade izquierdo
                    IgnorePointer(
                      child: Container(
                        width: halfW * 0.45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [rulerBg, rulerBg.withValues(alpha: 0)],
                          ),
                        ),
                      ),
                    ),

                    // Fade derecho
                    IgnorePointer(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: halfW * 0.45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [rulerBg.withValues(alpha: 0), rulerBg],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Indicador central
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomPaint(
                            painter: _TrianglePainter(color: primary),
                            size: const Size(10, 7),
                          ),
                          Container(
                            width: 2,
                            height: 44,
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Painter de la regla ───────────────────────────────────────────────────────

class _RulerPainter extends CustomPainter {
  final double min, max, pxPerKg, halfWidth;
  final bool isDark;

  const _RulerPainter({
    required this.min,
    required this.max,
    required this.pxPerKg,
    required this.halfWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height * 0.60;
    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (double kg = min; kg <= max; kg++) {
      final x = halfWidth + (kg - min) * pxPerKg;
      final isMajor = kg % 10 == 0;
      final isMedium = kg % 5 == 0 && !isMajor;

      tickPaint
        ..color = (isDark ? Colors.white : Colors.black87).withValues(
          alpha: isMajor ? 0.70 : (isMedium ? 0.40 : 0.20),
        )
        ..strokeWidth = isMajor ? 2.0 : (isMedium ? 1.5 : 1.0);

      canvas.drawLine(
        Offset(x, baseY - (isMajor ? 28.0 : (isMedium ? 18.0 : 10.0))),
        Offset(x, baseY),
        tickPaint,
      );

      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(
            text: kg.toInt().toString(),
            style: TextStyle(
              fontSize: 10,
              color: (isDark ? Colors.white : Colors.black87)
                  .withValues(alpha: 0.50),
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, baseY + 5));
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) =>
      old.isDark != isDark || old.min != min;
}

// ── Painter del triángulo indicador ──────────────────────────────────────────

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
