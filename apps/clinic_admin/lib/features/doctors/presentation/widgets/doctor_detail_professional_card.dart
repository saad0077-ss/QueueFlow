import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';

class DoctorDetailProfessionalCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailProfessionalCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = [
      ('SPECIALIZATION', doctor.specialty),
      ('DEPARTMENT', doctor.department),
      ('QUALIFICATIONS', doctor.qualifications),
      ('EXPERIENCE', doctor.experienceYears > 0 ? '${doctor.experienceYears} years' : ''),
      ('EMPLOYMENT TYPE', doctor.employmentType),
    ];

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
          Row(
            children: [
              Icon(Icons.work_outline_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Professional Details',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 480;
              final colWidth = isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 2;

              return Wrap(
                spacing: 24,
                runSpacing: 18,
                children: [
                  for (final (label, val) in items)
                    SizedBox(
                      width: colWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            val.isNotEmpty ? val : '—',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              letterSpacing: label.contains('REGISTRATION') ? 0.3 : 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
