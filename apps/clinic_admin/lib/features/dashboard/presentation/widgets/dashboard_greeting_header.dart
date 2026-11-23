import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_department_summary_entity.dart';
import 'clinic_assigned_departments_dialog.dart';

/// Header displaying the greeting, current date, clinic name, and department tags
/// matching the web-admin design.
class DashboardGreetingHeader extends StatelessWidget {
  final String doctorName;
  final String clinicName;
  final List<ClinicDepartmentSummaryEntity> departments;
  final ValueChanged<String>? onPeriodChanged;

  const DashboardGreetingHeader({
    super.key,
    this.doctorName = '',
    this.clinicName = '',
    this.departments = const [],
    this.onPeriodChanged,
  });

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : (now.hour < 17 ? 'Good afternoon' : 'Good evening');
    final date =
        '${_weekdays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]} ${now.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting H1
        Text(
          doctorName.isEmpty ? greeting : '$greeting, $doctorName',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),

        // Date, Clinic Name & Department Badges
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              clinicName.isEmpty ? date : '$date  ·',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: colors.textMuted,
              ),
            ),
            if (clinicName.isNotEmpty)
              Text(
                clinicName,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            if (departments.isNotEmpty)
              InkWell(
                onTap: () => ClinicAssignedDepartmentsDialog.show(
                  context,
                  clinicName: clinicName,
                  departments: departments,
                ),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🩺', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 5),
                      Text(
                        '${departments.length} Department${departments.length == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 15,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
