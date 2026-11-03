import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorDetailProfessionalCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailProfessionalCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('SPECIALIZATION', doctor.specialty),
      ('DEPARTMENT', doctor.department),
      ('QUALIFICATIONS', doctor.qualifications),
      ('EXPERIENCE', doctor.experienceYears > 0 ? '${doctor.experienceYears} years' : ''),
      ('EMPLOYMENT TYPE', doctor.employmentType),
    ];

    return Container(
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorColors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work_outline_rounded, size: 16, color: DoctorColors.cyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Professional Details',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: DoctorColors.border, height: 1),
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
                              color: DoctorColors.subtle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            val.isNotEmpty ? val : '—',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
