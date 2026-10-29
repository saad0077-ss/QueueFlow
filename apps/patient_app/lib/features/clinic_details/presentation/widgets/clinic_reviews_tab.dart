import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/clinic_review_item.dart';
import 'clinic_review_card.dart';
import 'clinic_reviews_rating_card.dart';

class ClinicReviewsTab extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final List<int> starPercents;
  final List<ClinicReviewItem> reviews;
  final VoidCallback onRateClinic;
  final ValueChanged<String> onHelpful;

  const ClinicReviewsTab({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.starPercents,
    required this.reviews,
    required this.onRateClinic,
    required this.onHelpful,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClinicReviewsRatingCard(
          rating: rating,
          reviewCount: reviewCount,
          starPercents: starPercents,
          onRateClinic: onRateClinic,
        ),
        if (reviews.isEmpty)
          _buildEmptyReviews()
        else
          ...reviews.map(
            (r) => ClinicReviewCard(
              review: r,
              onHelpful: () => onHelpful(r.id),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          const Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.darkInk,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Be the first to share your experience.',
            style: TextStyle(fontSize: 12, color: AppColors.darkInkMuted),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRateClinic,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Write First Review'),
          ),
        ],
      ),
    );
  }
}
