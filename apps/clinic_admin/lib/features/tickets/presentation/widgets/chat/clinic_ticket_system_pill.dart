import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicTicketSystemPill extends StatelessWidget {
  final String text;
  final String timeDisplay;

  const ClinicTicketSystemPill({
    super.key,
    required this.text,
    required this.timeDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: colors.isDark
              ? const Color(0xFF1E293B)
              : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: colors.textMuted,
                  ),
                ),
              ),
              TextSpan(
                text: text,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              TextSpan(
                text: '  • $timeDisplay',
                style: GoogleFonts.inter(fontSize: 10, color: colors.textMuted),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ),
    );
  }
}
