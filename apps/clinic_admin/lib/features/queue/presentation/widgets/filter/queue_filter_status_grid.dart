import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueFilterStatusGrid extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelectStatus;

  const QueueFilterStatusGrid({
    super.key,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusOptions = [
      {
        'id': 'all',
        'title': 'All Queues',
        'sub': 'All departments',
        'icon': '⚡',
      },
      {
        'id': 'waiting',
        'title': 'Patients Waiting',
        'sub': 'Queue active line',
        'icon': '⏳',
      },
      {
        'id': 'active',
        'title': 'In Consultation',
        'sub': 'Active doctor sessions',
        'icon': '🟢',
      },
      {
        'id': 'idle',
        'title': 'All Clear / Idle',
        'sub': 'Zero waiting tokens',
        'icon': '✨',
      },
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: statusOptions.map((opt) {
            final isSel = selectedStatus == opt['id'];
            return SizedBox(
              width: w,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectStatus(opt['id']!),
                emojiIcon: opt['icon'],
                title: opt['title']!,
                subtitle: opt['sub']!,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
