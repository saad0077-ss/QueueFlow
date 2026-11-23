import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformUsersFilterTypeSection extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onSelectType;

  const PlatformUsersFilterTypeSection({
    super.key,
    required this.selectedType,
    required this.onSelectType,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'id': 'all',
        'title': 'All Users',
        'sub': 'Platform & walk-in',
        'icon': '👥',
      },
      {
        'id': 'platform_user',
        'title': 'Platform Users',
        'sub': 'Registered via app',
        'icon': '📱',
      },
      {
        'id': 'walk-in',
        'title': 'Walk-In Patients',
        'sub': 'On-site registration',
        'icon': '🚶',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSel = selectedType == opt['id'];
            return SizedBox(
              width: itemWidth,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectType(opt['id']!),
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
