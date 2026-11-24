import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTrendType { up, down, neutral, amber }

class AppMetricTrendPill extends StatelessWidget {
  final String text;
  final AppTrendType type;

  const AppMetricTrendPill({
    super.key,
    required this.text,
    this.type = AppTrendType.up,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case AppTrendType.up:
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF10B981);
        break;
      case AppTrendType.amber:
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        fg = const Color(0xFFF59E0B);
        break;
      case AppTrendType.neutral:
        bg = const Color(0xFF0EA5E9).withValues(alpha: 0.15);
        fg = const Color(0xFF0EA5E9);
        break;
      case AppTrendType.down:
        bg = const Color(0xFFEF4444).withValues(alpha: 0.15);
        fg = const Color(0xFFEF4444);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
