import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Shared colours and building blocks for the services screens.
class ServiceColors {
  ServiceColors._();

  static const surface = Color(0xFF111A2E);
  static const field = Color(0xFF0B1324);
  static const border = Color(0xFF1E293B);
  static const fieldBorder = Color(0xFF26334D);
  static const focus = Color(0xFF38BDF8);
  static const muted = Color(0xFF94A3B8);
  static const subtle = Color(0xFF64748B);
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF22C55E);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);

  static const gradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Dynamic filled input decoration used by every field in the service dialog.
InputDecoration serviceInputDecoration({
  BuildContext? context,
  String? hint,
  String? errorText,
}) {
  final colors = context?.colors;
  final fillColor = colors?.surfaceSecondary ?? ServiceColors.field;
  final borderColor = colors?.border ?? ServiceColors.fieldBorder;
  final hintColor = colors?.textMuted ?? ServiceColors.subtle;
  final focusColor = colors?.primary ?? ServiceColors.focus;
  final errorColor = colors?.error ?? ServiceColors.red;

  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(fontSize: 13, color: hintColor),
    errorText: errorText,
    errorStyle: GoogleFonts.inter(fontSize: 11, color: errorColor),
    filled: true,
    fillColor: fillColor,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: border(borderColor),
    focusedBorder: border(focusColor, 1.5),
    errorBorder: border(errorColor),
    focusedErrorBorder: border(errorColor, 1.5),
    border: border(borderColor),
  );
}

/// A bold label sitting above its field.
class ServiceLabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const ServiceLabeledField({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Blue-to-teal pill button with a soft glow.
class ServiceGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const ServiceGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 46,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: ServiceColors.gradient,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Container(
              height: height,
              padding: padding,
              alignment: Alignment.center,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined pill button (Cancel, Edit, Deactivate, Upgrade...).
class ServiceOutlinedPill extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final Color? fill;
  final double height;
  final double fontSize;

  const ServiceOutlinedPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.fill,
    this.height = 38,
    this.fontSize = 12.5,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bColor = borderColor ?? colors.border;
    final tColor = textColor ?? colors.textPrimary;
    final fColor = fill ?? Colors.transparent;

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: fColor,
          side: BorderSide(color: bColor, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: tColor,
          ),
        ),
      ),
    );
  }
}

/// Paints a dashed rounded-rectangle border around [child].
class DashedBorderBox extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;

  const DashedBorderBox({
    super.key,
    required this.child,
    this.color,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final boxColor = color ?? context.colors.border;
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(color: boxColor, radius: radius),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 6.0;
    const gap = 5.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
