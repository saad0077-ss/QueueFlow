import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';

class ConcernDetailStepper extends StatelessWidget {
  final SupportTicketEntity ticket;
  final bool isResolved;
  final bool isInProg;

  const ConcernDetailStepper({
    super.key,
    required this.ticket,
    required this.isResolved,
    required this.isInProg,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final step2Done = isResolved || isInProg;
    final step2Active = !isResolved && !isInProg;
    final step3Done = isResolved;
    final step3Active = isInProg;
    final step4Done = isResolved;

    return Row(
      children: [
        _stepNode(
          label: 'Submitted',
          sub: ticket.createdAt,
          isDone: true,
          isActive: false,
          colors: colors,
        ),
        _stepConnector(isDone: step2Done, colors: colors),
        _stepNode(
          label: 'Care Desk',
          sub: ticket.assignedTo ?? 'Desk Triage',
          isDone: step2Done,
          isActive: step2Active,
          colors: colors,
        ),
        _stepConnector(isDone: step3Done, colors: colors),
        _stepNode(
          label: 'In Progress',
          sub: isResolved ? 'Complete' : 'Action taken',
          isDone: step3Done,
          isActive: step3Active,
          colors: colors,
        ),
        _stepConnector(isDone: step4Done, colors: colors),
        _stepNode(
          label: 'Resolved',
          sub: isResolved ? (ticket.resolvedAt ?? 'Closed') : 'Final',
          isDone: step4Done,
          isActive: false,
          colors: colors,
        ),
      ],
    );
  }

  Widget _stepNode({
    required String label,
    required String sub,
    required bool isDone,
    required bool isActive,
    required AppColorsExtension colors,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? const Color(0xFF10B981)
                  : (isActive ? const Color(0xFF2563EB) : colors.border),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : (isActive
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : const SizedBox.shrink()),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: isDone || isActive ? colors.textPrimary : colors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            sub,
            style: GoogleFonts.inter(fontSize: 8.5, color: colors.textMuted),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _stepConnector({
    required bool isDone,
    required AppColorsExtension colors,
  }) {
    return Container(
      width: 14,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isDone ? const Color(0xFF10B981) : colors.border,
    );
  }
}
