import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueHistoryEmptyState extends StatelessWidget {
  final int filterIndex;

  const QueueHistoryEmptyState({super.key, required this.filterIndex});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
          style: BorderStyle.solid,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text(
            '🎟️',
            style: TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 8),
          Text(
            filterIndex == 1
                ? 'No active queue tokens'
                : (filterIndex == 2
                    ? 'No completed queue tokens'
                    : 'No queue tokens'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You have no joined queues matching this filter.',
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
