import 'package:flutter/material.dart';

import '../../../domain/entities/patient_queue_history_entity.dart';
import 'queue_history_active_card.dart';
import 'queue_history_completed_card.dart';

class QueueHistoryCard extends StatelessWidget {
  final PatientQueueHistoryEntity item;
  final VoidCallback? onTrackLive;
  final VoidCallback? onBookAgain;

  const QueueHistoryCard({
    super.key,
    required this.item,
    this.onTrackLive,
    this.onBookAgain,
  });

  @override
  Widget build(BuildContext context) {
    if (item.isActive) {
      return QueueHistoryActiveCard(item: item, onTrackLive: onTrackLive);
    }
    return QueueHistoryCompletedCard(item: item, onBookAgain: onBookAgain);
  }
}
