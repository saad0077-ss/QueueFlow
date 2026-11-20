import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import 'service_card/service_queue_card_actions.dart';
import 'service_card/service_queue_card_header.dart';
import 'service_card/service_queue_card_metrics.dart';
import 'service_card/service_queue_card_serving_box.dart';

class ServiceQueueCard extends StatelessWidget {
  final ClinicServiceEntity service;
  final List<ClinicQueueItemEntity> queueItems;
  final bool isQueueOpen;
  final VoidCallback onViewQueue;
  final VoidCallback onCallNext;

  const ServiceQueueCard({
    super.key,
    required this.service,
    required this.queueItems,
    required this.isQueueOpen,
    required this.onViewQueue,
    required this.onCallNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sWaiting = queueItems.where((q) => q.isWaiting).toList();
    final sServing = queueItems.where((q) => q.isCalled).firstOrNull;
    final estWaitMin = sWaiting.isNotEmpty
        ? (sWaiting.length * (service.duration > 0 ? service.duration : 15))
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ServiceQueueCardHeader(
              service: service,
              isQueueOpen: isQueueOpen,
              isServing: sServing != null,
              waitingCount: sWaiting.length,
            ),
            const SizedBox(height: 14),
            ServiceQueueCardServingBox(servingItem: sServing),
            const SizedBox(height: 12),
            ServiceQueueCardMetrics(
              waitingItems: sWaiting,
              estWaitMinutes: estWaitMin,
            ),
            const SizedBox(height: 30),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 16),
            ServiceQueueCardActions(
              hasWaiting: sWaiting.isNotEmpty,
              onViewQueue: onViewQueue,
              onCallNext: onCallNext,
            ),
          ],
        ),
      ),
    );
  }
}
