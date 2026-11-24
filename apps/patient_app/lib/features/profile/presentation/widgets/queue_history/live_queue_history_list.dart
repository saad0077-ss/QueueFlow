import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:patient_app/features/profile/domain/entities/patient_queue_history_entity.dart';

import 'queue_history_card.dart';

class LiveQueueHistoryList extends StatelessWidget {
  final List<PatientQueueHistoryEntity> queues;
  final VoidCallback? onTrackLiveQueue;
  final ValueChanged<String>? onBookClinic;

  const LiveQueueHistoryList({
    super.key,
    required this.queues,
    this.onTrackLiveQueue,
    this.onBookClinic,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isGrid = constraints.maxWidth >= 768;
        if (!isGrid) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: queues.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) => _buildCard(ctx, queues[idx]),
          );
        }

        final maxCols = constraints.maxWidth >= 1150 ? 3 : 2;
        final columns = queues.length < maxCols
            ? math.max(1, queues.length)
            : maxCols;
        final rows = <List<PatientQueueHistoryEntity>>[];
        for (var i = 0; i < queues.length; i += columns) {
          rows.add(
            queues.sublist(i, (i + columns).clamp(0, queues.length)),
          );
        }

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: 16),
                    Expanded(
                      child: j < row.length
                          ? _buildCard(context, row[j])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, PatientQueueHistoryEntity item) {
    return QueueHistoryCard(
      item: item,
      onTrackLive: item.isActive
          ? () {
              Navigator.of(context).pop();
              onTrackLiveQueue?.call();
            }
          : null,
      onBookAgain: () {
        Navigator.of(context).pop();
        onBookClinic?.call(item.clinicId);
      },
    );
  }
}
