import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformClinicsFilterPlanSection extends StatelessWidget {
  final String selectedPlan;
  final ValueChanged<String> onSelectPlan;

  const PlatformClinicsFilterPlanSection({
    super.key,
    required this.selectedPlan,
    required this.onSelectPlan,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'id': 'All Plans',
        'title': 'All Plans',
        'sub': 'Entire facility network',
        'icon': '⚡',
      },
      {
        'id': 'Solo Doctor Plan',
        'title': 'Solo Doctor',
        'sub': 'Single practitioner tier',
        'icon': '👤',
      },
      {
        'id': 'Multi-Doctor Clinic Plan',
        'title': 'Multi-Doctor Clinic',
        'sub': 'Group practice tier',
        'icon': '🏥',
      },
      {
        'id': 'Enterprise Practice',
        'title': 'Enterprise Practice',
        'sub': 'Multi-center network tier',
        'icon': '👑',
      },
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSel = selectedPlan == opt['id'];
            return SizedBox(
              width: w,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectPlan(opt['id']!),
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
