import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_chat_helpers.dart';

class PlatformTicketChatSlaBadge extends StatelessWidget {
  final PlatformSupportTicketEntity ticket;

  const PlatformTicketChatSlaBadge({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final countdown = PlatformTicketChatHelpers.formatSlaCountdown(ticket);
    final isOverdue = countdown.contains('Overdue');
    final badgeColor = isResolved
        ? const Color(0xFF10B981)
        : (isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isResolved ? 'SLA Met' : 'Care Desk SLA: $countdown',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
