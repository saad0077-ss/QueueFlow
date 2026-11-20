import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'queue_stat_card.dart';

class QueueStatsRow extends StatelessWidget {
  final int totalDepartments;
  final int totalServices;
  final int waitingCount;
  final String avgWaitTime;

  const QueueStatsRow({
    super.key,
    required this.totalDepartments,
    required this.totalServices,
    required this.waitingCount,
    this.avgWaitTime = '15 min',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          QueueStatCard(
            iconText: '🩺',
            iconBg: colors.primaryTint,
            value: totalDepartments.toString(),
            label: 'Departments Active',
          ),
          QueueStatCard(
            iconText: '📋',
            iconBg: const Color(0xFF0F766E).withValues(alpha: 0.12),
            value: totalServices.toString(),
            label: 'Services Configured',
          ),
          QueueStatCard(
            iconText: '⏳',
            iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            value: waitingCount.toString(),
            label: 'Patients Waiting',
          ),
          QueueStatCard(
            iconText: '⏱️',
            iconBg: Colors.purple.withValues(alpha: 0.12),
            value: avgWaitTime,
            label: 'Average Wait Time',
          ),
        ];

        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 14),
            Expanded(child: cards[1]),
            const SizedBox(width: 14),
            Expanded(child: cards[2]),
            const SizedBox(width: 14),
            Expanded(child: cards[3]),
          ],
        );
      },
    );
  }
}
