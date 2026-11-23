import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class DoctorUtilizationBox extends StatelessWidget {
  final int activeDoctors;
  final int totalSlots;

  const DoctorUtilizationBox({
    super.key,
    required this.activeDoctors,
    required this.totalSlots,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;
    final utilizationPct = totalSlots > 0
        ? ((activeDoctors / totalSlots) * 100).round()
        : 0;
    final availableSlots = (totalSlots - activeDoctors).clamp(0, totalSlots);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Doctor Roster Utilization:',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '$activeDoctors / $totalSlots Active Doctors ($utilizationPct%)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '$availableSlots available slots in current subscription tiers',
            style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
