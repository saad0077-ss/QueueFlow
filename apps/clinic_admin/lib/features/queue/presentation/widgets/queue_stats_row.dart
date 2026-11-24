import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueStatsRow extends StatelessWidget {
  final int totalDepartments;
  final int totalServices;
  final int waitingCount;
  final String avgWaitTime;

  const QueueStatsRow({
    super.key,
    required this.totalDepartments,
    required this.totalServices,
    required this.waitingCount,
    this.avgWaitTime = '15 min',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      AppMetricCard(
        tag: 'DEPARTMENTS',
        tagColor: const Color(0xFF38BDF8),
        label: 'Departments Active',
        value: totalDepartments.toString(),
        icon: Icons.local_hospital_outlined,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Clinical branches operational',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'OPD SERVICES',
        tagColor: const Color(0xFF10B981),
        label: 'Services Configured',
        value: totalServices.toString(),
        icon: Icons.assignment_outlined,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Ready for patient triage',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'QUEUE LOAD',
        tagColor: const Color(0xFFF59E0B),
        hasDot: waitingCount > 0,
        dotColor: const Color(0xFFF59E0B),
        label: 'Patients Waiting',
        value: waitingCount.toString(),
        icon: Icons.hourglass_empty_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFFD97706).withValues(alpha: 0.4),
        bottomWidget: Text(
          waitingCount > 0 ? 'Active in clinic lobby' : 'No queue buildup',
          style: GoogleFonts.inter(
            fontSize: 9.5,
            color: waitingCount > 0 ? const Color(0xFFFBBF24) : colors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'WAIT SPEED',
        tagColor: const Color(0xFFA855F7),
        label: 'Average Wait Time',
        value: avgWaitTime,
        icon: Icons.timer_outlined,
        iconColor: const Color(0xFFC084FC),
        iconBgColor: const Color(0xFF581C87).withValues(alpha: 0.35),
        borderColor: const Color(0xFF7E22CE).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Queue turnaround speed',
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
