import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

/// Summary metric cards shown above the appointments list.
class AppointmentsStatsRow extends StatelessWidget {
  final List<ClinicAppointmentEntity> appointments;

  const AppointmentsStatsRow({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = appointments.length;
    final upcoming = appointments
        .where((a) => a.isUpcoming || a.isConfirmed)
        .length;
    final checkedIn = appointments.where((a) => a.isCheckedIn).length;
    final completed = appointments.where((a) => a.isCompleted).length;
    final cancelled = appointments.where((a) => a.isCancelled).length;

    final cards = [
      AppMetricCard(
        tag: 'TOTAL',
        tagColor: const Color(0xFF38BDF8),
        label: 'Total Bookings',
        value: '$total',
        icon: Icons.event_note_rounded,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          'All registered appointments',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'SCHEDULED',
        tagColor: const Color(0xFF60A5FA),
        label: 'Upcoming Visits',
        value: '$upcoming',
        icon: Icons.schedule_rounded,
        iconColor: const Color(0xFF60A5FA),
        iconBgColor: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
        borderColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Confirmed & pending',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'ARRIVED',
        tagColor: const Color(0xFF10B981),
        hasDot: checkedIn > 0,
        dotColor: const Color(0xFF10B981),
        label: 'Checked In',
        value: '$checkedIn',
        icon: Icons.how_to_reg_rounded,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          checkedIn > 0 ? 'Patients in waiting area' : 'None waiting',
          style: GoogleFonts.inter(
            fontSize: 9.5,
            color: checkedIn > 0 ? const Color(0xFF34D399) : colors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'CONSULTED',
        tagColor: const Color(0xFF14B8A6),
        label: 'Completed',
        value: '$completed',
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF2DD4BF),
        iconBgColor: const Color(0xFF134E4A).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0D9488).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Finished consultation',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'CANCELLED',
        tagColor: const Color(0xFFEF4444),
        label: 'Cancelled / Missed',
        value: '$cancelled',
        icon: Icons.cancel_outlined,
        iconColor: const Color(0xFFF87171),
        iconBgColor: const Color(0xFF7F1D1D).withValues(alpha: 0.35),
        borderColor: const Color(0xFFDC2626).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Cancelled or dropped',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final columns = w >= 1100 ? 5 : (w >= 700 ? 3 : (w >= 440 ? 2 : 1));
        const gap = 12.0;
        final itemWidth = (w - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final c in cards)
              SizedBox(
                width: itemWidth,
                child: c,
              ),
          ],
        );
      },
    );
  }
}
