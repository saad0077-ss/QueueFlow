import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/app_icon_badge.dart';

class AboutHeroIconFrame extends StatelessWidget {
  final double size;

  const AboutHeroIconFrame({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: AppIconBadge(size: size),
    );
  }
}

class AboutHeroBrandTitle extends StatelessWidget {
  final double fontSize;

  const AboutHeroBrandTitle({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
        ),
        children: const [
          TextSpan(text: 'Queue', style: TextStyle(color: Colors.white)),
          TextSpan(text: 'Flow', style: TextStyle(color: Color(0xFF5EEAD4))),
        ],
      ),
    );
  }
}

class AboutHeroVersionBadge extends StatelessWidget {
  const AboutHeroVersionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        'v1.0.0 · Build 1 · Patient App',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.spaceMono(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AboutHeroMissionCopy extends StatelessWidget {
  final TextAlign textAlign;
  final double fontSize;

  const AboutHeroMissionCopy({
    super.key,
    required this.textAlign,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Built to make clinic visits predictable with live queue tracking, verified doctor schedules, and instant digital receipts.',
      textAlign: textAlign,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        height: 1.45,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}
