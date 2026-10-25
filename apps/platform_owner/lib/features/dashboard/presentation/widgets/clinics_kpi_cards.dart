import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicsKpiCards extends StatelessWidget {
  final int totalClinics;
  final int activePractices;
  final int invitedClinics;
  final int totalDoctors;
  final int appointmentsMonth;
  final int totalMrr;

  const ClinicsKpiCards({
    super.key,
    required this.totalClinics,
    required this.activePractices,
    required this.invitedClinics,
    required this.totalDoctors,
    required this.appointmentsMonth,
    required this.totalMrr,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final perRow = w >= 1100 ? 5 : (w >= 700 ? 3 : (w >= 440 ? 2 : 1));
        final cardWidth = (w - 14 * (perRow - 1)) / perRow;

        final cards = [
          _card(Icons.domain_rounded, const Color(0xFF38BDF8), _fmt(totalClinics), 'Total Clinics',
              invitedClinics > 0 ? '$invitedClinics awaiting activation' : 'All onboarded'),
          _card(Icons.check_circle_outline_rounded, const Color(0xFF10B981), _fmt(activePractices), 'Active Clinics',
              totalClinics == 0 ? 'No clinics yet' : '${(activePractices * 100 / totalClinics).round()}% of network'),
          _card(Icons.medical_services_outlined, const Color(0xFFA855F7), _fmt(totalDoctors), 'Doctors on Roster',
              'Across all clinics'),
          _card(Icons.calendar_today_rounded, const Color(0xFFF59E0B), _fmt(appointmentsMonth), 'Appointments This Month',
              'Queue tickets since the 1st'),
          _card(Icons.credit_card_rounded, const Color(0xFF14B8A6), '₹${_fmt(totalMrr)}', 'Monthly Recurring Revenue',
              'From active subscriptions'),
        ];

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [for (final c in cards) SizedBox(width: cardWidth, child: c)],
        );
      },
    );
  }

  Widget _card(IconData icon, Color iconColor, String value, String label, String caption) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(height: 14),
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
