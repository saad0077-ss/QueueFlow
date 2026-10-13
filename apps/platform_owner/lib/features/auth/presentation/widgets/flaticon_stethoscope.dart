import 'package:flutter/material.dart';

/// Vector Flaticon Medical Stethoscope Icon Widget
class FlaticonStethoscope extends StatelessWidget {
  final double size;
  final Color color;

  const FlaticonStethoscope({
    super.key,
    this.size = 38,
    this.color = const Color(0xFF2563EB),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StethoscopePainter(color: color),
    );
  }
}

class _StethoscopePainter extends CustomPainter {
  final Color color;

  const _StethoscopePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.082;

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final leftTip = Offset(w * 0.22, h * 0.16);
    final rightTip = Offset(w * 0.44, h * 0.16);

    canvas.drawCircle(leftTip, strokeWidth * 0.65, dotPaint);
    canvas.drawCircle(rightTip, strokeWidth * 0.65, dotPaint);

    final uPath = Path()
      ..moveTo(leftTip.dx, leftTip.dy)
      ..lineTo(leftTip.dx, h * 0.34)
      ..quadraticBezierTo(w * 0.33, h * 0.48, rightTip.dx, h * 0.34)
      ..lineTo(rightTip.dx, rightTip.dy);
    canvas.drawPath(uPath, strokePaint);

    final tubePath = Path()
      ..moveTo(w * 0.33, h * 0.45)
      ..cubicTo(
        w * 0.33,
        h * 0.72,
        w * 0.48,
        h * 0.88,
        w * 0.64,
        h * 0.72,
      )
      ..quadraticBezierTo(w * 0.72, h * 0.60, w * 0.76, h * 0.46);
    canvas.drawPath(tubePath, strokePaint);

    final diaphragmCenter = Offset(w * 0.78, h * 0.38);
    canvas.drawCircle(diaphragmCenter, w * 0.12, strokePaint);
    canvas.drawCircle(diaphragmCenter, strokeWidth * 0.45, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _StethoscopePainter oldDelegate) =>
      oldDelegate.color != color;
}
