import 'package:flutter/material.dart';

import '../../domain/entities/platform_report_entity.dart';
import 'analytics/subscription_distribution_card.dart';
import 'analytics/top_clinics_card.dart';

class PlatformReportsAnalyticsGrid extends StatelessWidget {
  final PlatformReportEntity report;

  const PlatformReportsAnalyticsGrid({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 950;

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TopClinicsCard(clinics: report.rankedClinics),
              const SizedBox(height: 16),
              SubscriptionDistributionCard(report: report),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: TopClinicsCard(clinics: report.rankedClinics),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: SubscriptionDistributionCard(report: report),
            ),
          ],
        );
      },
    );
  }
}
