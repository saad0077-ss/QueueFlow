import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'flaticon_stethoscope.dart';

class GlassAnalyticsCard extends StatelessWidget {
  const GlassAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const barHeights = [24.0, 46.0, 34.0, 60.0, 44.0, 76.0, 50.0];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _tile('48', 'Appointments today')),
                      const SizedBox(width: 12),
                      Expanded(child: _tile('12', 'Customers waiting')),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int i = 0; i < barHeights.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: barHeights[i],
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.38), borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -22,
          right: -20,
          child: Transform.rotate(
            angle: 0.14,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Center(child: FlaticonStethoscope(size: 36, color: Color(0xFF2563EB))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tile(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count, style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.88))),
          ),
        ],
      ),
    );
  }
}
