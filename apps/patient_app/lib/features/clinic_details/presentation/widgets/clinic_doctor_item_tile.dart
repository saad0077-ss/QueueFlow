import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/doctor_avatar.dart';
import '../../domain/entities/clinic_doctor_item.dart';

class ClinicDoctorItemTile extends StatelessWidget {
  final ClinicDoctorItem doctor;
  final VoidCallback? onTap;
  final VoidCallback? onRate;

  const ClinicDoctorItemTile({
    super.key,
    required this.doctor,
    this.onTap,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                DoctorPhotoAvatar(
                  photoUrl: doctor.photoUrl,
                  radius: 22,
                  backgroundColor: colors.primaryTint,
                  borderColor: colors.primary.withValues(alpha: 0.5),
                  fallback: Text(
                    doctor.initials,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (doctor.department.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          doctor.department,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: colors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      _buildAvailabilityPill(doctor.isAvailable, colors),
                    ],
                  ),
                ),
                if (onRate != null) _buildRateButton(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Star + average rating; tapping it opens the rating dialog.
  Widget _buildRateButton(AppColorsExtension colors) {
    final rated = doctor.reviewCount > 0;
    return InkWell(
      onTap: onRate,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              rated ? Icons.star_rounded : Icons.star_outline_rounded,
              color: colors.ratingGold,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              rated ? doctor.rating.toStringAsFixed(1) : 'Rate',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityPill(bool available, AppColorsExtension colors) {
    final bg = available ? colors.badgeOpenBg : colors.surfaceSecondary;
    final fg = available ? colors.badgeOpenText : colors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            available ? 'Available' : 'Unavailable',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
