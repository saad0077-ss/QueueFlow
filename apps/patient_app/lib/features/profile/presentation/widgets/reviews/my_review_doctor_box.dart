import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/doctor_avatar.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/patient_review_entity.dart';

class MyReviewDoctorBox extends StatelessWidget {
  final PatientReviewEntity review;
  final bool isDental;

  const MyReviewDoctorBox({
    super.key,
    required this.review,
    required this.isDental,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final docRating =
        (review.doctorRating > 0 ? review.doctorRating : review.rating)
            .toDouble();
    final stars = docRating.clamp(1.0, 5.0).round();
    final specialty = review.doctorSpecialty.isNotEmpty
        ? review.doctorSpecialty
        : (isDental ? 'Senior Dental Surgeon' : 'Chief General Physician');
    final docTags = review.doctorTags.isNotEmpty
        ? review.doctorTags
        : (isDental
              ? const ['Gentle Hand', 'Painless Treatment', 'Polite & Reassuring']
              : const ['Attentive Listener', 'Accurate Diagnosis', 'Clear Explanation']);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2563EB).withValues(alpha: 0.08),
            const Color(0xFF7C3AED).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.22)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorPhotoAvatar(
                photoUrl: review.doctorPhotoUrl,
                radius: 19,
                backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
                borderColor: const Color(0xFF7C3AED).withValues(alpha: 0.45),
                borderWidth: 1.5,
                fallback: Text(
                  DoctorPhotoAvatar.initialsFor(review.doctorName),
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF60A5FA),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.doctorName,
                            style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w800, color: colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Doctor Rating',
                            style: GoogleFonts.inter(
                              fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(specialty, style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      '⭐ ${docRating.toStringAsFixed(1)}',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFFF59E0B)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${'★' * stars} Excellent',
                    style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
                  ),
                ],
              ),
            ],
          ),
          if (docTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 4, children: [for (final dt in docTags) _tagPill(dt)]),
          ],
        ],
      ),
    );
  }

  Widget _tagPill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.25)),
    ),
    child: Text('👨‍⚕️ $label', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF7C3AED))),
  );
}
