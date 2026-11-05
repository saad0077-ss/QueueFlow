import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/service_department_entity.dart';
import 'service_ui_kit.dart';

class ServiceDeptDropdown extends StatelessWidget {
  final String? selectedDeptId;
  final List<ServiceDepartmentEntity> departments;
  final ValueChanged<String?> onChanged;

  const ServiceDeptDropdown({
    super.key,
    required this.selectedDeptId,
    required this.departments,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ServiceLabeledField(
      label: 'Department',
      child: DropdownButtonFormField<String>(
        initialValue: selectedDeptId,
        isExpanded: true,
        dropdownColor: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colors.textMuted,
          size: 20,
        ),
        decoration: serviceInputDecoration(context: context),
        items: departments
            .map(
              (d) => DropdownMenuItem(
                value: d.id,
                child: Text(
                  '${d.icon} ${d.name} (${d.code})',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
