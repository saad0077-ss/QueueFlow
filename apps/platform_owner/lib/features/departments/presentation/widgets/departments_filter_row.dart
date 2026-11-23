import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'filter/platform_departments_filter_modal.dart';

class DepartmentsFilterRow extends StatelessWidget {
  final String searchQuery;
  final String selectedStatus;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onReset;

  const DepartmentsFilterRow({
    super.key,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onSearch,
    required this.onStatusChanged,
    required this.onReset,
  });

  bool get _isFiltered => selectedStatus != 'All Statuses';

  bool get _hasActiveFilters => _isFiltered || searchQuery.trim().isNotEmpty;

  void _openFilters(BuildContext context) {
    PlatformDepartmentsFilterModal.show(
      context,
      initialStatus: selectedStatus,
      onApply: (status) {
        if (status != selectedStatus) onStatusChanged(status);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              hintText: 'Search departments, specialties...',
              onChanged: onSearch,
            ),
          ),
          const SizedBox(width: 10),
          AppFilterTriggerButton(
            activeCount: _isFiltered ? 1 : 0,
            onTap: () => _openFilters(context),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(width: 8),
            AppFilterResetButton(onTap: onReset),
          ],
        ],
      ),
    );
  }
}
