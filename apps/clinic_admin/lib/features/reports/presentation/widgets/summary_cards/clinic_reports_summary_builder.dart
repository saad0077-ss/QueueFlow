import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_report_data.dart';

class ClinicReportsSummaryBuilder {
  static List<Widget> buildCards(
    BuildContext context,
    ClinicReportData data,
  ) {
    final colors = context.colors;

    return [
      AppMetricCard(
        tag: 'PATIENT FOOTFALL',
        tagColor: const Color(0xFF38BDF8),
        hasDot: true,
        dotColor: const Color(0xFF38BDF8),
        label: 'Total Patient Visits',
        value: '${data.totalVisits}',
        valueColor: colors.textPrimary,
        icon: Icons.people_alt_outlined,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Row(
          children: [
            const AppMetricTrendPill(
              text: '↑ Active',
              type: AppTrendType.neutral,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${data.bookedCount} Booked • ${data.walkInCount} Walk-ins',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  color: colors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      AppMetricCard(
        tag: 'CONSULTATIONS DONE',
        tagColor: const Color(0xFF10B981),
        hasDot: true,
        dotColor: const Color(0xFF10B981),
        label: 'Completed Visits',
        value: '${data.completedVisits}',
        valueColor: colors.textPrimary,
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Row(
          children: [
            AppMetricTrendPill(
              text: '${data.completionRate}% Done',
              type: AppTrendType.up,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Finished consultations',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  color: colors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      AppMetricCard(
        tag: 'MISSED / DROPPED',
        tagColor: const Color(0xFFEF4444),
        hasDot: true,
        dotColor: const Color(0xFFEF4444),
        label: 'No-Shows & Cancellations',
        value: '${data.cancellationRate}%',
        valueColor: colors.textPrimary,
        icon: Icons.cancel_outlined,
        iconColor: const Color(0xFFF87171),
        iconBgColor: const Color(0xFF7F1D1D).withValues(alpha: 0.35),
        borderColor: const Color(0xFFDC2626).withValues(alpha: 0.4),
        bottomWidget: Row(
          children: [
            AppMetricTrendPill(
              text: '${data.cancelledVisits} Dropped',
              type: AppTrendType.down,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Cancelled or lobby drop',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  color: colors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
