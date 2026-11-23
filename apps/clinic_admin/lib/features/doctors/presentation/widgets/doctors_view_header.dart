import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class DoctorsViewHeader extends StatelessWidget {
  final String? planPill;
  final String? planName;
  final VoidCallback? onAddDoctor;

  const DoctorsViewHeader({
    super.key,
    this.planPill,
    this.planName,
    this.onAddDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;
        final titleSize = isNarrow ? 22.0 : 26.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctors & Availability',
              style: GoogleFonts.inter(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage clinic doctors, room assignments, and live consultation availability for queue triage',
              style: GoogleFonts.inter(fontSize: 13.5, color: colors.textMuted),
            ),
          ],
        );
      },
    );
  }
}
