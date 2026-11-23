import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicAppointmentsFilterDateSection extends StatelessWidget {
  final String selectedDate;
  final ValueChanged<String> onSelectDate;

  const ClinicAppointmentsFilterDateSection({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'id': 'all',
        'title': 'All Dates',
        'sub': 'Any appointment date',
        'icon': '📅',
      },
      {'id': 'today', 'title': 'Today', 'sub': 'Scheduled today', 'icon': '☀️'},
      {'id': 'week', 'title': 'This Week', 'sub': 'Next 7 days', 'icon': '📆'},
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSel = selectedDate == opt['id'];
            return SizedBox(
              width: w,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectDate(opt['id']!),
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
