import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../data/repositories/clinic_support_repository.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_chat_top_bar.dart';
import 'clinic_ticket_conversation_feed.dart';
import 'clinic_ticket_macros_bar.dart';
import 'clinic_ticket_reply_input.dart';
import 'clinic_ticket_spotlight_card.dart';

class ClinicTicketChatConsole extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;
  final ClinicSupportRepository repository;
  final String staffName;
  final VoidCallback onNavigateToQueue;
  final VoidCallback? onBack;
  final ScrollController scrollController;
  final TextEditingController replyController;
  final bool isInternalNote;
  final ValueChanged<bool> onToggleMode;
  final ValueChanged<String> onSelectMacro;
  final VoidCallback onSend;

  const ClinicTicketChatConsole({
    super.key,
    required this.ticket,
    required this.repository,
    required this.staffName,
    required this.onNavigateToQueue,
    this.onBack,
    required this.scrollController,
    required this.replyController,
    required this.isInternalNote,
    required this.onToggleMode,
    required this.onSelectMacro,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final initials = ticket.patientName.isNotEmpty
        ? ticket.patientName
              .split(' ')
              .map((p) => p.isNotEmpty ? p[0] : '')
              .take(2)
              .join('')
              .toUpperCase()
        : 'PT';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          ClinicTicketChatTopBar(
            ticket: ticket,
            repository: repository,
            staffName: staffName,
            onBack: onBack,
          ),
          ClinicTicketSpotlightCard(
            ticket: ticket,
            initials: initials,
            onNavigateToQueue: onNavigateToQueue,
          ),
          Expanded(
            child: Container(
              color: colors.isDark
                  ? const Color(0xFF0B0F19)
                  : colors.surfaceSecondary,
              child: ClinicTicketConversationFeed(
                ticket: ticket,
                scrollController: scrollController,
              ),
            ),
          ),
          if (!isResolved) ClinicTicketMacrosBar(onSelectMacro: onSelectMacro),
          ClinicTicketReplyInput(
            controller: replyController,
            isNote: isInternalNote,
            isClosed: isResolved,
            onToggleMode: onToggleMode,
            onSend: onSend,
          ),
        ],
      ),
    );
  }
}
