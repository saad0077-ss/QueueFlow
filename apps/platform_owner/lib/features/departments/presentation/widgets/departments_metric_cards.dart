import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class DepartmentsMetricCards extends StatelessWidget {
  final int totalDepartments;
  final int activeSpecialties;
  final int doctorsAssigned;
  final int monthlyVisits;

  const DepartmentsMetricCards({
    super.key,
    required this.totalDepartments,
    required this.activeSpecialties,
    required this.doctorsAssigned,
    required this.monthlyVisits,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      AppMetricCard(
        tag: 'SPECIALTIES',
        tagColor: const Color(0xFF38BDF8),
        label: 'Total Departments',
        value: totalDepartments.toString(),
        icon: Icons.local_hospital_outlined,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Configured departments',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'ACTIVE',
        tagColor: const Color(0xFF10B981),
        hasDot: activeSpecialties > 0,
        dotColor: const Color(0xFF10B981),
        label: 'Active Specialties',
        value: activeSpecialties.toString(),
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Available across clinics',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'STAFFING',
        tagColor: const Color(0xFF14B8A6),
        label: 'Doctors Assigned',
        value: doctorsAssigned.toString(),
        icon: Icons.badge_outlined,
        iconColor: const Color(0xFF2DD4BF),
        iconBgColor: const Color(0xFF134E4A).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0D9488).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Specialists on roster',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'CONSULTATIONS',
        tagColor: const Color(0xFFF59E0B),
        label: 'Monthly Consultations',
        value: _formatNum(monthlyVisits),
        icon: Icons.bolt_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFFB45309).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Triage visits completed',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final colCount = isCompact ? 2 : 4;
        final itemWidth =
            (constraints.maxWidth - ((colCount - 1) * 12)) / colCount;

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

  String _formatNum(num n) {
    final str = n.round().toString();
    if (str.length <= 3) return str;
    return str.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
