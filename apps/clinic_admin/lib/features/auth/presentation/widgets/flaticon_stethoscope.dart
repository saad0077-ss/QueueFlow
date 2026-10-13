import 'package:flutter/material.dart';

class FlaticonStethoscopeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const FlaticonStethoscopeIcon({
    super.key,
    this.size = 22,
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
  _StethoscopePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.088
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.22, h * 0.14), w * 0.055, fillPaint);
    canvas.drawCircle(Offset(w * 0.54, h * 0.14), w * 0.055, fillPaint);

    final headPath = Path()
      ..moveTo(w * 0.22, h * 0.14)
      ..lineTo(w * 0.22, h * 0.36)
      ..arcToPoint(
        Offset(w * 0.54, h * 0.36),
        radius: Radius.circular(w * 0.16),
        clockwise: false,
      )
      ..lineTo(w * 0.54, h * 0.14);
    canvas.drawPath(headPath, strokePaint);

    final tubePath = Path()
      ..moveTo(w * 0.38, h * 0.52)
      ..lineTo(w * 0.38, h * 0.72)
      ..arcToPoint(
        Offset(w * 0.78, h * 0.72),
        radius: Radius.circular(w * 0.20),
        clockwise: false,
      )
      ..lineTo(w * 0.78, h * 0.52);
    canvas.drawPath(tubePath, strokePaint);

    final chestCenter = Offset(w * 0.78, h * 0.40);
    canvas.drawCircle(chestCenter, w * 0.11, strokePaint);
    canvas.drawCircle(chestCenter, w * 0.04, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
