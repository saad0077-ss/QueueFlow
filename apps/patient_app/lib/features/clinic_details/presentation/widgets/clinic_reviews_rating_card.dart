import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ClinicReviewsRatingCard extends StatelessWidget {
  final double rating;
  final int reviewCount;
  /// Share of reviews per star, ordered 5★ → 1★.
  final List<int> starPercents;
  final VoidCallback onRateClinic;

  const ClinicReviewsRatingCard({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.starPercents,
    required this.onRateClinic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    reviewCount > 0 ? rating.toStringAsFixed(1) : '–',
                    style: GoogleFonts.robotoMono(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkInk,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating.floor()
                                ? Icons.star
                                : (i < rating ? Icons.star_half : Icons.star_border),
                            color: AppColors.warning,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reviewCount > 0
                            ? 'Based on $reviewCount review${reviewCount == 1 ? '' : 's'}'
                            : 'No ratings yet',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.darkInkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onRateClinic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('⭐ Rate Clinic'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _buildBar('${5 - i} ★', i < starPercents.length ? starPercents[i] : 0),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(String starLabel, int percent) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            starLabel,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.darkInkMuted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent / 100.0,
              minHeight: 6,
              backgroundColor: AppColors.darkBgApp,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '$percent%',
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.darkInkMuted),
          ),
        ),
      ],
    );
  }
}
