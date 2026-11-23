import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformUsersFilterToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final int activeFiltersCount;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilter;
  final VoidCallback onReset;

  const PlatformUsersFilterToolbar({
    super.key,
    required this.searchController,
    required this.activeFiltersCount,
    required this.onSearchChanged,
    required this.onOpenFilter,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasActiveSearchOrFilter =
        searchController.text.trim().isNotEmpty || activeFiltersCount > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final searchField = SizedBox(
          height: 42,
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search by name, phone, email, token...',
              hintStyle: GoogleFonts.inter(
                fontSize: 12.5,
                color: colors.textMuted,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: colors.textMuted,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: colors.surfaceSecondary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF0072FF)),
              ),
            ),
          ),
        );

        final filterBtn = OutlinedButton.icon(
          onPressed: onOpenFilter,
          icon: Icon(
            Icons.tune_rounded,
            size: 16,
            color: activeFiltersCount > 0
                ? const Color(0xFF0072FF)
                : colors.textPrimary,
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: activeFiltersCount > 0
                      ? const Color(0xFF0072FF)
                      : colors.textPrimary,
                ),
              ),
              if (activeFiltersCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0072FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$activeFiltersCount',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: activeFiltersCount > 0
                ? const Color(0xFF0072FF).withAlpha(15)
                : colors.surfaceSecondary,
            side: BorderSide(
              color: activeFiltersCount > 0
                  ? const Color(0xFF0072FF)
                  : colors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          ),
        );

        final resetBtn = OutlinedButton(
          onPressed: onReset,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textMuted,
            side: BorderSide(color: colors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          ),
          child: Text(
            'Reset Filters',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [filterBtn, if (hasActiveSearchOrFilter) resetBtn],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 10),
            filterBtn,
            if (hasActiveSearchOrFilter) ...[
              const SizedBox(width: 10),
              resetBtn,
            ],
          ],
        );
      },
    );
  }
}
