import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PatientSearchFilterDropdowns extends StatelessWidget {
  final List<String> allDepartments;
  final String tempDept;
  final String tempService;
  final List<String> availableServices;
  final ValueChanged<String> onDeptChanged;
  final ValueChanged<String> onServiceChanged;
  final AppColorsExtension colors;

  const PatientSearchFilterDropdowns({
    super.key,
    required this.allDepartments,
    required this.tempDept,
    required this.tempService,
    required this.availableServices,
    required this.onDeptChanged,
    required this.onServiceChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT DEPARTMENT',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: colors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: allDepartments.contains(tempDept) ? tempDept : 'all',
              isExpanded: true,
              dropdownColor: colors.surfaceElevated,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.textSubtle,
              ),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              items: allDepartments
                  .map(
                    (d) => DropdownMenuItem<String>(
                      value: d,
                      child: Text(d == 'all' ? 'All Departments' : d),
                    ),
                  )
                  .toList(),
              onChanged: (val) => val != null ? onDeptChanged(val) : null,
            ),
          ),
        ),
        if (tempDept.toLowerCase() != 'all' &&
            availableServices.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'SELECT SERVICE',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: ['all', ...availableServices].contains(tempService)
                    ? tempService
                    : 'all',
                isExpanded: true,
                dropdownColor: colors.surfaceElevated,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.textSubtle,
                ),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'all',
                    child: Text('All Services'),
                  ),
                  ...availableServices.map(
                    (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
                  ),
                ],
                onChanged: (val) => val != null ? onServiceChanged(val) : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
