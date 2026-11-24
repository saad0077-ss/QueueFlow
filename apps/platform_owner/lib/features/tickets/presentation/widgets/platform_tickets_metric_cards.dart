import 'package:flutter/material.dart';

import 'metrics/platform_tickets_metrics_builder.dart';

class PlatformTicketsMetricCards extends StatelessWidget {
  final int totalCount;
  final int atRiskCount;
  final int activeClinicsCount;
  final String avgResponseTime;

  const PlatformTicketsMetricCards({
    super.key,
    required this.totalCount,
    required this.atRiskCount,
    required this.activeClinicsCount,
    this.avgResponseTime = '4.2m',
  });

  @override
  Widget build(BuildContext context) {
    final cards = PlatformTicketsMetricsBuilder.buildCards(
      context: context,
      totalCount: totalCount,
      atRiskCount: atRiskCount,
      activeClinicsCount: activeClinicsCount,
      avgResponseTime: avgResponseTime,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final colCount = isCompact ? 2 : 4;
        final itemWidth =
            (constraints.maxWidth - ((colCount - 1) * 12)) / colCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
  }
}
