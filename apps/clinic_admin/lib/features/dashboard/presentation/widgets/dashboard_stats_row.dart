import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Key performance indicator cards on the clinic dashboard overview:
/// 1. Today's Appointments
/// 2. Customers Waiting (live queue)
/// 3. Customers Served today
/// 4. Checked In
class DashboardStatsRow extends StatelessWidget {
  final int waitingCount;
  final int todayAppointmentsCount;
  final int servedCount;
  final int checkedInCount;

  const DashboardStatsRow({
    super.key,
    required this.waitingCount,
    this.todayAppointmentsCount = 0,
    this.servedCount = 0,
    this.checkedInCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = <Widget>[
      AppMetricCard(
        tag: 'APPOINTMENTS',
        tagColor: const Color(0xFF38BDF8),
        label: "Today's Appointments",
        value: '$todayAppointmentsCount',
        icon: Icons.calendar_month_outlined,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Scheduled consultations',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'QUEUE LIVE',
        tagColor: const Color(0xFFF59E0B),
        hasDot: waitingCount > 0,
        dotColor: const Color(0xFFF59E0B),
        label: 'Customers Waiting',
        value: '$waitingCount',
        icon: Icons.people_outline_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFFD97706).withValues(alpha: 0.4),
        bottomWidget: Text(
          waitingCount > 0 ? 'Active in clinic lobby' : 'Queue clear',
          style: GoogleFonts.inter(
            fontSize: 9.5,
            color: waitingCount > 0 ? const Color(0xFFFBBF24) : colors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'COMPLETED',
        tagColor: const Color(0xFF10B981),
        label: 'Customers Served',
        value: '$servedCount',
        icon: Icons.check_rounded,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Completed consultations',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'ARRIVED',
        tagColor: const Color(0xFFA855F7),
        label: 'Checked In',
        value: '$checkedInCount',
        icon: Icons.how_to_reg_outlined,
        iconColor: const Color(0xFFC084FC),
        iconBgColor: const Color(0xFF581C87).withValues(alpha: 0.35),
        borderColor: const Color(0xFF7E22CE).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Present in waiting room',
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
