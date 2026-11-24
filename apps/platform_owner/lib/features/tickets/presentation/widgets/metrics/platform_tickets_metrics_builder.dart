import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'platform_tickets_metric_card_item.dart';
import 'platform_tickets_secondary_metrics_builder.dart';

class PlatformTicketsMetricsBuilder {
  static List<Widget> buildCards({
    required BuildContext context,
    required int totalCount,
    required int atRiskCount,
    required int activeClinicsCount,
    required String avgResponseTime,
  }) {
    final colors = context.colors;
    final isDark = colors.isDark;

    final primaryCards = [
      PlatformTicketsMetricCardItem(
        tag: 'ALL NETWORKS',
        tagColor: isDark ? const Color(0xFF94A3B8) : colors.textMuted,
        label: 'Global Tickets',
        value: '$totalCount',
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4.5,
                    height: 4.5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Live stream',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Across all partner clinics',
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
        icon: Icons.confirmation_number_outlined,
        iconColor: const Color(0xFF60A5FA),
        iconBgColor: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
        borderColor: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
      ),
      PlatformTicketsMetricCardItem(
        tag: 'ACTION REQ',
        tagColor: const Color(0xFFEF4444),
        hasRedDot: true,
        label: 'SLA At Risk / Urgent',
        value: '$atRiskCount',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 9.5)),
            const SizedBox(width: 3),
            Text(
              'Breaching < 15m',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF87171),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Needs platform intervention',
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
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFF87171),
        iconBgColor: const Color(0xFF7F1D1D).withValues(alpha: 0.35),
        borderColor: const Color(0xFF7F1D1D).withValues(alpha: 0.4),
      ),
    ];

    final secondaryCards =
        PlatformTicketsSecondaryMetricsBuilder.buildSecondaryCards(
          context: context,
          activeClinicsCount: activeClinicsCount,
          avgResponseTime: avgResponseTime,
        );

    return [...primaryCards, ...secondaryCards];
  }
}
