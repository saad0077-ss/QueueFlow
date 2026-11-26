import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/support_ticket_entity.dart';
import 'concern_detail_progress_track.dart';
import 'concern_detail_step_node.dart';

/// Displays an animated progress bar and connected 4-stage resolution timeline.
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
    final activeStep = isResolved ? 4 : (isInProg ? 3 : 2);
    final stageLabel = isResolved
        ? 'Concern Resolved'
        : (isInProg ? 'Action In Progress' : 'Desk Triage');

    final steps = [
      (
        label: 'Submitted',
        sub: ticket.createdAt,
        done: true,
        active: false,
        icon: Icons.send_rounded,
      ),
      (
        label: 'Care Desk',
        sub: ticket.assignedTo ?? 'Desk Triage',
        done: isResolved || isInProg,
        active: !isResolved && !isInProg,
        icon: Icons.support_agent_rounded,
      ),
      (
        label: 'In Progress',
        sub: isResolved ? 'Complete' : 'Action taken',
        done: isResolved,
        active: isInProg && !isResolved,
        icon: Icons.sync_rounded,
      ),
      (
        label: 'Resolved',
        sub: isResolved ? (ticket.resolvedAt ?? 'Closed') : 'Final',
        done: isResolved,
        active: false,
        icon: Icons.verified_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConcernDetailProgressTrack(
            activeStep: activeStep,
            stageLabel: stageLabel,
            isResolved: isResolved,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < steps.length; i++)
                Expanded(
                  child: ConcernDetailStepNode(
                    label: steps[i].label,
                    sub: steps[i].sub,
                    done: steps[i].done,
                    active: steps[i].active,
                    icon: steps[i].icon,
                    showLeftLine: i > 0,
                    showRightLine: i < steps.length - 1,
                    leftDone: i > 0 && (steps[i].done || steps[i].active),
                    rightDone: i < steps.length - 1 &&
                        (steps[i + 1].done || steps[i + 1].active),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
