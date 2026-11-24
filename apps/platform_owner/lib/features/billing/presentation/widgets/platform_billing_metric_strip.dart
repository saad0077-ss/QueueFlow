import 'package:flutter/material.dart';

import '../../domain/entities/platform_billing_metrics.dart';
import 'platform_billing_metric_card.dart';

class PlatformBillingMetricStrip extends StatelessWidget {
  final PlatformBillingMetrics metrics;

  const PlatformBillingMetricStrip({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final clinicPlural = metrics.activeSubscriptions == 1
        ? 'partner clinic'
        : 'partner clinics';
    final overdueSubtext = metrics.overdueCount > 0
        ? '${metrics.overdueCount} awaiting payment'
        : 'All invoices settled';
    final activeSubtext = metrics.activeSubscriptions > 0
        ? 'All practices active'
        : 'No active subscriptions';

    final cards = [
      PlatformBillingMetricCard(
        tag: 'REVENUE STREAM',
        label: 'Monthly Recurring Revenue',
        value: metrics.totalMrr,
        trend: metrics.mrrTrend,
        subtext: 'Across ${metrics.activeSubscriptions} $clinicPlural',
        icon: Icons.payments_outlined,
        themeColor: const Color(0xFF38BDF8),
      ),
      PlatformBillingMetricCard(
        tag: 'RENEWAL EFFICIENCY',
        label: 'Active Subscriptions',
        value: metrics.activeSubscriptions.toString(),
        trend: metrics.retentionRate,
        subtext: activeSubtext,
        icon: Icons.verified_outlined,
        themeColor: const Color(0xFF10B981),
      ),
      PlatformBillingMetricCard(
        tag: 'RECEIVABLES',
        label: 'Overdue / Pending Invoices',
        value: metrics.overdueCount.toString(),
        trend: metrics.overdueAmount,
        subtext: overdueSubtext,
        icon: Icons.warning_amber_rounded,
        themeColor: const Color(0xFFEF4444),
      ),
      PlatformBillingMetricCard(
        tag: 'PLATFORM HEALTH',
        label: 'Platform Churn & ARPU',
        value: metrics.arpu,
        trend: metrics.churnRate,
        subtext: 'Avg revenue per practice',
        icon: Icons.trending_up_rounded,
        themeColor: const Color(0xFFF59E0B),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        if (isDesktop) {
          return Row(
            children: cards
                .map(
                  (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: c,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (c) => SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: c,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
