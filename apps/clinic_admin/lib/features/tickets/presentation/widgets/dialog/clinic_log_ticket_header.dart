import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicLogTicketHeader extends StatelessWidget {
  final VoidCallback onClose;

  const ClinicLogTicketHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Log Patient Support Ticket',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: colors.textMuted,
              ),
              onPressed: onClose,
            ),
          ],
        ),
        Text(
          'Record walk-in patient triage, queue complaint, or doctor request.',
          style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
        ),
      ],
    );
  }
}
