import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'legal_document_section.dart';

/// Compact left-pane index card shown on laptop layouts for quick clause navigation.
class LegalSectionsIndexCard extends StatelessWidget {
  final List<LegalSectionItem> sections;
  final Set<int> expanded;
  final ValueChanged<int> onSectionTap;

  const LegalSectionsIndexCard({
    super.key,
    required this.sections,
    required this.expanded,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 10),
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            InkWell(
              onTap: () => onSectionTap(i),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: expanded.contains(i)
                      ? sections[i].accent.withValues(alpha: 0.1)
                      : colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: expanded.contains(i)
                        ? sections[i].accent.withValues(alpha: 0.3)
                        : colors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      sections[i].number,
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: sections[i].accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sections[i].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      expanded.contains(i)
                          ? Icons.check_circle_rounded
                          : Icons.chevron_right_rounded,
                      size: 16,
                      color: expanded.contains(i)
                          ? sections[i].accent
                          : colors.textSubtle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
