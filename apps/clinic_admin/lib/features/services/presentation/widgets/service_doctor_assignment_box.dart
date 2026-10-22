import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_ui_kit.dart';

class ServiceDoctorAssignmentBox extends StatelessWidget {
  final List<String> assignedStaff;

  const ServiceDoctorAssignmentBox({super.key, required this.assignedStaff});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ServiceColors.field,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ServiceColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👨‍⚕️ ASSIGNED PRACTICING DOCTORS',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: ServiceColors.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: assignedStaff.map((doc) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ServiceColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: ServiceColors.blue.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '✓ $doc',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: ServiceColors.blue,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
