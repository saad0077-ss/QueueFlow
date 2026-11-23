import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import '../chat/platform_ticket_patient_avatar.dart';
import 'platform_ticket_card_style_helper.dart';

class PlatformTicketCardPatientRow extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;
  final String initials;

  const PlatformTicketCardPatientRow({
    super.key,
    required this.ticket,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final countdownStr = PlatformTicketCardStyleHelper.formatSlaCountdown(
      ticket,
    );
    final isOverdue = countdownStr.contains('Overdue');
    final prio = ticket.priority.toLowerCase();
    final isUrgentOrHigh =
        prio == 'high' || prio == 'urgent' || ticket.slaMinutes < 15;
    final isResolved = ticket.status.toLowerCase() == 'resolved';

    final displaySlaColor = isResolved
        ? (isDark ? const Color(0xFF10B981) : const Color(0xFF059669))
        : (isOverdue
              ? (isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626))
              : (isUrgentOrHigh
                    ? (isDark
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFD97706))
                    : (isDark
                          ? const Color(0xFF10B981)
                          : const Color(0xFF059669))));
    final displaySlaBg = isResolved
        ? (isDark
              ? const Color(0xFF064E3B).withValues(alpha: 0.35)
              : const Color(0xFFD1FAE5))
        : (isOverdue
              ? (isDark
                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.45)
                    : const Color(0xFFFEE2E2))
              : (isUrgentOrHigh
                    ? (isDark
                          ? const Color(0xFF78350F).withValues(alpha: 0.4)
                          : const Color(0xFFFEF3C7))
                    : (isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                          : const Color(0xFFD1FAE5))));

    return Row(
      children: [
        PlatformTicketPatientAvatar(
          initials: initials,
          photo: ticket.patientPhoto,
          patientId: ticket.patientId,
          patientEmail: ticket.patientEmail,
          patientPhone: ticket.patientPhone,
          patientName: ticket.patientName,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticket.patientName,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (ticket.patientPhone.isNotEmpty)
                Text(
                  ticket.patientPhone,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: displaySlaBg,
            borderRadius: BorderRadius.circular(4),
            border: isOverdue
                ? Border.all(
                    color:
                        (isDark
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFDC2626))
                            .withValues(alpha: 0.4),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOverdue
                    ? Icons.warning_amber_rounded
                    : Icons.schedule_rounded,
                size: 10,
                color: displaySlaColor,
              ),
              const SizedBox(width: 3),
              Text(
                countdownStr,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: displaySlaColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
