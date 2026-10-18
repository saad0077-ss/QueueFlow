import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Status pill badge shown for appointments (e.g. COMPLETED, RESCHEDULED, CHECKEDIN).
class AppointmentStatusPill extends StatelessWidget {
  final String status;
  final bool isCompleted;

  const AppointmentStatusPill({
    super.key,
    required this.status,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isCompleted
        ? const Color(0xFF064E3B)
        : const Color(0xFF172554);
    final textColor = isCompleted
        ? const Color(0xFF34D399)
        : const Color(0xFF38BDF8);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3.5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
