import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return ServiceLabeledField(
      label: 'Medical Specialty / Department (Super Admin)',
      child: DropdownButtonFormField<String>(
        initialValue: selectedDeptId,
        isExpanded: true,
        dropdownColor: const Color(0xFF16213A),
        borderRadius: BorderRadius.circular(10),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white,
          size: 20,
        ),
        decoration: serviceInputDecoration(),
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
                    color: Colors.white,
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
