import 'package:flutter/material.dart';

import '../../domain/entities/platform_report_entity.dart';
import 'kpi/platform_reports_kpi_builder.dart';

class PlatformReportsKpiRibbon extends StatelessWidget {
  final PlatformReportEntity report;

  const PlatformReportsKpiRibbon({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final cards = PlatformReportsKpiBuilder.buildCards(
      context: context,
      report: report,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final colCount = w >= 1200 ? 5 : (w >= 900 ? 3 : (w >= 560 ? 2 : 1));
        final spacing = 12.0;
        final itemWidth = (w - ((colCount - 1) * spacing)) / colCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
  }
}
