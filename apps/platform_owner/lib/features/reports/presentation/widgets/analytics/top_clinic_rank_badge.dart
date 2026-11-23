import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class TopClinicRankBadge extends StatelessWidget {
  final int rank;

  const TopClinicRankBadge({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    Color rankBg = colors.surfaceSecondary;
    Color rankFg = colors.textMuted;
    if (rank == 1) {
      rankBg = const Color(0xFFF59E0B).withValues(alpha: 0.2);
      rankFg = const Color(0xFFF59E0B);
    } else if (rank == 2) {
      rankBg = const Color(0xFF94A3B8).withValues(alpha: 0.2);
      rankFg = isDark ? Colors.white : const Color(0xFF475569);
    } else if (rank == 3) {
      rankBg = const Color(0xFFD97706).withValues(alpha: 0.2);
      rankFg = const Color(0xFFD97706);
    }

    return Container(
      width: 26,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rankBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#$rank',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: rankFg,
        ),
      ),
    );
  }
}
