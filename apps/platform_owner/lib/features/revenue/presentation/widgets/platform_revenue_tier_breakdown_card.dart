import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../billing/presentation/pages/platform_billing_page.dart';
import 'cards/platform_revenue_tier_row.dart';

class PlatformRevenueTierBreakdownCard extends StatelessWidget {
  final String? totalMrr;
  final String? enterpriseAmount;
  final String? enterpriseCount;
  final String? multiAmount;
  final String? multiCount;
  final String? soloAmount;
  final String? soloCount;

  const PlatformRevenueTierBreakdownCard({
    super.key,
    this.totalMrr,
    this.enterpriseAmount,
    this.enterpriseCount,
    this.multiAmount,
    this.multiCount,
    this.soloAmount,
    this.soloCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

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
                      'Revenue by Subscription Tier',
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
                      'Current monthly recurring distribution',
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
              Text(
                totalMrr ?? '₹2,40,000 / mo',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PlatformRevenueTierRow(
            name: '👑 Unlimited Doctors Tier',
            amount: enterpriseAmount ?? '₹1,39,980/mo',
            count: enterpriseCount ?? '2 Clinics (58.3%)',
            accent: const Color(0xFF0284C7),
          ),
          const SizedBox(height: 10),
          PlatformRevenueTierRow(
            name: '🏥 Multi-Doctor Tier',
            amount: multiAmount ?? '₹89,970/mo',
            count: multiCount ?? '3 Clinics (37.5%)',
            accent: const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),
          PlatformRevenueTierRow(
            name: '👤 Solo Doctor Tier',
            amount: soloAmount ?? '₹10,050/mo',
            count: soloCount ?? '1 Clinic (4.2%)',
            accent: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 18),
          _manageButton(context, colors),
        ],
      ),
    );
  }

  Widget _manageButton(BuildContext context, AppColorsExtension colors) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const PlatformBillingPage(),
              transitionDuration: Duration.zero,
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryLight,
          side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        icon: const Icon(Icons.receipt_long_outlined, size: 15),
        label: Text(
          'Manage Subscription Plans & Invoices →',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
