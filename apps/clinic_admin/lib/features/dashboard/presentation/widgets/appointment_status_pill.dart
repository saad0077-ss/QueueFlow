import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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
    final colors = context.colors;
    final bgColor = isCompleted
        ? colors.badgeOpenBg
        : colors.infoTint;
    final textColor = isCompleted
        ? colors.badgeOpenText
        : colors.info;

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
