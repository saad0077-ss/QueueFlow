import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../data/models/platform_support_ticket_model.dart';
import '../../../domain/repositories/platform_support_repository.dart';
import 'platform_ticket_chat_top_bar.dart';
import 'platform_ticket_conversation_feed.dart';
import 'platform_ticket_macros_bar.dart';
import 'platform_ticket_reply_input.dart';
import 'platform_ticket_spotlight_card.dart';

class PlatformTicketChatConsoleBody extends StatelessWidget {
  final PlatformSupportTicketModel ticket;
  final PlatformSupportRepository repository;
  final VoidCallback? onBack;
  final VoidCallback onDelete;
  final ScrollController scrollController;
  final TextEditingController replyController;
  final bool isInternalNote;
  final bool isSending;
  final ValueChanged<String> onSelectMacro;
  final ValueChanged<bool> onToggleMode;
  final VoidCallback onSend;

  const PlatformTicketChatConsoleBody({
    super.key,
    required this.ticket,
    required this.repository,
    this.onBack,
    required this.onDelete,
    required this.scrollController,
    required this.replyController,
    required this.isInternalNote,
    required this.isSending,
    required this.onSelectMacro,
    required this.onToggleMode,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlatformTicketChatTopBar(
            ticket: ticket,
            repository: repository,
            onBack: onBack,
            onDelete: onDelete,
          ),
          PlatformTicketSpotlightCard(ticket: ticket, initials: initials),
          Expanded(
            child: Container(
              color: colors.isDark
                  ? const Color(0xFF0B0F19)
                  : colors.surfaceSecondary,
              child: PlatformTicketConversationFeed(
                ticket: ticket,
                scrollController: scrollController,
              ),
            ),
          ),
          if (!isResolved)
            PlatformTicketMacrosBar(onSelectMacro: onSelectMacro),
          if (!isResolved)
            PlatformTicketReplyInput(
              controller: replyController,
              isInternalNote: isInternalNote,
              isSending: isSending,
              onToggleMode: onToggleMode,
              onSend: onSend,
            ),
        ],
      ),
    );
  }
}
