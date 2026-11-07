import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Shared colors and building blocks for the Doctors & Availability screen.
class DoctorColors {
  DoctorColors._();

  static const primary = Color(0xFF2563EB);
  static const surface = Color(0xFF111A2E);
  static const surfaceElevated = Color(0xFF1E293B);
  static const field = Color(0xFF0B1324);
  static const border = Color(0xFF1E293B);
  static const fieldBorder = Color(0xFF26334D);
  static const focus = Color(0xFF38BDF8);
  static const muted = Color(0xFF94A3B8);
  static const subtle = Color(0xFF64748B);
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFEAB308);
  static const red = Color(0xFFEF4444);
  static const danger = Color(0xFFEF4444);
  static const cyan = Color(0xFF38BDF8);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Dynamic input decoration for dialog input fields.
InputDecoration doctorInputDecoration({
  BuildContext? context,
  String? hint,
  String? errorText,
  IconData? prefixIcon,
  String? suffixText,
}) {
  final colors = context?.colors;
  final fillColor = colors?.surfaceSecondary ?? DoctorColors.field;
  final borderColor = colors?.border ?? DoctorColors.fieldBorder;
  final hintColor = colors?.textMuted ?? DoctorColors.subtle;
  final focusColor = colors?.primary ?? DoctorColors.focus;
  final errorColor = colors?.error ?? DoctorColors.red;

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
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 17, color: hintColor),
    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
    suffixText: suffixText,
    suffixStyle: GoogleFonts.inter(fontSize: 12, color: hintColor),
    filled: true,
    fillColor: fillColor,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: border(borderColor),
    focusedBorder: border(focusColor, 1.5),
    errorBorder: border(errorColor),
    focusedErrorBorder: border(errorColor, 1.5),
    border: border(borderColor),
  );
}

/// Doctor avatar: shows the uploaded photo (data URI or network URL) and falls
/// back to the initials.
class DoctorAvatar extends StatefulWidget {
  final String photoUrl;
  final String initials;
  final double size;
  final double radius;
  final double fontSize;

  const DoctorAvatar({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.size = 48,
    this.radius = 14,
    this.fontSize = 15,
  });

  @override
  State<DoctorAvatar> createState() => _DoctorAvatarState();
}

class _DoctorAvatarState extends State<DoctorAvatar> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = _decode(widget.photoUrl);
  }

  @override
  void didUpdateWidget(covariant DoctorAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl) {
      _bytes = _decode(widget.photoUrl);
    }
  }

  static Uint8List? _decode(String url) {
    if (!url.startsWith('data:image')) return null;
    final comma = url.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(url.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = Text(
      widget.initials,
      style: GoogleFonts.inter(
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w800,
        color: colors.primary,
      ),
    );

    Widget? photo;
    if (_bytes != null) {
      photo = Image.memory(
        _bytes!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => initials,
      );
    } else if (widget.photoUrl.startsWith('http')) {
      photo = Image.network(
        widget.photoUrl,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => initials,
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // Only tint behind initials; a photo fills the whole container.
        color: photo == null ? colors.surfaceSecondary : null,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      // Border painted over the photo so it doesn't inset the image.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: colors.border),
      ),
      child: photo ?? initials,
    );
  }
}

/// A bold label positioned cleanly above its input field.
class DoctorLabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const DoctorLabeledField({
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

/// Gradient pill button with subtle rounded corners and shadow.
class DoctorGradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const DoctorGradientButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.height = 42,
    this.fontSize = 13.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: DoctorColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            height: height,
            padding: padding,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
