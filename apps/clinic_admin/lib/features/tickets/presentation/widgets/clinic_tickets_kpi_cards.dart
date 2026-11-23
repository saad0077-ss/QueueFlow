import 'package:flutter/material.dart';
import 'kpi/clinic_tickets_kpi_card_builder.dart';

class ClinicTicketsKpiCards extends StatelessWidget {
  final int totalCount;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;

  const ClinicTicketsKpiCards({
    super.key,
    required this.totalCount,
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
  });

  @override
  Widget build(BuildContext context) {
    final cards = ClinicTicketsKpiCardBuilder.buildCards(
      context: context,
      totalCount: totalCount,
      openCount: openCount,
      inProgressCount: inProgressCount,
      resolvedCount: resolvedCount,
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
