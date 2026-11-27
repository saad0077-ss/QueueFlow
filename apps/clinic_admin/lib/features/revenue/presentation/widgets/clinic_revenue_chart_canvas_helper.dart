import 'package:flutter/material.dart';
import '../utils/clinic_revenue_formatter.dart';

/// Canvas drawing helpers for the Clinic Revenue spline area curve chart.
class ClinicRevenueChartCanvasHelper {
  ClinicRevenueChartCanvasHelper._();

  static void drawGrid({
    required Canvas canvas,
    required Size size,
    required double leftPad,
    required double rightPad,
    required double topPad,
    required double plotH,
    required double safeMax,
    required Color axisColor,
    required Color gridColor,
    required Color labelColor,
    required TextStyle baseTextStyle,
  }) {
    for (int i = 0; i <= 4; i++) {
      final y = topPad + plotH * i / 4;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        Paint()
          ..color = i == 4 ? axisColor : gridColor
          ..strokeWidth = 1,
      );
      paintLabel(
        canvas: canvas,
        text: ClinicRevenueFormatter.formatCompactInr(safeMax * (4 - i) / 4),
        at: Offset(leftPad - 8, y),
        baseTextStyle: baseTextStyle,
        color: labelColor,
        center: false,
      );
    }
  }

  static void drawCurveAndFill({
    required Canvas canvas,
    required Rect areaRect,
    required List<Offset> coords,
    required double baseY,
  }) {
    final linePath = Path()..moveTo(coords.first.dx, coords.first.dy);
    for (int i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }
    final areaPath = Path.from(linePath)
      ..lineTo(coords.last.dx, baseY)
      ..lineTo(coords.first.dx, baseY)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.28),
            const Color(0xFF00D2FF).withValues(alpha: 0.08),
            const Color(0xFF00D2FF).withValues(alpha: 0.0),
          ],
        ).createShader(areaRect),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF00D2FF)],
        ).createShader(areaRect),
    );
  }

  static void paintLabel({
    required Canvas canvas,
    required String text,
    required Offset at,
    required TextStyle baseTextStyle,
    required Color color,
    bool center = true,
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: baseTextStyle.copyWith(
          fontSize: 10,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      center ? at - Offset(tp.width / 2, 0) : at - Offset(tp.width, tp.height / 2),
    );
  }
}
