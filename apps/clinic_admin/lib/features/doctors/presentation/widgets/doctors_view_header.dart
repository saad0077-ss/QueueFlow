import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class DoctorsViewHeader extends StatelessWidget {
  final String planPill;
  final String planName;
  final VoidCallback? onAddDoctor;

  const DoctorsViewHeader({
    super.key,
    required this.planPill,
    required this.planName,
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
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.badgeOpenBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.badgeOpenText.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    planPill,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: colors.badgeOpenText,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Text(
                  '$planName Active',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: colors.textMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}
