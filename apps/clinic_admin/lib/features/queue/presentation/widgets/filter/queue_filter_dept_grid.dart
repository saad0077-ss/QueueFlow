import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        final w = (c.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _DeptTile(
              width: w,
              icon: '🏥',
              name: 'All Departments',
              sub: deptSubtitles['all'] ?? '${departments.length} total',
              isSelected: selectedDept == 'all',
              onTap: () => onSelectDept('all'),
            ),
            for (final d in departments)
              _DeptTile(
                width: w,
                icon: d.icon,
                name: d.name,
                sub: deptSubtitles[d.id] ?? '',
                isSelected: selectedDept == d.id,
                onTap: () => onSelectDept(d.id),
              ),
          ],
        );
      },
    );
  }
}

class _DeptTile extends StatelessWidget {
  final double width;
  final String icon;
  final String name;
  final String sub;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeptTile({
    required this.width,
    required this.icon,
    required this.name,
    required this.sub,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
            ),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : colors.textPrimary,
                      ),
                    ),
                    if (sub.isNotEmpty)
                      Text(
                        sub,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : colors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
