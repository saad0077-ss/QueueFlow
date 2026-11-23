import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'header/platform_revenue_header_actions.dart';

class PlatformRevenueHeader extends StatelessWidget {
  final VoidCallback onExportLedger;

  const PlatformRevenueHeader({
    super.key,
    required this.onExportLedger,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 750;

        final titleCol = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Revenue & Analytics',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track SaaS subscriptions, billing collections, payment gateway settlements & practice lifetime value',
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
            ),
          ],
        );

        final actions = PlatformRevenueHeaderActions(
          onExportLedger: onExportLedger,
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleCol,
              const SizedBox(height: 14),
              actions,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: titleCol),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}
