import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformClinicsFilterStatusSection extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelectStatus;

  const PlatformClinicsFilterStatusSection({
    super.key,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'id': 'All Statuses',
        'title': 'All Statuses',
        'sub': 'Any clinic status',
        'icon': '⚡',
      },
      {
        'id': 'ACTIVE',
        'title': 'Active',
        'sub': 'Fully operational',
        'icon': '🟢',
      },
      {
        'id': 'INVITED',
        'title': 'Invited',
        'sub': 'Awaiting onboarding',
        'icon': '📩',
      },
      {'id': 'TRIAL', 'title': 'Trial', 'sub': 'Evaluation phase', 'icon': '✨'},
      {
        'id': 'SUSPENDED',
        'title': 'Suspended',
        'sub': 'Temporarily paused',
        'icon': '⛔',
      },
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 20) / 3;
        final itemWidth = w < 140 ? (c.maxWidth - 10) / 2 : w;
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
