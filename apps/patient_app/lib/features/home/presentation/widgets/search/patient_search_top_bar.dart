import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../home_search_bar.dart';

class PatientSearchTopBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final bool autoFocus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onOpenFilter;
  final bool hasActiveFilters;
  final int activeCount;
  final double horizontalPadding;
  final AppColorsExtension colors;

  const PatientSearchTopBar({
    super.key,
    required this.searchCtrl,
    required this.autoFocus,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onOpenFilter,
    required this.hasActiveFilters,
    required this.activeCount,
    required this.horizontalPadding,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_left_rounded,
                color: colors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: HomeSearchBar(
              controller: searchCtrl,
              autoFocus: autoFocus,
              margin: EdgeInsets.zero,
              onChanged: onSearchChanged,
              onSubmitted: onSearchSubmitted,
              onClear: () => onSearchChanged(''),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onOpenFilter,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: hasActiveFilters
                    ? colors.primaryTint
                    : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasActiveFilters ? colors.primary : colors.border,
                  width: 1.5,
                ),
                boxShadow: hasActiveFilters
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: hasActiveFilters
                        ? colors.primary
                        : colors.textPrimary,
                  ),
                  if (activeCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
