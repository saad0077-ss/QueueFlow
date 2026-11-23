import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicAppointmentsFilterDeptSection extends StatelessWidget {
  final String selectedDept;
  final List<String> availableDepts;
  final ValueChanged<String> onSelectDept;

  const ClinicAppointmentsFilterDeptSection({
    super.key,
    required this.selectedDept,
    required this.availableDepts,
    required this.onSelectDept,
  });

  @override
  Widget build(BuildContext context) {
    final depts = ['all', ...availableDepts.where((d) => d != 'all')];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 20) / 3;
        final itemWidth = w < 140 ? (c.maxWidth - 10) / 2 : w;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: depts.map((dept) {
            final isSel = selectedDept == dept;
            final isAll = dept == 'all';
            return SizedBox(
              width: itemWidth,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectDept(dept),
                emojiIcon: isAll ? '🏥' : '🩺',
                title: isAll ? 'All Departments' : dept,
                subtitle: isAll ? 'Entire clinic' : 'Department filter',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
