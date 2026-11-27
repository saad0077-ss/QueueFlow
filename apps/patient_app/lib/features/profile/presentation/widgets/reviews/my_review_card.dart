import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/clinic_profile_avatar.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/patient_review_entity.dart';
import 'my_review_doctor_box.dart';
import 'my_review_score_footer.dart';

class MyReviewCard extends StatelessWidget {
  final PatientReviewEntity review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyReviewCard({
    super.key,
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDental = review.clinicName.toLowerCase().contains('dent');

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClinicProfileAvatar(
                clinicId: review.clinicId,
                clinicName: review.clinicName,
                imageVersion: review.clinicImageVersion,
                imageUrl: review.clinicImageUrl,
                size: 44,
                borderRadius: 12,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clinicName,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${review.service.isNotEmpty ? review.service : 'Consultation'} • Visit Date: ${review.date}',
                      style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Verified Patient',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (review.doctorName.isNotEmpty) ...[
            MyReviewDoctorBox(review: review, isDental: isDental),
            const SizedBox(height: 10),
          ],
          MyReviewScoreFooter(review: review, onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}
