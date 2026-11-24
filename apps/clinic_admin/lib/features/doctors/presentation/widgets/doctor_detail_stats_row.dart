import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';

class DoctorDetailStatsRow extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;

  const DoctorDetailStatsRow({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      AppMetricCard(
        tag: 'TOTAL APPOINTMENTS',
        tagColor: const Color(0xFF38BDF8),
        label: 'Total Bookings',
        value: doctor.totalAppointments.toString(),
        icon: Icons.calendar_month_outlined,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          'All time patient visits',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'COMPLETED',
        tagColor: const Color(0xFF10B981),
        label: 'Consultations Done',
        value: doctor.completedAppointments.toString(),
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          doctor.totalAppointments > 0
              ? '${doctor.completionRate}% of total'
              : '0% completed',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'UPCOMING',
        tagColor: const Color(0xFF60A5FA),
        label: 'Scheduled Visits',
        value: doctor.upcomingAppointments.toString(),
        icon: Icons.schedule_rounded,
        iconColor: const Color(0xFF60A5FA),
        iconBgColor: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
        borderColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Scheduled & checked-in',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'PATIENT RATING',
        tagColor: const Color(0xFFF59E0B),
        label: 'Average Rating',
        value: doctor.reviews.isNotEmpty
            ? doctor.averageRating.toStringAsFixed(1)
            : '—',
        icon: Icons.star_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFFD97706).withValues(alpha: 0.4),
        bottomWidget: Text(
          doctor.reviews.isNotEmpty
              ? '${doctor.reviews.length} reviews'
              : 'No patient reviews',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final colCount = w >= 900 ? 4 : (w >= 540 ? 2 : 1);
        final itemWidth = (w - ((colCount - 1) * 12)) / colCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
  }
}
