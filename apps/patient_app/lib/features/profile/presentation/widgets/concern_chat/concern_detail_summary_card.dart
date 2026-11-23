import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';
import 'concern_detail_sla_box.dart';
import 'concern_detail_stepper.dart';

class ConcernDetailSummaryCard extends StatelessWidget {
  final SupportTicketEntity ticket;
  final bool isResolved;
  final bool isInProg;
  final String slaCountdown;

  const ConcernDetailSummaryCard({
    super.key,
    required this.ticket,
    required this.isResolved,
    required this.isInProg,
    required this.slaCountdown,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final prio = ticket.priority.toLowerCase();
    Color prioColor = (prio == 'high' || prio == 'urgent')
        ? const Color(0xFFEF4444)
        : (prio == 'medium' ? const Color(0xFF2563EB) : colors.textMuted);
    String prioLabel = (prio == 'high' || prio == 'urgent')
        ? 'Urgent SOS'
        : (prio == 'medium' ? 'In-Clinic' : 'Standard');

    Color statusColor = isResolved
        ? const Color(0xFF10B981)
        : (isInProg ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6));
    String statusLabel = isResolved
        ? 'Resolved'
        : (isInProg ? 'Under Review' : 'Open / Logged');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.center,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isResolved)
                          Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: statusColor,
                          )
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ticket.subject,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _tagPill(
                icon: '🏥',
                label: ticket.clinicName.isNotEmpty
                    ? ticket.clinicName
                    : 'QueueFlow Platform',
                color: colors.surface,
                textColor: colors.textPrimary,
                border: colors.border,
              ),
              if (ticket.linkedTokenNumber != null &&
                  ticket.linkedTokenNumber!.isNotEmpty)
                _tagPill(
                  icon: '🏷️',
                  label: 'Token ${ticket.linkedTokenNumber}',
                  color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                  textColor: const Color(0xFF2563EB),
                  border: const Color(0xFF2563EB).withValues(alpha: 0.2),
                  isMono: true,
                ),
              _tagPill(
                icon: '📁',
                label: ticket.category.toUpperCase(),
                color: colors.surface,
                textColor: colors.textMuted,
                border: colors.border,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ticket.description.isNotEmpty
                ? ticket.description
                : 'No additional details provided.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ConcernDetailSlaBox(
            isResolved: isResolved,
            slaCountdown: slaCountdown,
          ),
          const SizedBox(height: 14),
          ConcernDetailStepper(
            ticket: ticket,
            isResolved: isResolved,
            isInProg: isInProg,
          ),
        ],
      ),
    );
  }

  Widget _tagPill({
    required String icon,
    required String label,
    required Color color,
    required Color textColor,
    required Color border,
    bool isMono = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: isMono
                ? GoogleFonts.firaCode(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  )
                : GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
          ),
        ],
      ),
    );
  }
}
