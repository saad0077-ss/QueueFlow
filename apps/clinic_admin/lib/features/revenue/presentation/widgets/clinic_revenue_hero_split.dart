import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_summary.dart';
import '../utils/clinic_revenue_formatter.dart';

/// Proportional split box comparing Razorpay Payments vs Walk-In Queue earnings.
class ClinicRevenueHeroSplit extends StatelessWidget {
  final ClinicRevenueSummary summary;

  const ClinicRevenueHeroSplit({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final razorpay = summary.razorpayRevenue;
    final walkIn = summary.walkInQueueRevenue;
    final total = razorpay + walkIn;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: colors.isDark ? 0.65 : 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SplitItem(
                  label: 'Razorpay Payments',
                  amount: ClinicRevenueFormatter.formatCompactInr(razorpay),
                  visits: '${summary.razorpayCount} visits',
                  color: const Color(0xFF00D2FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SplitItem(
                  label: 'Walk-In Queue',
                  amount: ClinicRevenueFormatter.formatCompactInr(walkIn),
                  visits: '${summary.walkInQueueCount} visits',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 7,
              child: total <= 0
                  ? Container(color: colors.border.withValues(alpha: 0.45))
                  : Row(
                      children: [
                        if (razorpay > 0)
                          Expanded(
                            flex: ((razorpay / total) * 100).round().clamp(1, 100),
                            child: Container(color: const Color(0xFF00D2FF)),
                          ),
                        if (walkIn > 0)
                          Expanded(
                            flex: ((walkIn / total) * 100).round().clamp(1, 100),
                            child: Container(color: const Color(0xFF10B981)),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitItem extends StatelessWidget {
  final String label;
  final String amount;
  final String visits;
  final Color color;

  const _SplitItem({
    required this.label,
    required this.amount,
    required this.visits,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                visits,
                style: GoogleFonts.inter(fontSize: 10.5, color: colors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
