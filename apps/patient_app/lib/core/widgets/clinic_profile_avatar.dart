import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_photo.dart';

/// Rounded clinic thumbnail showing the uploaded profile photo with an
/// initials badge fallback.
class ClinicProfileAvatar extends StatelessWidget {
  final String clinicId;
  final String clinicName;
  final int imageVersion;
  final String? imageUrl;
  final String? initials;
  final double size;
  final double borderRadius;

  const ClinicProfileAvatar({
    super.key,
    required this.clinicId,
    required this.clinicName,
    this.imageVersion = 0,
    this.imageUrl,
    this.initials,
    this.size = 44,
    this.borderRadius = 12,
  });

  static String _initialsFor(String name, String? explicit) {
    final clean = explicit?.trim() ?? '';
    if (clean.isNotEmpty) return clean;
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CL';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = _initialsFor(clinicName, initials);

    return Container(
      width: size,
      height: size,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.border),
      ),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: ClinicPhoto(
        clinicId: clinicId,
        imageVersion: imageVersion,
        imageUrl: imageUrl,
        placeholder: Container(
          color: colors.primaryTint,
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: size * 0.31,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
