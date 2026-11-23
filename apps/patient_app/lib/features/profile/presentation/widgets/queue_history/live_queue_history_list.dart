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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: queues.length,
      itemBuilder: (ctx, idx) {
        final item = queues[idx];
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
      },
    );
  }
}
