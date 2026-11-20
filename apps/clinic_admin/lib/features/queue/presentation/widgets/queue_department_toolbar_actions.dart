import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueDepartmentToolbarActions extends StatelessWidget {
  final int activeFiltersCount;
  final String? activeFilterLabel;
  final bool isAllCollapsed;
  final VoidCallback onOpenFilters;
  final VoidCallback onResetFilters;
  final VoidCallback onToggleAllDepts;

  const QueueDepartmentToolbarActions({
    super.key,
    required this.activeFiltersCount,
    this.activeFilterLabel,
    required this.isAllCollapsed,
    required this.onOpenFilters,
    required this.onResetFilters,
    required this.onToggleAllDepts,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: onOpenFilters,
          icon: const Icon(Icons.filter_list_rounded, size: 16),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              if (activeFiltersCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    activeFiltersCount.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: activeFiltersCount > 0 ? colors.primary : colors.textPrimary,
            side: BorderSide(color: activeFiltersCount > 0 ? colors.primary : colors.border),
            backgroundColor: activeFiltersCount > 0 ? colors.primaryTint : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        if (activeFilterLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activeFilterLabel!,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: onResetFilters,
                  child: Icon(Icons.close_rounded, size: 14, color: colors.primary),
                ),
              ],
            ),
          ),
        OutlinedButton(
          onPressed: onToggleAllDepts,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textMuted,
            side: BorderSide(color: colors.border),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            isAllCollapsed ? 'Expand All' : 'Collapse All',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
