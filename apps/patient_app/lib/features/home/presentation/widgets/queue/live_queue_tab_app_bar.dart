import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'radar/live_pulsing_dot.dart';

class LiveQueueTabAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool hasActiveTicket;

  const LiveQueueTabAppBar({super.key, required this.hasActiveTicket});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.headerBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: 64,
      titleSpacing: 20,
      title: Text(
        'Live Queue',
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        if (hasActiveTicket)
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? const Color(0xFF133633)
                  : colors.accentTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LivePulsingDot(),
                const SizedBox(width: 5),
                Text(
                  'Live',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.isDarkMode
                        ? const Color(0xFF2DD4BF)
                        : colors.accent,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
