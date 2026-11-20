import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../domain/entities/active_ticket_entity.dart';

class _TimelineStepData {
  final String label;
  final bool isDone;
  final bool isActive;

  const _TimelineStepData({
    required this.label,
    required this.isDone,
    required this.isActive,
  });
}

class ActiveTicketTimeline extends StatelessWidget {
  final ActiveTicketEntity ticket;

  const ActiveTicketTimeline({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCalled = ticket.status.toLowerCase() == 'called';
    final isCompleted = ticket.status.toLowerCase() == 'completed';

    final steps = [
      const _TimelineStepData(
        label: 'Token Issued & Paid\n(Razorpay)',
        isDone: true,
        isActive: false,
      ),
      _TimelineStepData(
        label: 'Waiting\nin Queue',
        isDone: isCompleted || isCalled || ticket.position <= 1,
        isActive: !isCompleted && !isCalled && ticket.position > 1,
      ),
      _TimelineStepData(
        label: 'Almost\nyour turn',
        isDone: isCompleted || isCalled,
        isActive:
            !isCompleted &&
            !isCalled &&
            ticket.position <= 1 &&
            ticket.position > 0,
      ),
      _TimelineStepData(
        label: 'Called for\nConsultation',
        isDone: isCompleted,
        isActive: !isCompleted && (isCalled || ticket.position <= 0),
      ),
      _TimelineStepData(label: 'Completed', isDone: isCompleted, isActive: false),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final prevStep = steps[i ~/ 2];
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                height: 2,
                color: prevStep.isDone
                    ? const Color(0xFF10B981)
                    : colors.border,
              ),
            );
          } else {
            final step = steps[i ~/ 2];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(context, step),
                const SizedBox(height: 6),
                SizedBox(
                  width: 64,
                  child: Text(
                    step.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: step.isActive
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: step.isActive
                          ? colors.primary
                          : (step.isDone
                              ? colors.textPrimary
                              : colors.textSubtle),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildDot(BuildContext context, _TimelineStepData step) {
    final colors = context.colors;

    if (step.isDone) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: Color(0xFF10B981),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
      );
    }

    if (step.isActive) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border, width: 2),
      ),
    );
  }
}
