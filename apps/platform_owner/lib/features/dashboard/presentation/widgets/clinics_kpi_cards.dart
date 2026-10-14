import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicsKpiCards extends StatelessWidget {
  final int totalClinics;
  final int activePractices;
  final int appointmentsMonth;
  final int totalMrr;

  const ClinicsKpiCards({
    super.key,
    required this.totalClinics,
    required this.activePractices,
    required this.appointmentsMonth,
    required this.totalMrr,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final c1 = _card(Icons.domain_rounded, const Color(0xFF38BDF8), '$totalClinics', 'Total Clinics');
        final c2 = _card(Icons.check_circle_outline_rounded, const Color(0xFF10B981), '$activePractices', 'Active Practices');
        final c3 = _card(Icons.calendar_today_rounded, const Color(0xFFF59E0B), '$appointmentsMonth', 'Appointments This Month');
        final c4 = _card(Icons.credit_card_rounded, const Color(0xFFF59E0B), '₹$totalMrr', 'Monthly Recurring Revenue');

        if (constraints.maxWidth >= 1000) {
          return Row(children: [
            Expanded(child: c1), const SizedBox(width: 14),
            Expanded(child: c2), const SizedBox(width: 14),
            Expanded(child: c3), const SizedBox(width: 14),
            Expanded(child: c4),
          ]);
        } else if (constraints.maxWidth >= 540) {
          return Column(children: [
            Row(children: [Expanded(child: c1), const SizedBox(width: 14), Expanded(child: c2)]),
            const SizedBox(height: 14),
            Row(children: [Expanded(child: c3), const SizedBox(width: 14), Expanded(child: c4)]),
          ]);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            c1, const SizedBox(height: 12),
            c2, const SizedBox(height: 12),
            c3, const SizedBox(height: 12),
            c4,
          ],
        );
      },
    );
  }

  Widget _card(IconData icon, Color iconColor, String value, String label) {
    return Container(
      width: double.infinity,
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
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
