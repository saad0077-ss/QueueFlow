import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/clinic_profile_avatar.dart';
import 'package:patient_app/core/widgets/doctor_avatar.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/favorite_clinic_entity.dart';

class FavoriteClinicHeaderRow extends StatelessWidget {
  final FavoriteClinicEntity clinic;
  final VoidCallback onUnfavorite;

  const FavoriteClinicHeaderRow({
    super.key,
    required this.clinic,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dept = clinic.department.trim();
    final doctor = clinic.topDoctor.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClinicProfileAvatar(
          clinicId: clinic.id,
          clinicName: clinic.name,
          initials: clinic.initials,
          imageVersion: clinic.imageVersion,
          imageUrl: clinic.imageUrl,
          size: 48,
          borderRadius: 14,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      clinic.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 15,
                    color: Color(0xFF10B981),
                  ),
                ],
              ),
              if (dept.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  dept,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
              ],
              if (doctor.isNotEmpty) ...[
                const SizedBox(height: 5),
                Row(
                  children: [
                    DoctorPhotoAvatar(
                      photoUrl: clinic.topDoctorPhotoUrl,
                      radius: 10,
                      backgroundColor: colors.primaryTint,
                      borderColor: colors.primary.withValues(alpha: 0.45),
                      borderWidth: 1,
                      fallback: Text(
                        DoctorPhotoAvatar.initialsFor(doctor),
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doctor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onUnfavorite,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            alignment: Alignment.center,
            child: const Text('❤️', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
