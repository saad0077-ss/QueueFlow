import 'package:flutter/material.dart';

import 'legal_document_hero_parts.dart';
import 'legal_document_section.dart';

/// Gradient hero banner displayed at the top of legal screens.
class LegalDocumentHero extends StatelessWidget {
  final LegalDocumentConfig config;
  final bool isWide;

  const LegalDocumentHero({
    super.key,
    required this.config,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.heroGradient.first,
            config.heroGradient[1],
            config.heroGradient.last.withValues(alpha: isWide ? 0.85 : 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: config.heroGradient.last.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -28,
            child: Container(
              width: isWide ? 180 : 120,
              height: isWide ? 180 : 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isWide ? 24 : 18),
            child: isWide ? _wideLayout() : _compactLayout(),
          ),
        ],
      ),
    );
  }

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LegalHeroMetaRow(config: config, showClausesCount: true),
              const SizedBox(height: 16),
              LegalHeroHeadlineRow(config: config, isWide: true),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in config.highlights)
                  LegalHeroHighlightChip(badge: h, wide: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _compactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegalHeroMetaRow(config: config, showClausesCount: false),
        const SizedBox(height: 14),
        LegalHeroHeadlineRow(config: config, isWide: false),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final h in config.highlights) LegalHeroHighlightChip(badge: h),
          ],
        ),
      ],
    );
  }
}
