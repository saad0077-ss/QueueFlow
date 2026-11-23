import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'bar/clinic_tickets_search_input.dart';
import 'bar/clinic_tickets_status_pills.dart';

class ClinicTicketsFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilters;
  final int activeFilterCount;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final int countAll;
  final int countOpen;
  final int countInProgress;
  final int countResolved;

  const ClinicTicketsFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onOpenFilters,
    required this.activeFilterCount,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.countAll,
    required this.countOpen,
    required this.countInProgress,
    required this.countResolved,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 750;

          final searchAndFilter = ClinicTicketsSearchInput(
            searchQuery: searchQuery,
            onSearchChanged: onSearchChanged,
            onOpenFilters: onOpenFilters,
            activeFilterCount: activeFilterCount,
            isNarrow: isNarrow,
            maxWidth: constraints.maxWidth,
          );

          final statusPills = ClinicTicketsStatusPills(
            selectedStatus: selectedStatus,
            onStatusChanged: onStatusChanged,
            countAll: countAll,
            countOpen: countOpen,
            countInProgress: countInProgress,
            countResolved: countResolved,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                searchAndFilter,
                const SizedBox(height: 12),
                statusPills,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [searchAndFilter, statusPills],
          );
        },
      ),
    );
  }
}
