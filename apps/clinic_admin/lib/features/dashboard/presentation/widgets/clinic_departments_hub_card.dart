import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_department_summary_entity.dart';

class ClinicDepartmentsHubCard extends StatelessWidget {
  final List<ClinicDepartmentSummaryEntity> departments;
  final VoidCallback? onNavigateToServices;
  final VoidCallback? onNavigateToAppointments;

  const ClinicDepartmentsHubCard({
    super.key,
    this.departments = const [],
    this.onNavigateToServices,
    this.onNavigateToAppointments,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final depts = departments;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🩺', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Clinic Departments & Clinical Triage',
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.badgeOpenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${depts.length} Active Departments',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.badgeOpenText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Department Cards Grid
          if (depts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No departments assigned to this clinic yet.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: colors.textMuted,
                  ),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 14.0;
                final maxCols = constraints.maxWidth >= 1000
                    ? 4
                    : constraints.maxWidth >= 640
                    ? 2
                    : 1;
                // Never reserve more columns than there are departments, so
                // a few cards stretch to fill the row instead of leaving gaps.
                final cols = depts.length < maxCols ? depts.length : maxCols;
                final rows = <Widget>[];
                for (var i = 0; i < depts.length; i += cols) {
                  final slice = depts.skip(i).take(cols).toList();
                  rows.add(
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var j = 0; j < cols; j++) ...[
                            if (j > 0) const SizedBox(width: gap),
                            Expanded(
                              child: j < slice.length
                                  ? _DepartmentCard(
                                      department: slice[j],
                                      onServicesTap: onNavigateToServices,
                                      onApptsTap: onNavigateToAppointments,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) const SizedBox(height: gap),
                      rows[i],
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final ClinicDepartmentSummaryEntity department;
  final VoidCallback? onServicesTap;
  final VoidCallback? onApptsTap;

  const _DepartmentCard({
    required this.department,
    this.onServicesTap,
    this.onApptsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Name, Code, and Status pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      department.icon,
                      style: const TextStyle(fontSize: 24, height: 1.1),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            department.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'CODE: ${department.code}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: colors.badgeOpenBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  department.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: colors.badgeOpenText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Description (services offered)
          if (department.description.isNotEmpty)
            Text(
              department.description,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: colors.textMuted,
                height: 1.45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),
          const SizedBox(height: 12),

          // 3-Column Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'DOCTORS',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${department.doctorCount}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: colors.border),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'PROCEDURES',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${department.proceduresCount}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: colors.border),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'WAITING',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${department.waitingCount}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onServicesTap,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colors.surface,
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Services (${department.proceduresCount})',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onApptsTap,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colors.surface,
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Appts (${department.appointmentCount})',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
