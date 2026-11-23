import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_patient_avatar.dart';
import 'clinic_ticket_patient_sla_indicator.dart';

class ClinicTicketPatientBubble extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;
  final ClinicTicketMessage message;
  final String timeDisplay;
  final String ticketSlaCountdown;
  final bool isSlaOverdue;
  final bool isLastPatientMsg;

  const ClinicTicketPatientBubble({
    super.key,
    required this.ticket,
    required this.message,
    required this.timeDisplay,
    required this.ticketSlaCountdown,
    required this.isSlaOverdue,
    required this.isLastPatientMsg,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    final initials = message.sender.isNotEmpty
        ? message.sender
              .split(' ')
              .map((p) => p.isNotEmpty ? p[0] : '')
              .take(2)
              .join('')
              .toUpperCase()
        : 'PT';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClinicTicketPatientAvatar(
          photo: ticket.patientPhoto,
          initials: initials,
          patientId: ticket.patientId,
          patientEmail: ticket.patientEmail,
          patientPhone: ticket.patientPhone,
          patientName: ticket.patientName,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141F32) : colors.surfaceSecondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(
                color: isDark ? const Color(0xFF22354D) : colors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.sender,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                            : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'PATIENT',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message.text,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colors.textPrimary,
                    height: 1.45,
                  ),
                ),
                if (isLastPatientMsg &&
                    ticket.status.toLowerCase() != 'resolved') ...[
                  const SizedBox(height: 8),
                  ClinicTicketPatientSlaIndicator(
                    isSlaOverdue: isSlaOverdue,
                    ticketSlaCountdown: ticketSlaCountdown,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
