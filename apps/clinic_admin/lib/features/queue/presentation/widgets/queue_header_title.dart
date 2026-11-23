import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueHeaderTitle extends StatelessWidget {
  final String clinicName;

  const QueueHeaderTitle({super.key, required this.clinicName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Queue Management',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$clinicName · Department & Service-wise live patient monitoring',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}
