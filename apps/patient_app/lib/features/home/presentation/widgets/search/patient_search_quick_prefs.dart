import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'patient_search_modal_chip.dart';

class PatientSearchQuickPrefs extends StatelessWidget {
  final Set<String> tempQuick;
  final ValueChanged<String> onToggle;
  final AppColorsExtension colors;

  const PatientSearchQuickPrefs({
    super.key,
    required this.tempQuick,
    required this.onToggle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK PREFERENCES',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: colors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PatientSearchModalChip(
              label: '🟢 Open Now',
              isSelected: tempQuick.contains('open'),
              colors: colors,
              onTap: () => onToggle('open'),
            ),
            PatientSearchModalChip(
              label: '★ 4.5+ Rating',
              isSelected: tempQuick.contains('rating'),
              colors: colors,
              onTap: () => onToggle('rating'),
            ),
            PatientSearchModalChip(
              label: '📍 < 2 km',
              isSelected: tempQuick.contains('near'),
              colors: colors,
              onTap: () => onToggle('near'),
            ),
            PatientSearchModalChip(
              label: '⚡ Live Queue',
              isSelected: tempQuick.contains('queue'),
              colors: colors,
              onTap: () => onToggle('queue'),
            ),
          ],
        ),
      ],
    );
  }
}
