import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../services/domain/entities/service_department_entity.dart';

class QueueFilterDeptGrid extends StatelessWidget {
  final List<ServiceDepartmentEntity> departments;
  final String selectedDept;
  final Map<String, String> deptSubtitles;
  final ValueChanged<String> onSelectDept;

  const QueueFilterDeptGrid({
    super.key,
    required this.departments,
    required this.selectedDept,
    required this.deptSubtitles,
    required this.onSelectDept,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 20) / 3;
        final actualWidth = w < 160 ? (c.maxWidth - 10) / 2 : w;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: actualWidth,
              child: AppFilterSelectableCard(
                isSelected: selectedDept == 'all',
                onTap: () => onSelectDept('all'),
                emojiIcon: '🏥',
                title: 'All Clinics',
                subtitle: deptSubtitles['all'] ?? '${departments.length} total',
              ),
            ),
            for (final d in departments)
              SizedBox(
                width: actualWidth,
                child: AppFilterSelectableCard(
                  isSelected: selectedDept == d.id,
                  onTap: () => onSelectDept(d.id),
                  emojiIcon: d.icon.isNotEmpty ? d.icon : '🩺',
                  title: d.name,
                  subtitle: deptSubtitles[d.id] ?? 'Specialty care',
                ),
              ),
          ],
        );
      },
    );
  }
}
