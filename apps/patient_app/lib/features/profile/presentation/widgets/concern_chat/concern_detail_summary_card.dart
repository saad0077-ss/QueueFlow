import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/support_ticket_entity.dart';
import 'concern_detail_sla_box.dart';
import 'concern_detail_stepper.dart';
import 'concern_detail_summary_badges.dart';
import 'concern_detail_tag_pill.dart';

/// Displays problem metadata, description, SLA banner, and resolution progress.
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
          ConcernDetailMetaRow(
            ticket: ticket,
            isResolved: isResolved,
            isInProg: isInProg,
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
              ConcernDetailTagPill(
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
                ConcernDetailTagPill(
                  icon: '🏷️',
                  label: 'Token ${ticket.linkedTokenNumber}',
                  color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                  textColor: const Color(0xFF2563EB),
                  border: const Color(0xFF2563EB).withValues(alpha: 0.2),
                  isMono: true,
                ),
              ConcernDetailTagPill(
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
}
