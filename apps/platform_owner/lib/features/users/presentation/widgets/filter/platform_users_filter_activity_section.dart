import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformUsersFilterActivitySection extends StatelessWidget {
  final String selectedActivity;
  final ValueChanged<String> onSelectActivity;

  const PlatformUsersFilterActivitySection({
    super.key,
    required this.selectedActivity,
    required this.onSelectActivity,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'id': 'all',
        'title': 'All Activity',
        'sub': 'Any token state',
        'icon': '⚡',
      },
      {
        'id': 'has-token',
        'title': 'Currently In Queue',
        'sub': 'Holding live queue token',
        'icon': '🎟️',
      },
      {
        'id': 'no-token',
        'title': 'Not In Queue',
        'sub': 'No active tokens right now',
        'icon': '⭕',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSel = selectedActivity == opt['id'];
            return SizedBox(
              width: itemWidth,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectActivity(opt['id']!),
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
