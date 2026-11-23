import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_support_ticket_entity.dart';
import 'card/clinic_ticket_card_footer.dart';
import 'card/clinic_ticket_card_header.dart';
import 'card/clinic_ticket_card_patient_row.dart';

class ClinicTicketCard extends StatelessWidget {
  final ClinicSupportTicketEntity ticket;
  final bool isSelected;
  final VoidCallback onTap;

  const ClinicTicketCard({
    super.key,
    required this.ticket,
    required this.isSelected,
    required this.onTap,
  });

  Color _getAccentColor() {
    final isResolved = ticket.status.toLowerCase() == 'resolved';
    final isInProgress = ticket.status.toLowerCase() == 'in_progress';
    final prio = ticket.priority.toLowerCase();
    final isUrgentOrHigh =
        prio == 'high' || prio == 'urgent' || ticket.slaMinutes < 15;

    if (isResolved) return const Color(0xFF10B981);
    if (isInProgress) return const Color(0xFFF59E0B);
    if (isUrgentOrHigh) return const Color(0xFFEF4444);
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    final cardBg = isSelected
        ? (isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.7)
              : const Color(0xFFEFF6FF))
        : colors.surface;
    final cardBorderColor = isSelected
        ? const Color(0xFF2563EB)
        : colors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cardBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(
                      0xFF2563EB,
                    ).withValues(alpha: isDark ? 0.2 : 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3.5, color: _getAccentColor()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClinicTicketCardHeader(ticket: ticket),
                        const SizedBox(height: 8),
                        ClinicTicketCardPatientRow(ticket: ticket),
                        const SizedBox(height: 8),
                        ClinicTicketCardFooter(ticket: ticket),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
