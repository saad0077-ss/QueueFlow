import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/doctor_avatar.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueHistoryDoctorRow extends StatelessWidget {
  final String doctorName;
  final String photoUrl;
  final Color? textColor;
  final Color? borderColor;
  final double radius;

  const QueueHistoryDoctorRow({
    super.key,
    required this.doctorName,
    required this.photoUrl,
    this.textColor,
    this.borderColor,
    this.radius = 11,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cleanName = doctorName.trim();
    if (cleanName.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_services_outlined, size: 13.5, color: colors.textSubtle),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              'Queue Token Record',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: textColor ?? colors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DoctorPhotoAvatar(
          photoUrl: photoUrl,
          radius: radius,
          backgroundColor: colors.primaryTint,
          borderColor: borderColor ?? colors.primary.withValues(alpha: 0.45),
          borderWidth: 1,
          fallback: Text(
            DoctorPhotoAvatar.initialsFor(cleanName),
            style: GoogleFonts.inter(
              fontSize: radius * 0.8,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            cleanName,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textColor ?? colors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
