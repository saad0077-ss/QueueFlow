import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveTicketMetricBox extends StatelessWidget {
  final String value;
  final String label;
  final bool isCompact;

  const ActiveTicketMetricBox({
    super.key,
    required this.value,
    required this.label,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: isCompact ? 14 : 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
