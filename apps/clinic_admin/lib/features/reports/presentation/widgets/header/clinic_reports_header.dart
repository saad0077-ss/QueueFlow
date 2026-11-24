import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'clinic_reports_header_actions.dart';

class ClinicReportsHeader extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  const ClinicReportsHeader({
    super.key,
    required this.onExport,
    required this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        final titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Analytics',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track patient visits, consultation volume, service distribution & clinical revenue',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colors.textMuted,
              ),
            ),
          ],
        );

        final actions = ClinicReportsHeaderActions(
          onExport: onExport,
          onRefresh: onRefresh,
          isRefreshing: isRefreshing,
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleSection, const SizedBox(height: 14), actions],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleSection),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}
