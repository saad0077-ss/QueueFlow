import 'package:flutter/material.dart';

import '../bloc/platform_revenue_state.dart';
import 'cards/platform_revenue_kpi_cards_builder.dart';

class PlatformRevenueKpiCards extends StatelessWidget {
  final PlatformRevenueState state;

  const PlatformRevenueKpiCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cards = PlatformRevenueKpiCardsBuilder.buildCards(
      context: context,
      state: state,
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
