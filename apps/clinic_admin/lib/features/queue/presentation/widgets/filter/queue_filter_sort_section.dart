import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueFilterSortSection extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  const QueueFilterSortSection({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {
        'id': 'default',
        'title': 'Default Order',
        'sub': 'Standard list',
        'icon': '📋',
      },
      {
        'id': 'waiting',
        'title': 'Most Waiting',
        'sub': 'Highest queue first',
        'icon': '⏳',
      },
      {
        'id': 'name',
        'title': 'Name (A–Z)',
        'sub': 'Alphabetical',
        'icon': '🔤',
      },
      {
        'id': 'services',
        'title': 'Most Services',
        'sub': 'Largest count',
        'icon': '🏥',
      },
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: sortOptions.map((opt) {
            final isSel = currentSort == opt['id'];
            return SizedBox(
              width: w,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSortChanged(opt['id']!),
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
