import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header displaying the greeting and current date/clinic name.
class DashboardGreetingHeader extends StatelessWidget {
  final String doctorName;
  final String clinicName;

  const DashboardGreetingHeader({
    super.key,
    this.doctorName = 'Dr. Priya',
    this.clinicName = 'Sunrise Health Clinic',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, $doctorName',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Friday, 12 June 2026 • $clinicName',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
