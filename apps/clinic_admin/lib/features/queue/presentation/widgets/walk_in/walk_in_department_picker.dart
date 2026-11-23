import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../services/domain/entities/service_department_entity.dart';

class WalkInDepartmentPicker extends StatelessWidget {
  final List<ServiceDepartmentEntity> departments;
  final String selectedDeptKey;
  final ValueChanged<String> onDepartmentChanged;

  const WalkInDepartmentPicker({
    super.key,
    required this.departments,
    required this.selectedDeptKey,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DropdownButtonFormField<String>(
      key: const ValueKey('walkin-dept'),
      initialValue: selectedDeptKey.isNotEmpty ? selectedDeptKey : null,
      isExpanded: true,
      dropdownColor: colors.surface,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textPrimary),
      items: [
        for (final d in departments)
          DropdownMenuItem(
            value: d.name.trim().toLowerCase(),
            child: Text(
              '${d.icon.isNotEmpty ? d.icon : '🩺'}  ${d.name}',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
      ],
      onChanged: (v) {
        if (v != null) onDepartmentChanged(v);
      },
      validator: (v) => v == null ? 'Select a department' : null,
      decoration: InputDecoration(
        hintText: 'Select department',
        hintStyle: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
        filled: true,
        fillColor: colors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
