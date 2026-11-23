import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/clinic_ranking_entity.dart';
import 'top_clinic_rank_badge.dart';
import 'top_clinic_volume_bar.dart';

class TopClinicItemRow extends StatelessWidget {
  final ClinicRankingEntity clinic;

  const TopClinicItemRow({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TopClinicRankBadge(rank: clinic.rank),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(clinic.colorHex),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                clinic.initials,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      clinic.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _badge(colors, '⭐ ${clinic.rating}', colors.textPrimary),
                  const SizedBox(width: 4),
                  _badge(
                    colors,
                    '⏱️ ${clinic.avgWaitMinutes}m',
                    colors.textMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${clinic.appointments} appts',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${clinic.sharePercentage}%',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TopClinicVolumeBar(
          barWidthPercentage: clinic.barWidthPercentage,
          colorHex: clinic.colorHex,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _badge(AppColorsExtension c, String t, Color tc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: c.isDark ? const Color(0xFF1E293B) : c.surfaceSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        t,
        style: GoogleFonts.inter(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: tc,
        ),
      ),
    );
  }
}
