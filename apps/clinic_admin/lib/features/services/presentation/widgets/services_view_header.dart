import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_ui_kit.dart';

class ServicesViewHeader extends StatelessWidget {
  final String planPill;
  final String planName;

  const ServicesViewHeader({
    super.key,
    required this.planPill,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleSize = constraints.maxWidth < 600 ? 22.0 : 26.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ServiceColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ServiceColors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    planPill,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: ServiceColors.green,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Text(
                  '$planName Active',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Services Management',
              style: GoogleFonts.inter(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Configure treatments, durations, pricing & clinical assignments (1 service per doctor limit)',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ],
        );
      },
    );
  }
}
