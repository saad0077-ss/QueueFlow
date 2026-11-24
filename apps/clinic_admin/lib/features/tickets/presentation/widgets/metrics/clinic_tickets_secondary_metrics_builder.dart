import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_tickets_metric_card_item.dart';

class ClinicTicketsSecondaryMetricsBuilder {
  static List<Widget> buildSecondaryCards({
    required BuildContext context,
    required int inProgressCount,
    required int resolvedCount,
  }) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return [
      ClinicTicketsMetricCardItem(
        tag: 'ACTIVE COUNTERS',
        tagColor: const Color(0xFF38BDF8),
        label: 'Being Handled Now',
        value: '$inProgressCount',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0C4A6E)
                    : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Desk Active',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF38BDF8),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Staff actively serving',
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
        icon: Icons.support_agent_rounded,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
      ),
      ClinicTicketsMetricCardItem(
        tag: 'COMPLETED TODAY',
        tagColor: const Color(0xFF10B981),
        label: 'Resolved Inquiries',
        value: '$resolvedCount',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 9.5)),
            const SizedBox(width: 3),
            Text(
              'Speedy turnaround',
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
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF064E3B).withValues(alpha: 0.35),
        borderColor: const Color(0xFF064E3B).withValues(alpha: 0.35),
      ),
    ];
  }
}
