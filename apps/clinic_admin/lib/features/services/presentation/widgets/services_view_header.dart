import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ServicesViewHeader extends StatelessWidget {
  final String? planPill;
  final String? planName;

  const ServicesViewHeader({
    super.key,
    this.planPill,
    this.planName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final titleSize = constraints.maxWidth < 600 ? 22.0 : 26.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services Management',
              style: GoogleFonts.inter(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Configure treatments, durations, pricing & clinical assignments (1 service per doctor limit)',
              style: GoogleFonts.inter(fontSize: 13.5, color: colors.textMuted),
            ),
          ],
        );
      },
    );
  }
}
