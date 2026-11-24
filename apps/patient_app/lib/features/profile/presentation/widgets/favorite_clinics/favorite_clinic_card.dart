import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/favorite_clinic_entity.dart';

class FavoriteClinicCard extends StatelessWidget {
  final FavoriteClinicEntity clinic;
  final VoidCallback onUnfavorite;
  final VoidCallback onBook;
  final VoidCallback onLiveQueue;
  final VoidCallback onCall;

  const FavoriteClinicCard({
    super.key,
    required this.clinic,
    required this.onUnfavorite,
    required this.onBook,
    required this.onLiveQueue,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFast = clinic.waitingCount <= 2;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Header Row: Avatar, Title & Doctor, Heart Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  clinic.iconEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
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
                    const SizedBox(height: 2),
                    Text(
                      '${clinic.department} · ${clinic.topDoctor}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: colors.textMuted,
                      ),
                    ),
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
          ),
          const SizedBox(height: 12),

          // 2. Meta Row: Rating, Distance, Live Queue Chip
          Container(
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
                      clinic.rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '(${clinic.reviewsCount})',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: colors.textMuted,
                      ),
                    ),
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
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isFast
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isFast
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${clinic.waitingCount} in queue (~${clinic.estWaitTime})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isFast
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 3. Open hours & Address
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🕒 ${clinic.openHours}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
              Text(
                clinic.address.split(',').first,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Action Buttons Grid
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onBook,
                  icon: const Text('📅', style: TextStyle(fontSize: 13)),
                  label: Text(
                    'Book',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onLiveQueue,
                  icon: const Text('🎟️', style: TextStyle(fontSize: 13)),
                  label: Text(
                    'Live Queue',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colors.primaryTint,
                    foregroundColor: colors.primary,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onCall,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  alignment: Alignment.center,
                  child: const Text('📞', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
