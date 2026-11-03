import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorDetailNoticeBanner extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailNoticeBanner({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    if (doctor.isActiveAccount) return const SizedBox.shrink();

    final isPending = doctor.isPendingAccount;
    final bannerColor = isPending ? DoctorColors.amber : DoctorColors.red;

    final title = isPending ? 'Verification pending' : 'Account inactive';
    final desc = isPending
        ? 'Verify the doctor details before activating. Patients cannot book this doctor yet.'
        : 'This doctor is hidden from patient booking and the live queue. Past appointments and reviews are kept.';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bannerColor.withValues(alpha: 0.2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: bannerColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPending ? Icons.hourglass_top_rounded : Icons.warning_amber_rounded,
                          size: 16,
                          color: bannerColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: bannerColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      desc,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: const Color(0xFFE2E8F0),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
