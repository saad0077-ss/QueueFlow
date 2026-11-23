import 'package:flutter/material.dart';

import 'platform_revenue_clinic_contributions_card.dart';
import 'platform_revenue_tier_breakdown_card.dart';

class PlatformRevenueChartsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> clinicRevenueItems;
  final List<Map<String, dynamic>> recentInvoices;
  final String? totalMrr;
  final String? enterpriseAmount;
  final String? enterpriseCount;
  final String? multiAmount;
  final String? multiCount;
  final String? soloAmount;
  final String? soloCount;

  const PlatformRevenueChartsGrid({
    super.key,
    this.clinicRevenueItems = const [],
    this.recentInvoices = const [],
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
    final clinicsCard = PlatformRevenueClinicContributionsCard(
      clinicRevenueItems: clinicRevenueItems,
      recentInvoices: recentInvoices,
    );
    final tierCard = PlatformRevenueTierBreakdownCard(
      totalMrr: totalMrr,
      enterpriseAmount: enterpriseAmount,
      enterpriseCount: enterpriseCount,
      multiAmount: multiAmount,
      multiCount: multiCount,
      soloAmount: soloAmount,
      soloCount: soloCount,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 950;

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [clinicsCard, const SizedBox(height: 16), tierCard],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: clinicsCard),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: tierCard),
          ],
        );
      },
    );
  }
}
