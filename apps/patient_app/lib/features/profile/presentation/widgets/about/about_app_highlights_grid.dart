import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class _AboutFeature {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _AboutFeature(this.icon, this.color, this.title, this.desc);
}

class AboutAppHighlightsGrid extends StatelessWidget {
  const AboutAppHighlightsGrid({super.key});

  static const _features = [
    _AboutFeature(Icons.radar_rounded, Color(0xFF3B82F6), 'Live Queue Radar', 'Track tokens & live wait times'),
    _AboutFeature(Icons.event_available_rounded, Color(0xFF10B981), 'Smart Bookings', 'Book clinic visits in seconds'),
    _AboutFeature(Icons.receipt_long_rounded, Color(0xFF8B5CF6), 'Digital Receipts', 'Invoices & instant refund tracking'),
    _AboutFeature(Icons.verified_rounded, Color(0xFFF59E0B), 'Verified Reviews', 'Ratings for clinics & doctors'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'PLATFORM HIGHLIGHTS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: colors.textSubtle,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 780) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < _features.length; i++) ...[
                      if (i > 0) const SizedBox(width: 14),
                      Expanded(child: _card(colors, _features[i])),
                    ],
                  ],
                ),
              );
            }
            final twoCol = constraints.maxWidth >= 340;
            if (!twoCol) {
              return Column(
                children: [
                  for (var i = 0; i < _features.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _card(colors, _features[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < _features.length; i += 2) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _card(colors, _features[i])),
                      const SizedBox(width: 10),
                      Expanded(child: _card(colors, _features[i + 1])),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _card(AppColorsExtension colors, _AboutFeature item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              height: 1.35,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
