import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'about_app_hero_parts.dart';
import 'about_app_pillars_strip.dart';

/// Branded gradient hero card showcasing QueueFlow identity and core pillars.
class AboutAppHeroCard extends StatelessWidget {
  final bool isWide;

  const AboutAppHeroCard({super.key, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              top: -32,
              right: -24,
              child: Container(
                width: isWide ? 180 : 110,
                height: isWide ? 180 : 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isWide ? 24 : 20),
              child: isWide ? _wideContent() : _compactContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AboutHeroIconFrame(size: 70),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AboutHeroBrandTitle(fontSize: 26),
                        AboutHeroVersionBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Book smarter. Wait less.',
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.94),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const AboutHeroMissionCopy(
                      textAlign: TextAlign.left,
                      fontSize: 12.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(flex: 4, child: AboutAppPillarsStrip()),
      ],
    );
  }

  Widget _compactContent() {
    return Column(
      children: [
        const AboutHeroIconFrame(size: 66),
        const SizedBox(height: 14),
        const AboutHeroBrandTitle(fontSize: 24),
        const SizedBox(height: 4),
        Text(
          'Book smarter. Wait less.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
        const SizedBox(height: 10),
        const AboutHeroVersionBadge(),
        const SizedBox(height: 12),
        const AboutHeroMissionCopy(textAlign: TextAlign.center, fontSize: 12),
        const SizedBox(height: 16),
        const AboutAppPillarsStrip(),
      ],
    );
  }
}
