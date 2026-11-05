import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class DoctorsRosterHeader extends StatelessWidget {
  final int count;

  const DoctorsRosterHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final title = isNarrow
            ? 'DOCTORS ROSTER & STATUS'
            : 'PRACTICING DOCTORS ROSTER & QUEUE STATUS';

        return Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 15,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: colors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Text(
              '$count Doctor${count == 1 ? '' : 's'} on Roster',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: colors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
