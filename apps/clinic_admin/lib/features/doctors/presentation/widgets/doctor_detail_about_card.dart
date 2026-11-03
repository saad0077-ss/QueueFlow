import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorDetailAboutCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailAboutCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.person_outline_rounded, size: 16, color: DoctorColors.cyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'About',
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
          const SizedBox(height: 14),
          Text(
            doctor.bio.trim().isNotEmpty
                ? doctor.bio.trim()
                : 'No professional bio provided.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.6,
              color: doctor.bio.trim().isNotEmpty
                  ? const Color(0xFFCBD5E1)
                  : DoctorColors.subtle,
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
