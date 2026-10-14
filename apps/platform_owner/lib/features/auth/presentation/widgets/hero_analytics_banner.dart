import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_analytics_card.dart';

class HeroAnalyticsBanner extends StatelessWidget {
  const HeroAnalyticsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF0284C7), Color(0xFF0D9488)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset('assets/icons/app_icon_128.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 12),
                    Text('QueueFlow', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, top: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: const GlassAnalyticsCard(),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Text(
                    'Manage multi-clinic tenants, SaaS subscriptions, MRR, and audit trails, all in one place.',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
