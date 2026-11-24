import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double? width;
  final double? maxWidth;
  final double height;
  final AlignmentGeometry alignment;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.width,
    this.maxWidth = 380,
    this.height = 52,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final buttonWidget = Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Image.asset(
                  'assets/images/google_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const GoogleLogoVector(size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Continue with Google',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (maxWidth != null) {
      return Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth!,
            minHeight: height,
          ),
          child: buttonWidget,
        ),
      );
    }

    return buttonWidget;
  }
}

class GoogleLogoVector extends StatelessWidget {
  final double size;

  const GoogleLogoVector({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final r = size.width / 2;
    final center = Offset(r, r);

    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.14159 * 1.25,
      3.14159 * 0.5,
      true,
      paint,
    );

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.14159 * 0.75,
      3.14159 * 0.5,
      true,
      paint,
    );

    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.14159 * 0.25,
      3.14159 * 0.5,
      true,
      paint,
    );

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -3.14159 * 0.25,
      3.14159 * 0.5,
      true,
      paint,
    );

    // Inner cutout to form the G
    paint.color = const Color(0xFF132545);
    canvas.drawCircle(center, r * 0.55, paint);

    // Horizontal bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - r * 0.18, r, r * 0.36),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
