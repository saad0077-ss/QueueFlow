import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformTicketsSearchInput extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilters;
  final int activeFilterCount;
  final bool isNarrow;
  final double maxWidth;

  const PlatformTicketsSearchInput({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onOpenFilters,
    required this.activeFilterCount,
    required this.isNarrow,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isNarrow ? maxWidth : 260,
          height: 38,
          child: TextField(
            onChanged: onSearchChanged,
            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 16,
                color: colors.textMuted,
              ),
              hintText: 'Search clinics, patient, ID, issue...',
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                color: colors.textMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              isDense: true,
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF0B0F19)
                  : colors.surfaceSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2563EB)),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onOpenFilters,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: activeFilterCount > 0
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
                  : (isDark
                        ? const Color(0xFF0B0F19)
                        : colors.surfaceSecondary),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: activeFilterCount > 0
                    ? const Color(0xFF2563EB)
                    : colors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: activeFilterCount > 0
                      ? const Color(0xFF60A5FA)
                      : colors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Filters',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activeFilterCount > 0
                        ? const Color(0xFF60A5FA)
                        : colors.textPrimary,
                  ),
                ),
                if (activeFilterCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
