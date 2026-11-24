import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../bloc/platform_revenue_state.dart';

class PlatformRevenueMetricsBuilder {
  static List<Widget> buildCards({
    required BuildContext context,
    required PlatformRevenueState state,
  }) {
    final colors = context.colors;
    final clinicCount = state.activeClinicsCount;
    final clinicText =
        '$clinicCount Active Clinic${clinicCount == 1 ? '' : 's'}';

    return [
      AppMetricCard(
        tag: 'GROSS REVENUE',
        tagColor: const Color(0xFF10B981),
        label: 'Total Gross Revenue',
        value: state.grossRevenue,
        icon: Icons.account_balance_wallet_outlined,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Active SaaS & invoice settlements',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'RECURRING REVENUE',
        tagColor: const Color(0xFF38BDF8),
        label: 'Monthly Recurring (MRR)',
        value: state.mrrAmount,
        icon: Icons.trending_up_rounded,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          clinicText,
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'ANNUAL RUN RATE',
        tagColor: const Color(0xFFA855F7),
        label: 'Annualized Run Rate (ARR)',
        value: state.arrAmount,
        icon: Icons.diamond_outlined,
        iconColor: const Color(0xFFC084FC),
        iconBgColor: const Color(0xFF581C87).withValues(alpha: 0.35),
        borderColor: const Color(0xFF7E22CE).withValues(alpha: 0.4),
        bottomWidget: Text(
          '12x Annualized run-rate',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'PRACTICE ARPU',
        tagColor: const Color(0xFFF59E0B),
        label: 'Avg Revenue / Clinic',
        value: state.arpuAmount,
        icon: Icons.domain_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFFB45309).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Per partner site contribution',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }
}
