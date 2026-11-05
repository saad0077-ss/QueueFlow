import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';

class DoctorDetailReviewsCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailReviewsCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reviews = doctor.reviews;
    final avgRating = doctor.averageRating;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 16, color: colors.info),
                  const SizedBox(width: 8),
                  Text(
                    'Patient Reviews',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 16),

          // Rating summary
          if (reviews.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: colors.ratingGold,
                          );
                        }),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Based on ${reviews.length} verified review${reviews.length == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 16),
          ],

          // Review list
          if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No patient reviews yet.',
                style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: colors.border, height: 1),
              ),
              itemBuilder: (context, index) {
                final r = reviews[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        r.initials,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colors.info,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  r.userName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                r.date,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: colors.textSubtle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: List.generate(5, (sIdx) {
                              final filled = sIdx < r.rating.round();
                              return Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: filled ? colors.ratingGold : colors.border,
                              );
                            }),
                          ),
                          if (r.comment.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              r.comment,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                height: 1.45,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
