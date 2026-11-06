import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/dashboard_overview.dart';

/// Appointment volume for the last 7 days as a smooth gradient area chart with
/// hover tooltip and total / daily-average / peak summaries.
class AppointmentTrendCard extends StatelessWidget {
  final List<TrendPoint> data;

  const AppointmentTrendCard({super.key, this.data = const []});

  @override 
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = data.fold<int>(0, (s, d) => s + d.count);
    final peak = data.fold<int>(0, (m, d) => d.count > m ? d.count : m);
    final avg = data.isEmpty ? 0.0 : total / data.length;
    final peakDay = peak == 0
        ? '—' 
        : data.firstWhere((d) => d.count == peak).label;
 
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Appointment volume trend',
                style: GoogleFonts.inter(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                'Last 7 days',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _stat(colors, 'TOTAL', '$total'),
              _divider(colors),
              _stat(colors, 'DAILY AVG', avg.toStringAsFixed(1)),
              _divider(colors),
              _stat(colors, 'PEAK', peak == 0 ? '—' : '$peakDay · $peak'),
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(height: 190, child: _AreaChart(data: data)),

          if (total == 0) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(
                'No appointments in the last 7 days.',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider(AppColorsExtension colors) => Container(
    width: 1,
    height: 28,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: colors.border,
  );

  Widget _stat(AppColorsExtension colors, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AreaChart extends StatefulWidget {
  final List<TrendPoint> data;
  const _AreaChart({required this.data});

  @override
  State<_AreaChart> createState() => _AreaChartState();
}

class _AreaChartState extends State<_AreaChart> {
  int? _hover;

  static const double _left = 28;
  static const double _bottom = 24;
  static const double _top = 14;
  static const double _right = 12;

  void _update(Offset pos, double width) {
    final n = widget.data.length;
    if (n < 2) return;
    final plotW = width - _left - _right;
    final step = plotW / (n - 1);
    final i = ((pos.dx - _left) / step).round().clamp(0, n - 1);
    if (i != _hover) setState(() => _hover = i);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final data = widget.data;
    if (data.length < 2) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final height = c.maxHeight;
        final peak = data.fold<int>(0, (m, d) => d.count > m ? d.count : m);
        final axisMax = peak <= 4 ? 4 : ((peak + 3) ~/ 4) * 4;
        final plotW = width - _left - _right;
        final plotH = height - _top - _bottom;

        Offset pt(int i) => Offset(
          _left + plotW * i / (data.length - 1),
          _top + plotH * (1 - data[i].count / axisMax),
        );

        final h = _hover;
        Widget? tip;
        if (h != null) {
          final p = pt(h);
          const tipW = 96.0;
          final left = (p.dx - tipW / 2).clamp(0.0, width - tipW);
          tip = Positioned(
            left: left,
            top: (p.dy - 52).clamp(0.0, height),
            width: tipW,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data[h].isToday ? 'Today' : data[h].label,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: colors.textMuted,
                      ),
                    ),
                    Text(
                      '${data[h].count} appt${data[h].count == 1 ? '' : 's'}',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return MouseRegion(
          onHover: (e) => _update(e.localPosition, width),
          onExit: (_) => setState(() => _hover = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _update(d.localPosition, width),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AreaPainter(
                      data: data,
                      axisMax: axisMax,
                      hover: h,
                      line: colors.primary,
                      line2: colors.accent,
                      grid: colors.borderSubtle,
                      axis: colors.border,
                      text: colors.textMuted,
                      todayText: colors.primary,
                      surface: colors.surface,
                    ),
                  ),
                ),
                ?tip,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AreaPainter extends CustomPainter {
  final List<TrendPoint> data;
  final int axisMax;
  final int? hover;
  final Color line, line2, grid, axis, text, todayText, surface;

  _AreaPainter({
    required this.data,
    required this.axisMax,
    required this.hover,
    required this.line,
    required this.line2,
    required this.grid,
    required this.axis,
    required this.text,
    required this.todayText,
    required this.surface,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = _AreaChartState._left;
    const bottom = _AreaChartState._bottom;
    const top = _AreaChartState._top;
    const right = _AreaChartState._right;
    final plotW = size.width - left - right;
    final plotH = size.height - top - bottom;
    final n = data.length;

    Offset pt(int i) => Offset(
      left + plotW * i / (n - 1),
      top + plotH * (1 - data[i].count / axisMax),
    );

    void label(
      String s,
      Offset at, {
      bool center = true,
      bool bold = false,
      Color? color,
    }) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? text,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        center
            ? at - Offset(tp.width / 2, 0)
            : at - Offset(tp.width, tp.height / 2),
      );
    }

    // Grid lines + y labels
    for (var i = 0; i <= 4; i++) {
      final y = top + plotH * i / 4;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        Paint()
          ..color = i == 4 ? axis : grid
          ..strokeWidth = 1,
      );
      label(
        '${axisMax - axisMax * i ~/ 4}',
        Offset(left - 8, y),
        center: false,
      );
    }

    // X labels
    for (var i = 0; i < n; i++) {
      label(
        data[i].isToday ? 'Today' : data[i].label,
        Offset(pt(i).dx, size.height - bottom + 7),
        bold: data[i].isToday,
        color: data[i].isToday ? todayText : text,
      );
    }

    // Smooth curve
    final pts = [for (var i = 0; i < n; i++) pt(i)];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < n - 1; i++) {
      final mx = (pts[i].dx + pts[i + 1].dx) / 2;
      path.cubicTo(
        mx,
        pts[i].dy,
        mx,
        pts[i + 1].dy,
        pts[i + 1].dx,
        pts[i + 1].dy,
      );
    }

    // Gradient fill
    final fill = Path.from(path)
      ..lineTo(pts.last.dx, top + plotH)
      ..lineTo(pts.first.dx, top + plotH)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: 0.35), line2.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(left, top, plotW, plotH)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [line, line2],
        ).createShader(Rect.fromLTWH(left, top, plotW, plotH)),
    );

    // Hover guide
    if (hover != null) {
      final p = pts[hover!];
      canvas.drawLine(
        Offset(p.dx, top),
        Offset(p.dx, top + plotH),
        Paint()
          ..color = line.withValues(alpha: 0.4)
          ..strokeWidth = 1,
      );
    }

    // Dots
    for (var i = 0; i < n; i++) {
      final active = i == hover || data[i].isToday;
      canvas.drawCircle(pts[i], active ? 5.5 : 3.5, Paint()..color = surface);
      canvas.drawCircle(
        pts[i],
        active ? 4 : 2.5,
        Paint()..color = active ? line : line2,
      );
    }
  }

  @override
  bool shouldRepaint(_AreaPainter old) =>
      old.hover != hover || old.data != data || old.axisMax != axisMax;
}
