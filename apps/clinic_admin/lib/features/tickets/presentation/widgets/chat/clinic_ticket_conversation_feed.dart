import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_chat_helpers.dart';
import 'clinic_ticket_patient_bubble.dart';
import 'clinic_ticket_staff_bubble.dart';
import 'clinic_ticket_staff_note_card.dart';
import 'clinic_ticket_system_pill.dart';

class ClinicTicketConversationFeed extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;
  final ScrollController scrollController;

  const ClinicTicketConversationFeed({
    super.key,
    required this.ticket,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (ticket.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_chat_unread_outlined,
              size: 40,
              color: colors.textMuted,
            ),
            const SizedBox(height: 10),
            Text(
              'No conversation messages yet',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Use the quick macros or reply box below to communicate with the patient.',
              style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    final ticketSlaCountdown = ClinicTicketChatHelpers.formatSlaCountdown(
      ticket,
    );
    final isSlaOverdue = ticketSlaCountdown.contains('Overdue');

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      physics: const BouncingScrollPhysics(),
      itemCount: ticket.messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final msg = ticket.messages[index];
        final isStaff =
            msg.senderRole == 'clinic_admin' ||
            msg.senderRole == 'doctor' ||
            !msg.isUser;
        final timeDisplay = ClinicTicketChatHelpers.formatMessageTime(
          msg.createdAt,
          msg.time,
        );

        if (msg.senderRole == 'system') {
          String display = msg.text;
          if (display.toLowerCase().contains('escalated')) {
            if (!display.toLowerCase().contains('escalated from')) {
              final match = RegExp(
                r'by\s+([^for\.\n]+?)(?:\s+for|$|\.)',
                caseSensitive: false,
              ).firstMatch(display);
              final sender = match != null
                  ? match.group(1)!.trim()
                  : (ticket.clinicName.isNotEmpty
                        ? ticket.clinicName
                        : 'Clinic Admin');
              display = '🚨 Ticket escalated from $sender to Platform Admin.';
            }
          }
          return ClinicTicketSystemPill(
            text: display,
            timeDisplay: timeDisplay,
          );
        }

        if (msg.isInternalNote) {
          return ClinicTicketStaffNoteCard(
            message: msg,
            timeDisplay: timeDisplay,
          );
        }

        if (!isStaff) {
          final isLastPatientMsg =
              index ==
              ticket.messages.lastIndexWhere(
                (m) => m.isUser || m.senderRole == 'patient',
              );
          return ClinicTicketPatientBubble(
            ticket: ticket,
            message: msg,
            timeDisplay: timeDisplay,
            ticketSlaCountdown: ticketSlaCountdown,
            isSlaOverdue: isSlaOverdue,
            isLastPatientMsg: isLastPatientMsg,
          );
        }

        return ClinicTicketStaffBubble(message: msg, timeDisplay: timeDisplay);
      },
    );
  }
}
