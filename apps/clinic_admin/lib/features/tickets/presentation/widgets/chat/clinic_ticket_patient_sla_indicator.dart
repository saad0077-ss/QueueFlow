import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicTicketPatientSlaIndicator extends StatelessWidget {
  final bool isSlaOverdue;
  final String ticketSlaCountdown;

  const ClinicTicketPatientSlaIndicator({
    super.key,
    required this.isSlaOverdue,
    required this.ticketSlaCountdown,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isSlaOverdue
            ? (isDark
                  ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                  : const Color(0xFFFEE2E2))
            : (isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                  : const Color(0xFFD1FAE5)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSlaOverdue ? Icons.warning_amber_rounded : Icons.schedule_rounded,
            size: 11,
            color: isSlaOverdue
                ? const Color(0xFFEF4444)
                : const Color(0xFF10B981),
          ),
          const SizedBox(width: 4),
          Text(
            isSlaOverdue
                ? 'SLA Breach: $ticketSlaCountdown'
                : 'Target SLA: $ticketSlaCountdown',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSlaOverdue
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
