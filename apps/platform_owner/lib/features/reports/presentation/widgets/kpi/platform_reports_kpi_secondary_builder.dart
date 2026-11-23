import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../tickets/presentation/widgets/kpi/platform_tickets_kpi_card_item.dart';
import '../../../domain/entities/platform_report_entity.dart';
import 'platform_reports_kpi_builder.dart';

class PlatformReportsKpiSecondaryBuilder {
  static List<Widget> buildSecondaryCards({
    required BuildContext context,
    required PlatformReportEntity report,
  }) {
    final colors = context.colors;

    return [
      PlatformTicketsKpiCardItem(
        tag: 'DOCTOR CAPACITY',
        tagColor: const Color(0xFFFBBF24),
        label: 'Active Doctors',
        value: '${report.activeDoctors}',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            PlatformReportsKpiBuilder.buildBadge(
              '76% Utilization',
              const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '${report.totalDoctorSlots} Slots Allocated',
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
        icon: Icons.medical_services_outlined,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFF78350F).withValues(alpha: 0.4),
      ),
      PlatformTicketsKpiCardItem(
        tag: 'SUBSCRIPTION REVENUE',
        tagColor: const Color(0xFFA855F7),
        label: 'Platform MRR',
        value: '₹${PlatformReportsKpiBuilder.formatCurrency(report.mrrAmount)}',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            PlatformReportsKpiBuilder.buildBadge(
              '↑ ${report.mrrGrowthPercentage}% MoM',
              const Color(0xFFA855F7),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '100% on-time collection',
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
        icon: Icons.currency_rupee_rounded,
        iconColor: const Color(0xFFA855F7),
        iconBgColor: const Color(0xFF581C87).withValues(alpha: 0.35),
        borderColor: const Color(0xFF581C87).withValues(alpha: 0.4),
      ),
    ];
  }
}
