import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays the 3-column KPI summary inside [PaymentHistoryHeroBanner].
class PaymentHistoryKpiStrip extends StatelessWidget {
  final double totalPaid;
  final int paidCount;
  final double totalRefunded;
  final int refundCount;
  final int queueTokensCount;

  const PaymentHistoryKpiStrip({
    super.key,
    required this.totalPaid,
    required this.paidCount,
    required this.totalRefunded,
    required this.refundCount,
    required this.queueTokensCount,
  });

  @override
  Widget build(BuildContext context) {
    final kpis = [
      (
        title: 'TOTAL PAID',
        value: '₹${totalPaid.toStringAsFixed(0)}',
        sub: '$paidCount paid txns',
        color: const Color(0xFF34D399),
      ),
      (
        title: 'REFUNDED',
        value: '₹${totalRefunded.toStringAsFixed(0)}',
        sub: '$refundCount refunded',
        color: const Color(0xFFFBBF24),
      ),
      (
        title: 'QUEUE TOKENS',
        value: '$queueTokensCount',
        sub: 'Walk-in paid',
        color: const Color(0xFF60A5FA),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < kpis.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 38,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            Expanded(
              child: _kpiCol(
                title: kpis[i].title,
                value: kpis[i].value,
                sub: kpis[i].sub,
                valueColor: kpis[i].color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kpiCol({
    required String title,
    required String value,
    required String sub,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.75),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
