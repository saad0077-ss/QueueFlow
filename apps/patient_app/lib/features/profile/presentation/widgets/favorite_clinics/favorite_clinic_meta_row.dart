import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/favorite_clinic_entity.dart';

class FavoriteClinicMetaRow extends StatelessWidget {
  final FavoriteClinicEntity clinic;

  const FavoriteClinicMetaRow({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasRating = clinic.reviewsCount > 0 && clinic.rating > 0;
    final hasDist = clinic.distance.trim().isNotEmpty;
    final isFast = clinic.waitingCount <= 2;
    final queueColor = isFast ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final queueLabel = clinic.waitingCount > 0
        ? '${clinic.waitingCount} in queue${clinic.estWaitTime.trim().isNotEmpty ? ' (~${clinic.estWaitTime})' : ''}'
        : '0 waiting';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 3),
              Text(
                hasRating ? clinic.rating.toStringAsFixed(1) : 'New',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              if (clinic.reviewsCount > 0) ...[
                const SizedBox(width: 2),
                Text(
                  '(${clinic.reviewsCount})',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: colors.textMuted,
                  ),
                ),
              ],
              if (hasDist) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '·',
                    style: TextStyle(
                      color: colors.textSubtle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text('📍', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 3),
                Text(
                  clinic.distance,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: colors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: queueColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: queueColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      queueLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: queueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
