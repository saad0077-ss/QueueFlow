import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class HoursScheduleBanner extends StatelessWidget {
  final int totalWeeklyHours;
  final bool isEmergencyOnCall;
  final String scheduleSummary;

  const HoursScheduleBanner({
    super.key,
    required this.totalWeeklyHours,
    required this.isEmergencyOnCall,
    this.scheduleSummary = 'Mon–Sat: 9:00 AM – 8:00 PM · Sun: Closed',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    'Clinic Operating Schedule',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.warningTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.warning),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: colors.warning, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('OPENS AT 9:00 AM', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: colors.warning)),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isEmergencyOnCall) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.badgeOpenBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.badgeOpenText.withAlpha(120)),
                      ),
                      child: Text(
                        '⚡ 24/7 Triage On-Call',
                        style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.badgeOpenText),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.primaryTint,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.primary.withAlpha(120)),
                    ),
                    child: Text(
                      '$totalWeeklyHours Hrs / Week',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: colors.primaryLight),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(scheduleSummary, style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted)),
        ],
      ),
    );
  }
}
