import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'live_pulsing_dot.dart';

class QueueRadarHero extends StatelessWidget {
  const QueueRadarHero({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Live Clinic Wait Times',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        Row(
          children: [
            const LivePulsingDot(),
            const SizedBox(width: 5),
            Text(
              'Real-time',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: context.isDarkMode
                    ? const Color(0xFF2DD4BF)
                    : colors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
