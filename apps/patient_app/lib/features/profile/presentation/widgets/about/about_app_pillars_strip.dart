import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutAppPillarsStrip extends StatelessWidget {
  const AboutAppPillarsStrip({super.key});

  static const _pillars = [
    (tag: 'REAL-TIME', title: 'Live Sync', color: Color(0xFF5EEAD4)),
    (tag: 'VERIFIED', title: 'Trusted Care', color: Color(0xFF60A5FA)),
    (tag: 'DIGITAL', title: 'Smart Slips', color: Color(0xFFFBBF24)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _pillars.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    _pillars[i].tag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _pillars[i].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _pillars[i].color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
