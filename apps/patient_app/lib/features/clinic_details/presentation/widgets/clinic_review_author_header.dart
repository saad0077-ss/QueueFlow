import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/clinic_review_item.dart';

class ClinicReviewAuthorHeader extends StatelessWidget {
  final ClinicReviewItem review;

  const ClinicReviewAuthorHeader({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Text(
            review.initials,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryLight,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  review.patientName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkInk,
                  ),
                ),
                if (review.verified) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'VERIFIED VISIT',
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${review.doctor.isNotEmpty ? "${review.doctor} · " : ""}${review.date}',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.darkInkMuted),
            ),
          ],
        ),
      ],
    );
  }
}
