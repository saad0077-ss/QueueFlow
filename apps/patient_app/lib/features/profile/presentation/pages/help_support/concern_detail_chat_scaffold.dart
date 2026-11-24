import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';
import '../../widgets/concern_chat/concern_detail_reply_bar.dart';
import 'concern_detail_chat_app_bar.dart';
import 'concern_detail_chat_body.dart';

class ConcernDetailChatScaffold extends StatelessWidget {
  final SupportTicketEntity ticket;
  final ScrollController scrollController;
  final TextEditingController replyController;
  final bool isSending;
  final VoidCallback onToggleResolve;
  final VoidCallback onSendReply;
  final Map<String, DateTime> fallbackStartTimes;

  const ConcernDetailChatScaffold({
    super.key,
    required this.ticket,
    required this.scrollController,
    required this.replyController,
    required this.isSending,
    required this.onToggleResolve,
    required this.onSendReply,
    required this.fallbackStartTimes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isResolved = ticket.status.toLowerCase() == 'resolved';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: ConcernDetailChatAppBar(ticket: ticket),
      body: Column(
        children: [
          Expanded(
            child: ConcernDetailChatBody(
              ticket: ticket,
              scrollController: scrollController,
              onToggleResolve: onToggleResolve,
              fallbackStartTimes: fallbackStartTimes,
            ),
          ),
          ConcernDetailReplyBar(
            controller: replyController,
            isSending: isSending,
            isResolved: isResolved,
            ticket: ticket,
            onSend: onSendReply,
            onReopen: onToggleResolve,
          ),
        ],
      ),
    );
  }
}
