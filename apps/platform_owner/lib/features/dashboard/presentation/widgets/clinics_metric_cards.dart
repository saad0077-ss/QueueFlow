import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicsMetricCards extends StatelessWidget {
  final int totalClinics;
  final int activePractices;
  final int invitedClinics;
  final int totalDoctors;
  final int appointmentsMonth;
  final int totalMrr;

  const ClinicsMetricCards({
    super.key,
    required this.totalClinics,
    required this.activePractices,
    required this.invitedClinics,
    required this.totalDoctors,
    required this.appointmentsMonth,
    required this.totalMrr,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      AppMetricCard(
        tag: 'TOTAL CLINICS',
        tagColor: const Color(0xFF38BDF8),
        label: 'Total Clinics',
        value: _fmt(totalClinics),
        icon: Icons.domain_rounded,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          invitedClinics > 0
              ? '$invitedClinics awaiting activation'
              : 'All onboarded',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'ACTIVE PRACTICES',
        tagColor: const Color(0xFF10B981),
        hasDot: activePractices > 0,
        dotColor: const Color(0xFF10B981),
        label: 'Active Clinics',
        value: _fmt(activePractices),
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          totalClinics == 0
              ? 'No clinics yet'
              : '${(activePractices * 100 / totalClinics).round()}% of network',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'CLINICAL ROSTER',
        tagColor: const Color(0xFFA855F7),
        label: 'Doctors on Roster',
        value: _fmt(totalDoctors),
        icon: Icons.medical_services_outlined,
        iconColor: const Color(0xFFC084FC),
        iconBgColor: const Color(0xFF581C87).withValues(alpha: 0.35),
        borderColor: const Color(0xFF7E22CE).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Across all clinics',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'PATIENT VOLUME',
        tagColor: const Color(0xFFF59E0B),
        label: 'Appointments This Month',
        value: _fmt(appointmentsMonth),
        icon: Icons.calendar_today_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFFB45309).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Queue tickets since the 1st',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'PLATFORM MRR',
        tagColor: const Color(0xFF14B8A6),
        label: 'Monthly Recurring Revenue',
        value: '₹${_fmt(totalMrr)}',
        icon: Icons.credit_card_rounded,
        iconColor: const Color(0xFF2DD4BF),
        iconBgColor: const Color(0xFF134E4A).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0D9488).withValues(alpha: 0.4),
        bottomWidget: Text(
          'From active subscriptions',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final colCount = w >= 1200 ? 5 : (w >= 900 ? 3 : (w >= 560 ? 2 : 1));
        const spacing = 12.0;
        final itemWidth = (w - ((colCount - 1) * spacing)) / colCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
  }

  String _fmt(num n) {
    final str = n.round().toString();
    if (str.length <= 3) return str;
    return str.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
