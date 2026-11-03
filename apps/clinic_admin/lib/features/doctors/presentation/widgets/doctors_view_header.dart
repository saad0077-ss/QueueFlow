import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_ui_kit.dart';

class DoctorsViewHeader extends StatelessWidget {
  final String planPill;
  final String planName;
  final VoidCallback? onAddDoctor;

  const DoctorsViewHeader({
    super.key,
    required this.planPill,
    required this.planName,
    this.onAddDoctor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;
        final titleSize = isNarrow ? 22.0 : 26.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DoctorColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: DoctorColors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    planPill,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: DoctorColors.green,
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
            const SizedBox(height: 8),
            Text(
              'Doctors & Availability',
              style: GoogleFonts.inter(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage clinic doctors, room assignments, and live consultation availability for queue triage',
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
