import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/clinic_review_item.dart';
import 'clinic_review_author_header.dart';

class ClinicReviewCard extends StatelessWidget {
  final ClinicReviewItem review;
  final VoidCallback onHelpful;

  const ClinicReviewCard({
    super.key,
    required this.review,
    required this.onHelpful,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClinicReviewAuthorHeader(review: review),
              _buildStarRow(review.rating),
            ],
          ),
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: review.tags.map(_buildTag).toList(),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.darkInk,
            ),
          ),
          const SizedBox(height: 10),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildStarRow(int rating) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: AppColors.warning,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.darkBgApp,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(fontSize: 10, color: AppColors.darkInkMuted),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onHelpful,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                const Text('👍', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  'Helpful (${review.helpfulCount})',
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.darkInkMuted),
                ),
              ],
            ),
          ),
        ),
        Text(
          'QueueFlow Verified Patient',
          style: GoogleFonts.inter(fontSize: 10, color: AppColors.darkInkFaint),
        ),
      ],
    );
  }
}
