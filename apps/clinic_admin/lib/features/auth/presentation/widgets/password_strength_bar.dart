import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PasswordStrengthBar extends StatelessWidget {
  final double strength;

  const PasswordStrengthBar({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color activeColor = colors.border;
    if (strength >= 0.8) {
      activeColor = colors.success;
    } else if (strength >= 0.4) {
      activeColor = colors.warning;
    } else if (strength > 0) {
      activeColor = colors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength == 0 ? 1.0 : strength,
            minHeight: 3,
            backgroundColor: colors.border,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Password strength',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}
