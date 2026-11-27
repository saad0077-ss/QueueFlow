import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../utils/clinic_revenue_formatter.dart';
import 'clinic_revenue_area_painter.dart';

/// Interactive gradient area curve chart with hover/tap point inspection.
class ClinicRevenueAreaChart extends StatefulWidget {
  final List<DailyRevenuePoint> points;
  final int? activeIndex;
  final ValueChanged<int?> onActiveChanged;

  const ClinicRevenueAreaChart({
    super.key,
    required this.points,
    required this.activeIndex,
    required this.onActiveChanged,
  });

  @override
  State<ClinicRevenueAreaChart> createState() => _ClinicRevenueAreaChartState();
}

class _ClinicRevenueAreaChartState extends State<ClinicRevenueAreaChart> {
  static double _niceCeiling(double peak) {
    if (peak <= 0) return 1000;
    if (peak <= 400) return 400;
    if (peak <= 1000) return ((peak / 200).ceil() * 200).toDouble();
    final step = peak > 10000 ? 2000 : 500;
    return ((peak / step).ceil() * step).toDouble();
  }

  void _pickIndex(Offset pos, double width) {
    final n = widget.points.length;
    if (n < 2) return;
    final plotW =
        width - ClinicRevenueAreaPainter.leftPad - ClinicRevenueAreaPainter.rightPad;
    if (plotW <= 0) return;
    final step = plotW / (n - 1);
    final idx = ((pos.dx - ClinicRevenueAreaPainter.leftPad) / step)
        .round()
        .clamp(0, n - 1);
    if (idx != widget.activeIndex) widget.onActiveChanged(idx);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pts = widget.points;
    if (pts.length < 2) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, c) {
        final peak = pts.fold<double>(0, (m, p) => p.amount > m ? p.amount : m);
        final axisMax = _niceCeiling(peak);
        final active = widget.activeIndex;
        final tip = active != null && active < pts.length
            ? _buildTooltip(colors, pts[active], active, pts.length, axisMax, c)
            : null;

        return MouseRegion(
          onHover: (e) => _pickIndex(e.localPosition, c.maxWidth),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _pickIndex(d.localPosition, c.maxWidth),
            onHorizontalDragUpdate: (d) => _pickIndex(d.localPosition, c.maxWidth),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: ClinicRevenueAreaPainter(
                      points: pts,
                      axisMax: axisMax,
                      activeIndex: active,
                      gridColor: colors.borderSubtle,
                      axisColor: colors.border,
                      labelColor: colors.textMuted,
                      surfaceColor: colors.surface,
                      baseTextStyle: GoogleFonts.inter(),
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

  Widget _buildTooltip(AppColorsExtension colors, DailyRevenuePoint p, int idx, int total, double axisMax, BoxConstraints c) {
    final plotW = c.maxWidth - ClinicRevenueAreaPainter.leftPad - ClinicRevenueAreaPainter.rightPad;
    final plotH = c.maxHeight - ClinicRevenueAreaPainter.topPad - ClinicRevenueAreaPainter.bottomPad;
    final x = ClinicRevenueAreaPainter.leftPad + plotW * idx / (total - 1);
    final y = ClinicRevenueAreaPainter.topPad +
        plotH * (1 - (p.amount / axisMax).clamp(0.0, 1.0));
    const tipW = 112.0;
    final nearTop = y < 64;
    final left = nearTop
        ? (x > c.maxWidth * 0.55 ? x - tipW - 12 : x + 12)
        : (x - tipW / 2);
    final top = nearTop ? (y - 12) : (y - 48);

    return Positioned(
      left: left.clamp(0.0, (c.maxWidth - tipW).clamp(0.0, c.maxWidth)),
      top: top.clamp(0.0, (c.maxHeight - 44).clamp(0.0, c.maxHeight)),
      width: tipW,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF00D2FF).withValues(alpha: 0.45)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${p.label} • ${p.count} visit${p.count == 1 ? '' : 's'}',
                style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                ClinicRevenueFormatter.formatInr(p.amount),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
