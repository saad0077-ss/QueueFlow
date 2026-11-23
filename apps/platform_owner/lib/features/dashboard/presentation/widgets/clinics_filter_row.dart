import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'filter/platform_clinics_filter_modal.dart';

class ClinicsFilterRow extends StatelessWidget {
  final String searchQuery;
  final String selectedPlan;
  final String selectedStatus;
  final int count;
  final int total;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onPlanChanged;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onReset;

  const ClinicsFilterRow({
    super.key,
    required this.searchQuery,
    required this.selectedPlan,
    required this.selectedStatus,
    required this.count,
    required this.total,
    required this.onSearch,
    required this.onPlanChanged,
    required this.onStatusChanged,
    required this.onReset,
  });

  int get _activeCount =>
      (selectedPlan != 'All Plans' ? 1 : 0) +
      (selectedStatus != 'All Statuses' ? 1 : 0);

  void _openFilters(BuildContext context) {
    PlatformClinicsFilterModal.show(
      context,
      initialPlan: selectedPlan,
      initialStatus: selectedStatus,
      onApply: ({required String plan, required String status}) {
        if (plan != selectedPlan) onPlanChanged(plan);
        if (status != selectedStatus) onStatusChanged(status);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = _activeCount;
    final hasFilters = active > 0 || searchQuery.trim().isNotEmpty;

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
              hintText: 'Search by clinic name, doctor, city, plan...',
              onChanged: onSearch,
            ),
          ),
          const SizedBox(width: 10),
          AppFilterTriggerButton(
            activeCount: active,
            onTap: () => _openFilters(context),
          ),
          if (hasFilters) ...[
            const SizedBox(width: 8),
            AppFilterResetButton(onTap: onReset),
          ],
        ],
      ),
    );
  }
}
