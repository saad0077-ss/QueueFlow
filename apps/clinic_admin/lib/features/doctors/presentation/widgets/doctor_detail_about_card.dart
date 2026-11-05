import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';

class DoctorDetailAboutCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailAboutCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              Icon(Icons.person_outline_rounded, size: 16, color: colors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'About',
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
          const SizedBox(height: 14),
          Text(
            doctor.bio.trim().isNotEmpty
                ? doctor.bio.trim()
                : 'No professional bio provided.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.6,
              color: doctor.bio.trim().isNotEmpty
                  ? colors.textPrimary
                  : colors.textMuted,
              fontStyle: doctor.bio.trim().isNotEmpty
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
