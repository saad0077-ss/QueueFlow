import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PaymentHistorySummaryBanner extends StatelessWidget {
  final double totalSpent;
  final int count;

  const PaymentHistorySummaryBanner({
    super.key,
    required this.totalSpent,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('TOTAL SPENT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: colors.textMuted)),
                const SizedBox(height: 2),
                Text('₹${totalSpent.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ),
          Container(width: 1, height: 26, color: colors.border),
          Expanded(
            child: Column(
              children: [
                Text('INVOICES', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: colors.textMuted)),
                const SizedBox(height: 2),
                Text('$count Paid', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.textPrimary)),
              ],
            ),
          ),
          Container(width: 1, height: 26, color: colors.border),
          const Expanded(
            child: Column(
              children: [
                Text('SECURITY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                SizedBox(height: 2),
                Text('✓ Verified', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
