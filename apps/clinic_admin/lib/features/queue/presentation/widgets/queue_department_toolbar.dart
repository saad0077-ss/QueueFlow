import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'queue_department_toolbar_actions.dart';

class QueueDepartmentToolbar extends StatefulWidget {
  final String searchQuery;
  final int activeFiltersCount;
  final String? activeFilterLabel;
  final bool isAllCollapsed;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenFilters;
  final VoidCallback onResetFilters;
  final VoidCallback onToggleAllDepts;

  const QueueDepartmentToolbar({
    super.key,
    required this.searchQuery,
    required this.activeFiltersCount,
    this.activeFilterLabel,
    required this.isAllCollapsed,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onOpenFilters,
    required this.onResetFilters,
    required this.onToggleAllDepts,
  });

  @override
  State<QueueDepartmentToolbar> createState() => _QueueDepartmentToolbarState();
}

class _QueueDepartmentToolbarState extends State<QueueDepartmentToolbar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant QueueDepartmentToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          final searchBox = ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearchChanged,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search departments, services, or tokens...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: colors.textMuted,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: colors.textMuted,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                suffixIcon: widget.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: colors.textMuted,
                        ),
                        splashRadius: 18,
                        onPressed: () {
                          _controller.clear();
                          widget.onClearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceSecondary,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
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
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
              ),
            ),
          );

          final filterButtons = QueueDepartmentToolbarActions(
            activeFiltersCount: widget.activeFiltersCount,
            activeFilterLabel: widget.activeFilterLabel,
            isAllCollapsed: widget.isAllCollapsed,
            onOpenFilters: widget.onOpenFilters,
            onResetFilters: widget.onResetFilters,
            onToggleAllDepts: widget.onToggleAllDepts,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [searchBox, const SizedBox(height: 10), filterButtons],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: searchBox),
              const SizedBox(width: 14),
              filterButtons,
            ],
          );
        },
      ),
    );
  }
}
