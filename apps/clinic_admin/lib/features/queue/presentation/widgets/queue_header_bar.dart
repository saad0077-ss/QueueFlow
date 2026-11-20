import 'package:flutter/material.dart';
import 'queue_header_controls.dart';
import 'queue_header_title.dart';

class QueueHeaderBar extends StatelessWidget {
  final String clinicName;
  final bool isQueueOpen;
  final VoidCallback onToggleQueue;
  final VoidCallback onAddWalkIn;

  const QueueHeaderBar({
    super.key,
    required this.clinicName,
    required this.isQueueOpen,
    required this.onToggleQueue,
    required this.onAddWalkIn,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 780;

        final titleBlock = QueueHeaderTitle(clinicName: clinicName);
        final controls = QueueHeaderControls(
          isQueueOpen: isQueueOpen,
          onToggleQueue: onToggleQueue,
          onAddWalkIn: onAddWalkIn,
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleBlock, const SizedBox(height: 14), controls],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            controls,
          ],
        );
      },
    );
  }
}
