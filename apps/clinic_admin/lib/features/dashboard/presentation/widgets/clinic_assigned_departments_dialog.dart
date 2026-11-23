import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_department_summary_entity.dart';

/// Modal dialog showing the assigned medical departments for the current clinic.
class ClinicAssignedDepartmentsDialog extends StatelessWidget {
  final String clinicName;
  final List<ClinicDepartmentSummaryEntity> departments;

  const ClinicAssignedDepartmentsDialog({
    super.key,
    required this.clinicName,
    required this.departments,
  });

  static void show(
    BuildContext context, {
    required String clinicName,
    required List<ClinicDepartmentSummaryEntity> departments,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ClinicAssignedDepartmentsDialog(
        clinicName: clinicName,
        departments: departments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: 580,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primaryTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🩺', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Assigned Departments',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primaryTint,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.primary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  '${departments.length} Active',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            clinicName.isEmpty
                                ? 'Active clinical specialties and triage routing'
                                : 'Licensed medical departments for $clinicName',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: colors.textMuted,
                      ),
                      splashRadius: 18,
                    ),
                  ],
                ),
              ),

              // Department Items List
              Flexible(
                child: departments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 40,
                              color: colors.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No departments currently assigned',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Departments configured by the platform admin will appear here.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: colors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(20),
                        itemCount: departments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final d = departments[index];
                          return _DepartmentTile(department: d);
                        },
                      ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                      : colors.surfaceSecondary.withValues(alpha: 0.5),
                  border: Border(top: BorderSide(color: colors.border)),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

class _DepartmentTile extends StatelessWidget {
  final ClinicDepartmentSummaryEntity department;

  const _DepartmentTile({required this.department});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              department.icon,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        department.name,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryTint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        department.code,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (department.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    department.description,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: colors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _metaChip(
                      colors,
                      Icons.people_outline_rounded,
                      '${department.doctorCount} Doctors',
                    ),
                    _metaChip(
                      colors,
                      Icons.medical_services_outlined,
                      '${department.proceduresCount} Procedures',
                    ),
                    if (department.waitingCount > 0)
                      _metaChip(
                        colors,
                        Icons.hourglass_top_rounded,
                        '${department.waitingCount} in Queue',
                        color: const Color(0xFFF59E0B),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(
    AppColorsExtension colors,
    IconData icon,
    String label, {
    Color? color,
  }) {
    final c = color ?? colors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: c),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: c,
          ),
        ),
      ],
    );
  }
}
