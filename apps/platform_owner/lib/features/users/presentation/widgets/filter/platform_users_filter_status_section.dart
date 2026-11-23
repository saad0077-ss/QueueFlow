import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformUsersFilterStatusSection extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelectStatus;

  const PlatformUsersFilterStatusSection({
    super.key,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'id': 'all',
        'title': 'All Statuses',
        'sub': 'Any account status',
        'icon': '⚡',
      },
      {'id': 'active', 'title': 'Active', 'sub': 'Normal access', 'icon': '🟢'},
      {
        'id': 'in-queue',
        'title': 'In Queue',
        'sub': 'Holding live token',
        'icon': '🎫',
      },
      {
        'id': 'suspended',
        'title': 'Suspended',
        'sub': 'Restricted account',
        'icon': '⛔',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSel = selectedStatus == opt['id'];
            return SizedBox(
              width: itemWidth,
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
