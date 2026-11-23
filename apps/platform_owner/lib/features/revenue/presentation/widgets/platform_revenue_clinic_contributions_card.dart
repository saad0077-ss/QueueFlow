import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'cards/platform_revenue_clinic_item_row.dart';
import 'cards/platform_revenue_empty_clinics.dart';

class PlatformRevenueClinicContributionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> clinicRevenueItems;
  final List<Map<String, dynamic>> recentInvoices;

  const PlatformRevenueClinicContributionsCard({
    super.key,
    required this.clinicRevenueItems,
    this.recentInvoices = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final count = clinicRevenueItems.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partner Clinic Revenue Contributions',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time active subscription fees & practice billing run-rate',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count ENROLLED CLINIC${count == 1 ? '' : 'S'}',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (clinicRevenueItems.isEmpty)
            const PlatformRevenueEmptyClinics()
          else
            Column(
              children: [
                for (int i = 0; i < clinicRevenueItems.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  PlatformRevenueClinicItemRow(item: clinicRevenueItems[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
