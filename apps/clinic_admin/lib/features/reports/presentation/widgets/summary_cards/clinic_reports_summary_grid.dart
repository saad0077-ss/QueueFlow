import 'package:flutter/material.dart';
import '../../../domain/entities/clinic_report_data.dart';
import 'clinic_reports_summary_builder.dart';

class ClinicReportsSummaryGrid extends StatelessWidget {
  final ClinicReportData data;

  const ClinicReportsSummaryGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int colCount;
        if (width < 580) {
          colCount = 1;
        } else if (width < 880) {
          colCount = 2;
        } else {
          colCount = 3;
        }

        final itemWidth = (width - ((colCount - 1) * 12)) / colCount;
        final cards = ClinicReportsSummaryBuilder.buildCards(context, data);

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
