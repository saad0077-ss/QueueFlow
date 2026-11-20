import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveTicketBottomRow extends StatelessWidget {
  final String nowServing;

  const ActiveTicketBottomRow({super.key, required this.nowServing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Now serving: ',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            Text(
              nowServing.isNotEmpty ? nowServing : '—',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Text(
            '✓ PAID · ₹100 (Razorpay)',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFA7F3D0),
            ),
          ),
        ),
      ],
    );
  }
}
