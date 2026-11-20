import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class WalkInModalHeader extends StatelessWidget {
  const WalkInModalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Walk-In Patient',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Generate an in-person token directly into live queue',
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 20),
          color: colors.textMuted,
        ),
      ],
    );
  }
}
