import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_audit_memo_card.dart';
import 'platform_ticket_chat_helpers.dart';
import 'platform_ticket_patient_bubble.dart';
import 'platform_ticket_staff_bubble.dart';
import 'platform_ticket_system_pill.dart';

class PlatformTicketConversationFeed extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;
  final ScrollController scrollController;
  final ImageProvider? avatarProvider;

  const PlatformTicketConversationFeed({
    super.key,
    required this.ticket,
    required this.scrollController,
    this.avatarProvider,
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
              'Send a public broadcast response or log an internal platform audit memo.',
              style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    final ticketSlaCountdown = PlatformTicketChatHelpers.formatSlaCountdown(
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
        final isMemo = msg.isInternalNote;
        final isStaff =
            msg.senderRole == 'platform_owner' ||
            msg.senderRole == 'clinic_admin' ||
            msg.senderRole == 'doctor' ||
            !msg.isUser;
        final timeDisplay = PlatformTicketChatHelpers.formatMessageTime(
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
          return PlatformTicketSystemPill(
            text: display,
            timeDisplay: timeDisplay,
          );
        }

        if (isMemo) {
          return PlatformTicketAuditMemoCard(
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
          return PlatformTicketPatientBubble(
            ticket: ticket,
            message: msg,
            timeDisplay: timeDisplay,
            ticketSlaCountdown: ticketSlaCountdown,
            isSlaOverdue: isSlaOverdue,
            isLastPatientMsg: isLastPatientMsg,
            avatarProvider: avatarProvider,
          );
        }

        return PlatformTicketStaffBubble(
          message: msg,
          timeDisplay: timeDisplay,
        );
      },
    );
  }
}
