import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordStrengthBar extends StatelessWidget {
  final double strength;

  const PasswordStrengthBar({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    Color activeColor = const Color(0xFF1E293B);
    if (strength >= 0.8) {
      activeColor = const Color(0xFF10B981);
    } else if (strength >= 0.4) {
      activeColor = const Color(0xFFF59E0B);
    } else if (strength > 0) {
      activeColor = const Color(0xFFEF4444);
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
            backgroundColor: const Color(0xFF1E293B),
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Password strength',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
