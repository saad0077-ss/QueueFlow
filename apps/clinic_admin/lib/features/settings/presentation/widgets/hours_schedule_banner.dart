import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF090E1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
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
                  Text('Clinic Operating Schedule', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF78350F).withAlpha(60),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('OPENS AT 9:00 AM', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFFBBF24))),
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
                      decoration: BoxDecoration(color: const Color(0xFF065F46).withAlpha(80), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF10B981).withAlpha(120))),
                      child: Text('⚡ 24/7 Triage On-Call', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF34D399))),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withAlpha(80), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF3B82F6).withAlpha(120))),
                    child: Text('$totalWeeklyHours Hrs / Week', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF60A5FA))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(scheduleSummary, style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
