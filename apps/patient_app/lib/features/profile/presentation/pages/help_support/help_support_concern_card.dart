import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';
import 'help_support_concern_card_header.dart';

class HelpSupportConcernCard extends StatelessWidget {
  final SupportTicketEntity ticket;
  final VoidCallback onTap;

  const HelpSupportConcernCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isResolved = ticket.status == 'resolved';
    final isInProgress = ticket.status == 'in_progress';

    Color statusColor;
    String statusText;
    if (isResolved) {
      statusColor = const Color(0xFF10B981);
      statusText = 'Resolved';
    } else if (isInProgress) {
      statusColor = const Color(0xFF0072FF);
      statusText = 'Under Review';
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Lobby Triage';
    }

    final prioColor = ticket.priority == 'high'
        ? const Color(0xFFEF4444)
        : (ticket.priority == 'medium'
              ? const Color(0xFFF59E0B)
              : const Color(0xFF10B981));
    final prioText = ticket.priority == 'high'
        ? 'Urgent SOS'
        : (ticket.priority == 'medium' ? 'In-Clinic' : 'Standard');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HelpSupportConcernCardHeader(
              ticket: ticket,
              prioColor: prioColor,
              prioText: prioText,
              statusColor: statusColor,
              statusText: statusText,
            ),
            const SizedBox(height: 10),
            Text(
              ticket.subject,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.local_hospital_outlined,
                  size: 13,
                  color: colors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${ticket.clinicName} • ${ticket.category.toUpperCase()}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: colors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${ticket.messages.length} msgs',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ticket.createdAt,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  'Open Chat & Resolution ›',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0072FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
