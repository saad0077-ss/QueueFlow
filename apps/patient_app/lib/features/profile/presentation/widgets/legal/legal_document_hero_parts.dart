import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'legal_document_section.dart';

class LegalHeroMetaRow extends StatelessWidget {
  final LegalDocumentConfig config;
  final bool showClausesCount;

  const LegalHeroMetaRow({
    super.key,
    required this.config,
    required this.showClausesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            config.heroBadge,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Text(
          config.lastUpdated,
          style: GoogleFonts.spaceMono(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        if (showClausesCount)
          Text(
            '· ${config.sections.length} Clauses',
            style: GoogleFonts.spaceMono(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
      ],
    );
  }
}

class LegalHeroHeadlineRow extends StatelessWidget {
  final LegalDocumentConfig config;
  final bool isWide;

  const LegalHeroHeadlineRow({
    super.key,
    required this.config,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final box = isWide ? 52.0 : 46.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          alignment: Alignment.center,
          child: Icon(config.heroIcon, color: Colors.white, size: isWide ? 26 : 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.heroTitle,
                style: GoogleFonts.inter(
                  fontSize: isWide ? 23 : 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                config.heroDescription,
                style: GoogleFonts.inter(
                  fontSize: isWide ? 13 : 12,
                  height: 1.45,
                  color: Colors.white.withValues(alpha: 0.86),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LegalHeroHighlightChip extends StatelessWidget {
  final LegalHighlightBadge badge;
  final bool wide;

  const LegalHeroHighlightChip({
    super.key,
    required this.badge,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 12 : 10,
        vertical: wide ? 7 : 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: wide ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, size: wide ? 14 : 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            badge.label,
            style: GoogleFonts.inter(
              fontSize: wide ? 11.5 : 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
