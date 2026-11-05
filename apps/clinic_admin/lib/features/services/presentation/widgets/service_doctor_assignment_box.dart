import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ServiceDoctorAssignmentBox extends StatelessWidget {
  final List<String> assignedStaff;

  const ServiceDoctorAssignmentBox({super.key, required this.assignedStaff});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👨‍⚕️ ASSIGNED PRACTICING DOCTORS',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: colors.textMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          if (assignedStaff.isEmpty)
            Text(
              'No doctors assigned yet',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: colors.textSubtle,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: assignedStaff.map((doc) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '✓ $doc',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
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
