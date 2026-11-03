import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorDetailReviewsCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailReviewsCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final reviews = doctor.reviews;
    final avgRating = doctor.averageRating;

    return Container(
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorColors.border),
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
                  const Icon(Icons.star_rounded, size: 16, color: DoctorColors.cyan),
                  const SizedBox(width: 8),
                  Text(
                    'Patient Reviews',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                style: GoogleFonts.inter(fontSize: 12.5, color: DoctorColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: DoctorColors.border, height: 1),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFFF59E0B),
                          );
                        }),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Based on ${reviews.length} verified review${reviews.length == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(fontSize: 11.5, color: DoctorColors.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: DoctorColors.border, height: 1),
            const SizedBox(height: 16),
          ],

          // Review list
          if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No patient reviews yet.',
                style: GoogleFonts.inter(fontSize: 13, color: DoctorColors.muted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: DoctorColors.border, height: 1),
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
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Text(
                        r.initials,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: DoctorColors.cyan,
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
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                r.date,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: DoctorColors.subtle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  r.rating.round().clamp(1, 5),
                                  (i) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '· ${r.service}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: DoctorColors.cyan,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            r.comment,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: const Color(0xFFCBD5E1),
                              height: 1.45,
                            ),
                          ),
                          if (r.tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: r.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF334155)),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                );
                              }).toList(),
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
