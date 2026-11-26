import 'package:flutter/material.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import 'clinic_revenue_chart_canvas_helper.dart';

/// Paints a smooth cubic-spline gradient area chart with currency Y-axis ticks.
class ClinicRevenueAreaPainter extends CustomPainter {
  static const double leftPad = 48;
  static const double rightPad = 24;
  static const double topPad = 20;
  static const double bottomPad = 28;

  final List<DailyRevenuePoint> points;
  final double axisMax;
  final int? activeIndex;
  final Color gridColor;
  final Color axisColor;
  final Color labelColor;
  final Color surfaceColor;
  final TextStyle baseTextStyle;

  const ClinicRevenueAreaPainter({
    required this.points,
    required this.axisMax,
    required this.activeIndex,
    required this.gridColor,
    required this.axisColor,
    required this.labelColor,
    required this.surfaceColor,
    required this.baseTextStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final plotW = size.width - leftPad - rightPad;
    final plotH = size.height - topPad - bottomPad;
    if (plotW <= 0 || plotH <= 0) return;

    final safeMax = axisMax > 0 ? axisMax : 100.0;
    final baseY = topPad + plotH;
    final coords = [
      for (int i = 0; i < points.length; i++)
        Offset(
          leftPad + plotW * i / (points.length - 1),
          topPad + plotH * (1 - (points[i].amount / safeMax).clamp(0.0, 1.0)),
        ),
    ];

    ClinicRevenueChartCanvasHelper.drawGrid(
      canvas: canvas,
      size: size,
      leftPad: leftPad,
      rightPad: rightPad,
      topPad: topPad,
      plotH: plotH,
      safeMax: safeMax,
      axisColor: axisColor,
      gridColor: gridColor,
      labelColor: labelColor,
      baseTextStyle: baseTextStyle,
    );

    ClinicRevenueChartCanvasHelper.drawCurveAndFill(
      canvas: canvas,
      areaRect: Rect.fromLTWH(leftPad, topPad, plotW, plotH),
      coords: coords,
      baseY: baseY,
    );

    for (int i = 0; i < coords.length; i++) {
      final p = coords[i];
      final isActive = i == activeIndex;
      if (isActive) {
        canvas.drawLine(
          Offset(p.dx, topPad),
          Offset(p.dx, baseY),
          Paint()
            ..color = const Color(0xFF00D2FF).withValues(alpha: 0.4)
            ..strokeWidth = 1.2,
        );
        canvas.drawCircle(
          p,
          7,
          Paint()..color = const Color(0xFF00D2FF).withValues(alpha: 0.25),
        );
      }
      if (isActive || points[i].amount > 0) {
        canvas.drawCircle(p, isActive ? 4.5 : 3.2, Paint()..color = surfaceColor);
        canvas.drawCircle(
          p,
          isActive ? 3.2 : 2.2,
          Paint()..color = isActive ? const Color(0xFF00D2FF) : const Color(0xFF10B981),
        );
      }
      ClinicRevenueChartCanvasHelper.paintLabel(
        canvas: canvas,
        text: points[i].label,
        at: Offset(p.dx, baseY + 8),
        baseTextStyle: baseTextStyle,
        color: isActive ? const Color(0xFF00D2FF) : labelColor,
        bold: isActive,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ClinicRevenueAreaPainter old) =>
      old.points != points ||
      old.axisMax != axisMax ||
      old.activeIndex != activeIndex ||
      old.surfaceColor != surfaceColor;
}
