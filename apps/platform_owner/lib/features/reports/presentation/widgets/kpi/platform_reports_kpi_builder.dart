import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../tickets/presentation/widgets/kpi/platform_tickets_kpi_card_item.dart';
import '../../../domain/entities/platform_report_entity.dart';
import 'platform_reports_kpi_secondary_builder.dart';

class PlatformReportsKpiBuilder {
  static List<Widget> buildCards({
    required BuildContext context,
    required PlatformReportEntity report,
  }) {
    final colors = context.colors;

    final primaryCards = [
      PlatformTicketsKpiCardItem(
        tag: 'NETWORK PATIENT VOLUME',
        tagColor: const Color(0xFF60A5FA),
        label: 'Total Network Patients',
        value: formatNumber(report.totalPatients),
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            buildBadge(
              '↑ ${report.patientsGrowthPercentage}% MoM',
              const Color(0xFF10B981),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Across ${report.connectedClinics} connected clinics',
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
        icon: Icons.people_alt_outlined,
        iconColor: const Color(0xFF60A5FA),
        iconBgColor: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
        borderColor: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
      ),
      PlatformTicketsKpiCardItem(
        tag: 'LOBBY SPEED',
        tagColor: const Color(0xFF2DD4BF),
        label: 'Avg Network Wait',
        value: '${report.avgWaitMinutes} min',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            buildBadge(
              '↓ ${report.waitReductionMinutes}m faster',
              const Color(0xFF10B981),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Target <15 min (94% SLA)',
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
        icon: Icons.schedule_rounded,
        iconColor: const Color(0xFF2DD4BF),
        iconBgColor: const Color(0xFF134E4A).withValues(alpha: 0.35),
        borderColor: const Color(0xFF134E4A).withValues(alpha: 0.4),
      ),
      PlatformTicketsKpiCardItem(
        tag: 'QUEUE COMPLETION',
        tagColor: const Color(0xFF38BDF8),
        label: 'Completion Rate',
        value: '${report.completionRatePercentage}%',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            buildBadge('<4% Drop-off', const Color(0xFF10B981)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'High triage throughput',
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
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0369A1).withValues(alpha: 0.4),
      ),
    ];

    final secondaryCards =
        PlatformReportsKpiSecondaryBuilder.buildSecondaryCards(
          context: context,
          report: report,
        );

    return [...primaryCards, ...secondaryCards];
  }

  static Widget buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  static String formatCurrency(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    }
    return formatNumber(amount);
  }
}
