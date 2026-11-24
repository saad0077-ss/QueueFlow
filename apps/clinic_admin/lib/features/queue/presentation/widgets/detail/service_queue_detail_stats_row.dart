import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';
import 'service_queue_detail_stat_card.dart';

class ServiceQueueDetailStatsRow extends StatelessWidget {
  final ClinicQueueItemEntity? servingItem;
  final int waitingCount;
  final int estWaitMinutes;
  final int completedCount;

  const ServiceQueueDetailStatsRow({
    super.key,
    required this.servingItem,
    required this.waitingCount,
    required this.estWaitMinutes,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          ServiceQueueDetailStatCard(
            icon: '👨‍⚕️',
            iconBg: const Color(0xFF10B981).withValues(alpha: 0.12),
            value: servingItem != null ? servingItem!.token : '--',
            label: 'Currently Serving',
            sub: servingItem != null
                ? servingItem!.patientName
                : 'Counter ready / No patient called',
            isMono: servingItem != null,
          ),
          ServiceQueueDetailStatCard(
            icon: '⏳',
            iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            value: waitingCount.toString(),
            label: 'Patients Waiting',
            sub: '$waitingCount patient${waitingCount == 1 ? "" : "s"} in line',
          ),
          ServiceQueueDetailStatCard(
            icon: '⏱️',
            iconBg: colors.primaryTint,
            value: '$estWaitMinutes min',
            label: 'Estimated Wait Time',
            sub: 'Based on service pace',
          ),
          ServiceQueueDetailStatCard(
            icon: '✅',
            iconBg: Colors.purple.withValues(alpha: 0.12),
            value: completedCount.toString(),
            label: 'Completed Today',
            sub: 'Consultations logged',
          ),
        ];

        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        if (constraints.maxWidth < 1050) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i < cards.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }
}
