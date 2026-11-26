import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'legal_document_section.dart';

/// Quick clause overview bar shown on desktop/laptop screens for legal pages.
class LegalSectionsIndexCard extends StatelessWidget {
  final List<LegalSectionItem> sections;
  final Set<int> expanded;
  final ValueChanged<int> onSectionTap;
  final bool isHorizontal;

  const LegalSectionsIndexCard({
    super.key,
    required this.sections,
    required this.expanded,
    required this.onSectionTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          Row(
            children: [
              Text(
                'SECTIONS OVERVIEW',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: colors.textSubtle,
                ),
              ),
              const Spacer(),
              Text(
                '${expanded.length}/${sections.length} expanded',
                style: GoogleFonts.spaceMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isHorizontal)
            Row(
              children: [
                for (var i = 0; i < sections.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _chip(colors, i)),
                ],
              ],
            )
          else
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              _chip(colors, i),
            ],
        ],
      ),
    );
  }

  Widget _chip(AppColorsExtension colors, int i) {
    final active = expanded.contains(i);
    final section = sections[i];
    return InkWell(
      onTap: () => onSectionTap(i),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? section.accent.withValues(alpha: 0.11)
              : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? section.accent.withValues(alpha: 0.35)
                : colors.border,
          ),
        ),
        child: Row(
          children: [
            Text(
              section.number,
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: section.accent,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                section.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              active
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              size: 15,
              color: active ? section.accent : colors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
