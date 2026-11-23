import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class AppointmentsFilterTriggerButtons extends StatelessWidget {
  final int activeFilterCount;
  final bool hasActiveFilters;
  final VoidCallback onOpenFilter;
  final VoidCallback onClearFilters;

  const AppointmentsFilterTriggerButtons({
    super.key,
    required this.activeFilterCount,
    required this.hasActiveFilters,
    required this.onOpenFilter,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = activeFilterCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onOpenFilter,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: count > 0 ? colors.primaryTint : colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: count > 0 ? colors.primary : colors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: count > 0 ? colors.primary : colors.textPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  count > 0 ? 'Filters ($count)' : 'Filters',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: count > 0 ? colors.primary : colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasActiveFilters) ...[
          const SizedBox(width: 10),
          InkWell(
            onTap: onClearFilters,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
