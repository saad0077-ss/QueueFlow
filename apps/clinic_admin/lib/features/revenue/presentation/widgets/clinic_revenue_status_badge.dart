import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared status pill badge and color helper for revenue ledger rows.
class ClinicRevenueStatusBadge extends StatelessWidget {
  final String status;

  const ClinicRevenueStatusBadge({super.key, required this.status});

  static Color colorFor(String status) {
    return switch (status) {
      'paid' => const Color(0xFF10B981),
      'refunded' => const Color(0xFFEF4444),
      _ => const Color(0xFFF59E0B),
    };
  }

  @override
  Widget build(BuildContext context) {
    final fg = colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
