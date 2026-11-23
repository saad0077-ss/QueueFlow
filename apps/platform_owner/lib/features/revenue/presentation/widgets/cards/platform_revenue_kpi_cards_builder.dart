import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../tickets/presentation/widgets/kpi/platform_tickets_kpi_card_item.dart';
import '../../bloc/platform_revenue_state.dart';

class PlatformRevenueKpiCardsBuilder {
  static List<Widget> buildCards({
    required BuildContext context,
    required PlatformRevenueState state,
  }) {
    final c = context.colors;
    final clinicCount = state.activeClinicsCount;
    final clinicText =
        '$clinicCount Active Clinic${clinicCount == 1 ? '' : 's'}';

    return [
      _card(
        tag: 'GROSS REVENUE',
        tagColor: const Color(0xFF10B981),
        label: 'Total Gross Revenue',
        value: state.grossRevenue,
        badgeText: 'Live Collections',
        desc: 'Active SaaS & invoice settlements',
        icon: Icons.account_balance_wallet_outlined,
        accent: const Color(0xFF10B981),
        bgAccent: const Color(0xFF064E3B),
        colors: c,
      ),
      _card(
        tag: 'RECURRING REVENUE',
        tagColor: const Color(0xFF3B82F6),
        label: 'Monthly Recurring (MRR)',
        value: state.mrrAmount,
        badgeText: clinicText,
        desc: 'Recurring partner subscriptions',
        icon: Icons.trending_up_rounded,
        accent: const Color(0xFF3B82F6),
        bgAccent: const Color(0xFF1E3A8A),
        colors: c,
      ),
      _card(
        tag: 'ANNUAL RUN RATE',
        tagColor: const Color(0xFFA855F7),
        label: 'Annualized Run Rate (ARR)',
        value: state.arrAmount,
        badgeText: '12x Run-Rate',
        desc: 'Annualized recurring run-rate',
        icon: Icons.diamond_outlined,
        accent: const Color(0xFFA855F7),
        bgAccent: const Color(0xFF581C87),
        colors: c,
      ),
      _card(
        tag: 'PRACTICE ARPU',
        tagColor: const Color(0xFFF59E0B),
        label: 'Avg Revenue / Clinic',
        value: state.arpuAmount,
        badgeText: 'Per Partner Site',
        desc: 'Net average practice contribution',
        icon: Icons.domain_rounded,
        accent: const Color(0xFFF59E0B),
        bgAccent: const Color(0xFF78350F),
        colors: c,
      ),
    ];
  }

  static Widget _card({
    required String tag,
    required Color tagColor,
    required String label,
    required String value,
    required String badgeText,
    required String desc,
    required IconData icon,
    required Color accent,
    required Color bgAccent,
    required AppColorsExtension colors,
  }) {
    return PlatformTicketsKpiCardItem(
      tag: tag,
      tagColor: tagColor,
      label: label,
      value: value,
      valueColor: colors.textPrimary,
      bottomWidget: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              desc,
              style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      icon: icon,
      iconColor: accent,
      iconBgColor: bgAccent.withValues(alpha: 0.35),
      borderColor: bgAccent.withValues(alpha: 0.4),
    );
  }
}
