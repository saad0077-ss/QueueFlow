import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicTicketReplyClosedBanner extends StatelessWidget {
  const ClinicTicketReplyClosedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.isDark
            ? const Color(0xFF0F172A)
            : colors.surfaceSecondary,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: colors.textMuted),
          const SizedBox(width: 8),
          Text(
            'Ticket Closed & Resolved — Chat is locked until reopened.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
