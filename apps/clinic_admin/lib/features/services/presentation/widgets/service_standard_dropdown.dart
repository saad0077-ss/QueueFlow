import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/service_department_entity.dart';
import 'service_ui_kit.dart';

/// Lists the platform admin's catalog services for the selected department.
class ServiceStandardDropdown extends StatelessWidget {
  /// Dropdown value used for the "request a new service" option.
  static const customValue = '__custom__';

  final String selectedStandard;
  final List<StandardServiceTemplate> templates;
  final ValueChanged<String?> onChanged;

  const ServiceStandardDropdown({
    super.key,
    required this.selectedStandard,
    required this.templates,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection =
        selectedStandard == customValue ||
        templates.any((t) => t.name == selectedStandard);
    final itemStyle = GoogleFonts.inter(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return ServiceLabeledField(
      label: 'Standard Clinical Service',
      child: DropdownButtonFormField<String>(
        initialValue: hasSelection ? selectedStandard : customValue,
        isExpanded: true,
        dropdownColor: const Color(0xFF16213A),
        borderRadius: BorderRadius.circular(10),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white,
          size: 20,
        ),
        decoration: serviceInputDecoration(),
        items: [
          ...templates.map(
            (s) => DropdownMenuItem(
              value: s.name,
              child: Text(
                '📋 ${s.name} (⏱ ${s.duration}m • ₹${s.suggestedPrice})',
                overflow: TextOverflow.ellipsis,
                style: itemStyle,
              ),
            ),
          ),
          DropdownMenuItem(
            value: customValue,
            child: Text(
              '➕ Request New Service (Super Admin Review)',
              overflow: TextOverflow.ellipsis,
              style: itemStyle.copyWith(color: ServiceColors.amber),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
