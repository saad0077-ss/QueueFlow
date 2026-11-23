import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicAppointmentsFilterStatusSection extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelectStatus;

  const ClinicAppointmentsFilterStatusSection({
    super.key,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {'id': 'all', 'title': 'All Statuses', 'sub': 'Any stage', 'icon': '⚡'},
      {
        'id': 'confirmed',
        'title': 'Confirmed',
        'sub': 'Verified booking',
        'icon': '✅',
      },
      {
        'id': 'upcoming',
        'title': 'Upcoming',
        'sub': 'Booked advance',
        'icon': '🕒',
      },
      {
        'id': 'checkedin',
        'title': 'Checked In',
        'sub': 'Present at clinic',
        'icon': '📍',
      },
      {
        'id': 'completed',
        'title': 'Completed',
        'sub': 'Finished visit',
        'icon': '🏆',
      },
      {
        'id': 'cancelled',
        'title': 'Cancelled',
        'sub': 'Void/missed',
        'icon': '❌',
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
