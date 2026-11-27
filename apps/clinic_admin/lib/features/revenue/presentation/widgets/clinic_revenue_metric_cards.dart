import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_revenue_summary.dart';
import '../utils/clinic_revenue_formatter.dart';

/// Responsive 4-card KPI grid summarizing clinic revenue channels and averages.
class ClinicRevenueMetricCards extends StatelessWidget {
  final ClinicRevenueSummary summary;

  const ClinicRevenueMetricCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cards = _buildCards(colors);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width < 540 ? 1 : (width < 960 ? 2 : 4);
        final itemWidth = (width - ((cols - 1) * 16)) / cols;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((card) => SizedBox(width: itemWidth, child: card))
              .toList(),
        );
      },
    );
  }

  List<Widget> _buildCards(AppColorsExtension colors) {
    return [
      AppMetricCard(
        tag: 'NET REVENUE',
        tagColor: const Color(0xFF10B981),
        hasDot: true,
        dotColor: const Color(0xFF10B981),
        label: 'Settled Net',
        value: ClinicRevenueFormatter.formatCompactInr(summary.netRevenue),
        icon: Icons.account_balance_wallet_outlined,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Row(
          children: [
            AppMetricTrendPill(
              text: '${summary.paidCount} Settled',
              type: AppTrendType.up,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Razorpay + Walk-in',
                style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      AppMetricCard(
        tag: 'RAZORPAY PAYMENTS',
        tagColor: const Color(0xFF38BDF8),
        hasDot: true,
        dotColor: const Color(0xFF38BDF8),
        label: 'Online Paid',
        value: ClinicRevenueFormatter.formatCompactInr(summary.razorpayRevenue),
        icon: Icons.payments_outlined,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          '${summary.razorpayCount} settled Razorpay transactions',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'WALK-IN QUEUE',
        tagColor: const Color(0xFF10B981),
        hasDot: true,
        dotColor: const Color(0xFF10B981),
        label: 'Live Queue',
        value: ClinicRevenueFormatter.formatCompactInr(summary.walkInQueueRevenue),
        icon: Icons.confirmation_number_outlined,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          '${summary.walkInQueueCount} walk-in queue tokens settled',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'AVG FEE / VISIT',
        tagColor: const Color(0xFFA855F7),
        label: 'Mean Ticket',
        value: ClinicRevenueFormatter.formatInr(summary.avgTicketValue),
        icon: Icons.insights_rounded,
        iconColor: const Color(0xFFC084FC),
        iconBgColor: const Color(0xFF581C87).withValues(alpha: 0.35),
        borderColor: const Color(0xFF7E22CE).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Refunds: ${ClinicRevenueFormatter.formatCompactInr(summary.refundedTotal)}',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }
}
