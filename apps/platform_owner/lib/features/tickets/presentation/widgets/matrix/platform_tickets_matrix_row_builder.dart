import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';

class PlatformTicketsMatrixRowBuilder {
  static DataRow buildRow({
    required PlatformSupportTicketEntity ticket,
    required AppColorsExtension colors,
    required ValueChanged<PlatformSupportTicketEntity> onSelectTicket,
    required ValueChanged<PlatformSupportTicketEntity> onResolveTicket,
  }) {
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final isInProg = ticket.status.toLowerCase() == 'in_progress';

    Color statusColor = const Color(0xFF3B82F6);
    String statusText = 'OPEN';
    if (isResolved) {
      statusColor = const Color(0xFF10B981);
      statusText = 'RESOLVED';
    } else if (isInProg) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'IN PROGRESS';
    }

    final prio = ticket.priority.toLowerCase();
    Color prioColor = colors.textMuted;
    if (prio == 'high' || prio == 'urgent') {
      prioColor = const Color(0xFFEF4444);
    } else if (prio == 'medium') {
      prioColor = const Color(0xFF2563EB);
    }

    final isUrgentSla = ticket.slaMinutes < 15;

    return DataRow(
      onSelectChanged: (_) => onSelectTicket(ticket),
      cells: [
        DataCell(
          Text(
            '#${ticket.ticketNumber}',
            style: GoogleFonts.firaCode(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2563EB),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              '🏥 ${ticket.clinicName}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticket.patientName,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                ticket.patientPhone.isNotEmpty
                    ? ticket.patientPhone
                    : (ticket.patientEmail.isNotEmpty
                          ? ticket.patientEmail
                          : 'No contact'),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ticket.category.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ticket.description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: prioColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ticket.priority.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: prioColor,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isUrgentSla
                  ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                  : const Color(0xFF2563EB).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isUrgentSla
                  ? '🔥 ${ticket.slaMinutes}m'
                  : '⏱️ ${ticket.slaMinutes}m',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isUrgentSla
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF2563EB),
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => onSelectTicket(ticket),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Open Console',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (!isResolved) ...[
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () => onResolveTicket(ticket),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  child: Text(
                    'Resolve',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
