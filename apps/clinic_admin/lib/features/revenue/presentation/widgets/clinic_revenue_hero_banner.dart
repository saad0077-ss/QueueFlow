import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_summary.dart';
import '../utils/clinic_revenue_formatter.dart';
import 'clinic_revenue_hero_split.dart';

/// Highlight banner summarizing net clinic cashflow and collection efficiency.
class ClinicRevenueHeroBanner extends StatelessWidget {
  final ClinicRevenueSummary summary;

  const ClinicRevenueHeroBanner({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final balance = _buildBalanceColumn(colors);
    final split = ClinicRevenueHeroSplit(summary: summary);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0B2239), Color(0xFF0F172A), Color(0xFF0A2E2A)]
              : const [Color(0xFFF0FDF9), Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.35 : 0.3),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [balance, const SizedBox(height: 16), split],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: balance),
              const SizedBox(width: 16),
              Expanded(child: split),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceColumn(AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'NET CLINIC EARNINGS • ${summary.period.label.toUpperCase()}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                  letterSpacing: 0.4,
                ),
              ),
            ),
            Text(
              '${summary.collectionRate.toStringAsFixed(1)}% collection rate',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          ClinicRevenueFormatter.formatInr(summary.netRevenue),
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${summary.razorpayCount} Razorpay • '
          '${summary.walkInQueueCount} walk-in queue • '
          '${summary.refundedCount} refunds processed',
          style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
        ),
      ],
    );
  }
}
