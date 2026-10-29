import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimelineRulerHeader extends StatelessWidget {
  const TimelineRulerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const ticks = ['07:00', '09:00', '11:00', '13:00', '15:00', '17:00', '19:00', '21:00'];
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 64, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ticks.map((t) {
          return Text(
            t,
            style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
          );
        }).toList(),
      ),
    );
  }
}
