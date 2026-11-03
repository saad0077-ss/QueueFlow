import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorDetailStatsRow extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailStatsRow({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        'TOTAL APPOINTMENTS',
        doctor.totalAppointments.toString(),
        'All time',
      ),
      (
        'COMPLETED',
        doctor.completedAppointments.toString(),
        doctor.totalAppointments > 0 ? '${doctor.completionRate}% of total' : '0% of total',
      ),
      (
        'UPCOMING',
        doctor.upcomingAppointments.toString(),
        'Scheduled & checked-in',
      ),
      (
        'PATIENT RATING',
        doctor.reviews.isNotEmpty ? doctor.averageRating.toStringAsFixed(1) : '—',
        doctor.reviews.isNotEmpty
            ? '${doctor.reviews.length} review${doctor.reviews.length == 1 ? '' : 's'}'
            : 'No reviews yet',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 4
              : (constraints.maxWidth >= 500 ? 2 : 1);

          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final (label, val, hint) in stats)
                SizedBox(
                  width: columns == 4
                      ? (constraints.maxWidth - (14 * 3)) / 4
                      : (columns == 2
                          ? (constraints.maxWidth - 14) / 2
                          : constraints.maxWidth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: DoctorColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DoctorColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: DoctorColors.muted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          val,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hint,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: DoctorColors.subtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
  }
}
