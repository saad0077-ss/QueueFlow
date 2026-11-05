import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../departments/domain/entities/department_entity.dart';

class OnboardTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final String? helperText;

  const OnboardTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: GoogleFonts.inter(
              color: readOnly ? colors.textMuted : colors.textPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: colors.textMuted, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
          ),
        ],
      ],
    );
  }
}

class OnboardPlanDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const OnboardPlanDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Tier',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: colors.surfaceElevated,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted, size: 18),
              style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 13),
              items: const [
                DropdownMenuItem(value: 'solo', child: Text('Solo Doctor Plan (₹999/mo)')),
                DropdownMenuItem(value: 'multi', child: Text('Multi-Doctor Clinic Plan (₹2,999/mo)')),
                DropdownMenuItem(value: 'enterprise', child: Text('Enterprise Practice (₹6,999/mo)')),
              ],
              onChanged: (v) => onChanged(v ?? 'solo'),
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardDepartmentDropdown extends StatelessWidget {
  final List<DepartmentEntity> departments;
  final List<String> selectedDepartmentIds;
  final ValueChanged<List<String>> onChanged;
  final bool isLoading;

  const OnboardDepartmentDropdown({
    super.key,
    required this.departments,
    required this.selectedDepartmentIds,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeDepartments = departments.where((d) => d.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Clinic Departments / Specialties',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            if (selectedDepartmentIds.isNotEmpty)
              Text(
                '${selectedDepartmentIds.length} assigned',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryLight,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: null,
              hint: Text(
                isLoading
                    ? 'Loading platform departments...'
                    : (activeDepartments.isEmpty
                        ? 'No active departments found (add in Dept tab)'
                        : (selectedDepartmentIds.isEmpty
                            ? 'Select departments for this clinic...'
                            : '+ Add / toggle another department...')),
                style: GoogleFonts.inter(
                  color: colors.textMuted,
                  fontSize: 13,
                ),
              ),
              dropdownColor: colors.surfaceElevated,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted, size: 18),
              style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 13),
              items: activeDepartments.map((dept) {
                final isSelected = selectedDepartmentIds.contains(dept.id);
                return DropdownMenuItem<String>(
                  value: dept.id,
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        size: 16,
                        color: isSelected ? colors.primaryLight : colors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dept.icon.isNotEmpty ? '${dept.icon} ' : '',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Expanded(
                        child: Text(
                          '${dept.name} (${dept.code})',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: isSelected ? colors.primaryLight : colors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (deptId) {
                if (deptId == null) return;
                final updated = List<String>.from(selectedDepartmentIds);
                if (updated.contains(deptId)) {
                  updated.remove(deptId);
                } else {
                  updated.add(deptId);
                }
                onChanged(updated);
              },
            ),
          ),
        ),
        if (selectedDepartmentIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedDepartmentIds.map((id) {
              final DepartmentEntity dept = departments.where((d) => d.id == id).firstOrNull ??
                  DepartmentEntity(
                    id: id,
                    name: id,
                    code: '',
                    icon: '🩺',
                    description: '',
                  );
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(dept.icon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      dept.name,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        final updated = List<String>.from(selectedDepartmentIds)..remove(id);
                        onChanged(updated);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
