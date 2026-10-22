import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DepartmentsKpiCards extends StatelessWidget {
  final int totalDepartments;
  final int activeSpecialties;
  final int doctorsAssigned;
  final int monthlyVisits;

  const DepartmentsKpiCards({
    super.key,
    required this.totalDepartments,
    required this.activeSpecialties,
    required this.doctorsAssigned,
    required this.monthlyVisits,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cardWidth = w >= 900 ? (w - 36) / 4 : (w >= 500 ? (w - 12) / 2 : w);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _card('🩺', const Color(0xFF2563EB), totalDepartments.toString(), 'Total Departments', cardWidth),
            _card('✓', const Color(0xFF10B981), activeSpecialties.toString(), 'Active Specialties', cardWidth),
            _card('👨‍⚕️', const Color(0xFF0F766E), doctorsAssigned.toString(), 'Doctors Assigned', cardWidth),
            _card('⚡', const Color(0xFFF59E0B), _formatNum(monthlyVisits), 'Monthly Consultations', cardWidth),
          ],
        );
      },
    );
  }

  Widget _card(String icon, Color tint, String value, String label, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1526),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: tint.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  String _formatNum(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
