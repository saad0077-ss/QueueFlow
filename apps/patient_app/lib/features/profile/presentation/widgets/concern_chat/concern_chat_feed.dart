import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/support_ticket_entity.dart';
import 'concern_chat_bubble.dart';
import 'concern_chat_feed_header.dart';
import 'concern_chat_system_pill.dart';

/// Displays concern conversation messages, either inline or as a scrollable pane.
class ConcernChatFeed extends StatelessWidget {
  final SupportTicketEntity ticket;
  final bool isResolved;
  final VoidCallback onToggleResolve;
  final bool scrollablePanel;
  final ScrollController? scrollController;
  final Widget? footer;

  const ConcernChatFeed({
    super.key,
    required this.ticket,
    required this.isResolved,
    required this.onToggleResolve,
    this.scrollablePanel = false,
    this.scrollController,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bodyContent = ticket.messages.isEmpty
        ? _buildEmptyState(colors)
        : _buildMessagesList(ticket);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConcernChatFeedHeader(
            messageCount: ticket.messages.length,
            isResolved: isResolved,
            onToggleResolve: onToggleResolve,
          ),
          if (scrollablePanel)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: bodyContent,
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(minHeight: 280),
              padding: const EdgeInsets.all(12),
              child: bodyContent,
            ),
          if (footer != null) footer!,
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Text('💬', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 10),
        Text(
          'Care Desk live chat active',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Inquiry received. Front desk coordinator will respond shortly.',
          style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (scrollablePanel) return Center(child: content);
    return Container(height: 240, alignment: Alignment.center, child: content);
  }

  Widget _buildMessagesList(SupportTicketEntity ticket) {
    return ListView.separated(
      controller: scrollablePanel ? scrollController : null,
      shrinkWrap: !scrollablePanel,
      physics: scrollablePanel
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: ticket.messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final msg = ticket.messages[index];
        if (msg.senderRole == 'system') {
          return ConcernChatSystemPill(
            text: _formatSystemText(msg.text, ticket),
            time: msg.time,
          );
        }
        return ConcernChatBubble(msg: msg);
      },
    );
  }

  String _formatSystemText(String raw, SupportTicketEntity ticket) {
    if (raw.toLowerCase().contains('escalated') &&
        !raw.toLowerCase().contains('escalated from')) {
      final match = RegExp(
        r'by\s+([^for\.\n]+?)(?:\s+for|$|\.)',
        caseSensitive: false,
      ).firstMatch(raw);
      final sender = match != null
          ? match.group(1)!.trim()
          : (ticket.clinicName.isNotEmpty ? ticket.clinicName : 'Clinic Admin');
      return '🚨 Ticket escalated from $sender to Platform Admin.';
    }
    return raw;
  }
}
