import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'platform_tickets_kpi_card_item.dart';

class PlatformTicketsKpiSecondaryCardsBuilder {
  static List<Widget> buildSecondaryCards({
    required BuildContext context,
    required int activeClinicsCount,
    required String avgResponseTime,
  }) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return [
      PlatformTicketsKpiCardItem(
        tag: 'PARTNER SITES',
        tagColor: isDark ? const Color(0xFF94A3B8) : colors.textMuted,
        label: 'Clinics With Open Cases',
        value: '$activeClinicsCount',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Multi-tenant',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFA5B4FC)
                      : const Color(0xFF4338CA),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Reporting incidents',
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
        icon: Icons.domain_rounded,
        iconColor: const Color(0xFFA5B4FC),
        iconBgColor: const Color(0xFF312E81).withValues(alpha: 0.35),
        borderColor: const Color(0xFF312E81).withValues(alpha: 0.35),
      ),
      PlatformTicketsKpiCardItem(
        tag: 'NETWORK AVG',
        tagColor: const Color(0xFF10B981),
        label: 'Avg Initial Response',
        value: avgResponseTime,
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 9.5)),
            const SizedBox(width: 3),
            Text(
              'Under 5m SLA target',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF34D399)
                    : const Color(0xFF059669),
              ),
            ),
          ],
        ),
        icon: Icons.timer_outlined,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF064E3B).withValues(alpha: 0.35),
        borderColor: const Color(0xFF064E3B).withValues(alpha: 0.35),
      ),
    ];
  }
}
