import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';
import 'concern_chat_bubble.dart';
import 'concern_chat_system_pill.dart';

class ConcernChatFeed extends StatelessWidget {
  final SupportTicketEntity ticket;
  final bool isResolved;
  final VoidCallback onToggleResolve;

  const ConcernChatFeed({
    super.key,
    required this.ticket,
    required this.isResolved,
    required this.onToggleResolve,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('💬', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Care Desk Discussion (${ticket.messages.length})',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: onToggleResolve,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isResolved
                          ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                          : const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isResolved
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF10B981),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isResolved
                              ? Icons.refresh_rounded
                              : Icons.check_circle_rounded,
                          size: 13,
                          color: isResolved
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isResolved ? 'Reopen Concern' : 'Mark as Resolved',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isResolved
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 280),
            padding: const EdgeInsets.all(12),
            child: ticket.messages.isEmpty
                ? _buildEmptyState(colors)
                : _buildMessagesList(ticket),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors) {
    return Container(
      height: 240,
      alignment: Alignment.center,
      child: Column(
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
      ),
    );
  }

  Widget _buildMessagesList(SupportTicketEntity ticket) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ticket.messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final msg = ticket.messages[index];
        if (msg.senderRole == 'system') {
          String display = msg.text;
          if (display.toLowerCase().contains('escalated') &&
              !display.toLowerCase().contains('escalated from')) {
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
          return ConcernChatSystemPill(text: display, time: msg.time);
        }
        return ConcernChatBubble(msg: msg);
      },
    );
  }
}
