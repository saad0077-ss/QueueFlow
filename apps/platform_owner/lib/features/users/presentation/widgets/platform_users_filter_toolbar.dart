import 'package:flutter/material.dart';
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppFilterSearchField(
              hintText: 'Search by name, phone, email, token...',
              controller: searchController,
              onChanged: onSearchChanged,
              onClear: () {
                searchController.clear();
                onSearchChanged('');
              },
            ),
          ),
          const SizedBox(width: 10),
          AppFilterTriggerButton(
            activeCount: activeFiltersCount,
            onTap: onOpenFilter,
          ),
          if (hasActiveSearchOrFilter) ...[
            const SizedBox(width: 8),
            AppFilterResetButton(onTap: onReset),
          ],
        ],
      ),
    );
  }
}
