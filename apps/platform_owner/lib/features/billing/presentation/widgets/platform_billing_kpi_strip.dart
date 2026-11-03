import 'package:flutter/material.dart';
import '../../domain/entities/platform_billing_kpis.dart';
import 'platform_billing_kpi_card.dart';

class PlatformBillingKpiStrip extends StatelessWidget {
  final PlatformBillingKpis kpis;

  const PlatformBillingKpiStrip({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    final cards = [
      PlatformBillingKpiCard(
        tag: 'REVENUE STREAM',
        label: 'Monthly Recurring Revenue',
        value: kpis.totalMrr,
        trend: kpis.mrrTrend,
        subtext: 'Across ${kpis.activeSubscriptions} partner clinics',
        icon: Icons.payments_outlined,
        themeColor: const Color(0xFF38BDF8),
      ),
      PlatformBillingKpiCard(
        tag: 'RENEWAL EFFICIENCY',
        label: 'Active Subscriptions',
        value: kpis.activeSubscriptions.toString(),
        trend: kpis.retentionRate,
        subtext: '0 cancellations this quarter',
        icon: Icons.verified_outlined,
        themeColor: const Color(0xFF10B981),
      ),
      PlatformBillingKpiCard(
        tag: 'RECEIVABLES',
        label: 'Overdue / Pending Invoices',
        value: kpis.overdueCount.toString(),
        trend: kpis.overdueAmount,
        subtext: 'Automated retries active',
        icon: Icons.warning_amber_rounded,
        themeColor: const Color(0xFFEF4444),
      ),
      PlatformBillingKpiCard(
        tag: 'PLATFORM HEALTH',
        label: 'Platform Churn & ARPU',
        value: kpis.arpu,
        trend: kpis.churnRate,
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
            children: cards.map((c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: c,
              ),
            )).toList(),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards.map((c) => SizedBox(
            width: constraints.maxWidth >= 600 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
            child: c,
          )).toList(),
        );
      },
    );
  }
}
