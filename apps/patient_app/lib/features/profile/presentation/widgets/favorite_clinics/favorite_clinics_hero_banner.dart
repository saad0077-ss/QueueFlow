import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteClinicsHeroBanner extends StatelessWidget {
  final int count;

  const FavoriteClinicsHeroBanner({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: Personal care badge & count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 5),
                    Text(
                      'Personal Care Network',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$count Saved',
                style: GoogleFonts.spaceMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 KPI columns
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _kpiCol(
                    title: 'FAVORITES',
                    value: '$count',
                    sub: 'Clinics',
                    valueColor: const Color(0xFF6EE7B7),
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _kpiCol(
                    title: 'LIVE QUEUE',
                    value: 'Instant',
                    sub: 'Triage Pass',
                    valueColor: const Color(0xFFA7F3D0),
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _kpiCol(
                    title: 'COVERAGE',
                    value: '100%',
                    sub: 'Verified Care',
                    valueColor: const Color(0xFFFCD34D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCol({
    required String title,
    required String value,
    required String sub,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.75),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
