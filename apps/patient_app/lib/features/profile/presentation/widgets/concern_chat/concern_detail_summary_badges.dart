import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/support_ticket_entity.dart';

/// Renders the ticket number, status/priority badges, and timestamp row.
class ConcernDetailMetaRow extends StatelessWidget {
  final SupportTicketEntity ticket;
  final bool isResolved;
  final bool isInProg;

  const ConcernDetailMetaRow({
    super.key,
    required this.ticket,
    required this.isResolved,
    required this.isInProg,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final prio = ticket.priority.toLowerCase();
    final prioColor = (prio == 'high' || prio == 'urgent')
        ? const Color(0xFFEF4444)
        : (prio == 'medium' ? const Color(0xFF2563EB) : colors.textMuted);
    final prioLabel = (prio == 'high' || prio == 'urgent')
        ? 'Urgent SOS'
        : (prio == 'medium' ? 'In-Clinic' : 'Standard');

    final statusColor = isResolved
        ? const Color(0xFF10B981)
        : (isInProg ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6));
    final statusLabel = isResolved
        ? 'Resolved'
        : (isInProg ? 'Under Review' : 'Open / Logged');

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '#${ticket.ticketNumber}',
              style: GoogleFonts.firaCode(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2563EB),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isResolved)
                    Icon(Icons.check_rounded, size: 12, color: statusColor)
                  else
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: prioColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                prioLabel,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: prioColor,
                ),
              ),
            ),
            Text(
              ticket.createdAt,
              style: GoogleFonts.inter(fontSize: 10.5, color: colors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
