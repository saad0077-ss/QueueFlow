import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformUsersFilterVerificationSection extends StatelessWidget {
  final String selectedVerification;
  final ValueChanged<String> onSelectVerification;

  const PlatformUsersFilterVerificationSection({
    super.key,
    required this.selectedVerification,
    required this.onSelectVerification,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'id': 'all',
        'title': 'All Users',
        'sub': 'Any verification',
        'icon': '⚡',
      },
      {
        'id': 'verified',
        'title': 'Verified Users',
        'sub': 'Phone/email confirmed',
        'icon': '✅',
      },
      {
        'id': 'unverified',
        'title': 'Unverified',
        'sub': 'Registration pending check',
        'icon': '⚠️',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSel = selectedVerification == opt['id'];
            return SizedBox(
              width: itemWidth,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectVerification(opt['id']!),
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
