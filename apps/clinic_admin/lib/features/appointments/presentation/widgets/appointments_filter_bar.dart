import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'appointments_filter_bar_helper.dart';
import 'appointments_filter_trigger_buttons.dart';
import 'appointments_search_field.dart';

class AppointmentsFilterBar extends StatefulWidget {
  final String searchQuery;
  final String selectedDateRange;
  final String selectedDept;
  final String selectedService;
  final String selectedDoctor;
  final String selectedStatus;
  final String selectedPayment;
  final List<String> availableDepts;
  final List<String> availableServices;
  final List<String> availableDoctors;
  final int totalCount;
  final int filteredCount;
  final bool hasActiveFilters;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onDateRangeChanged;
  final ValueChanged<String> onDeptChanged;
  final ValueChanged<String> onServiceChanged;
  final ValueChanged<String> onDoctorChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onClearFilters;

  const AppointmentsFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedDateRange,
    required this.selectedDept,
    required this.selectedService,
    required this.selectedDoctor,
    required this.selectedStatus,
    required this.selectedPayment,
    required this.availableDepts,
    required this.availableServices,
    required this.availableDoctors,
    required this.totalCount,
    required this.filteredCount,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onDateRangeChanged,
    required this.onDeptChanged,
    required this.onServiceChanged,
    required this.onDoctorChanged,
    required this.onStatusChanged,
    required this.onPaymentChanged,
    required this.onClearFilters,
  });

  @override
  State<AppointmentsFilterBar> createState() => _AppointmentsFilterBarState();
}

class _AppointmentsFilterBarState extends State<AppointmentsFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant AppointmentsFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount => [
    widget.selectedDateRange,
    widget.selectedDept,
    widget.selectedService,
    widget.selectedDoctor,
    widget.selectedStatus,
    widget.selectedPayment,
  ].where((v) => v != 'all').length;

  Future<void> _openFilterDialog() =>
      AppointmentsFilterBarHelper.openFilterDialog(context, widget);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppointmentsSearchField(
              controller: _searchController,
              onChanged: (v) {
                widget.onSearchChanged(v);
                setState(() {});
              },
              onClear: () {
                _searchController.clear();
                widget.onSearchChanged('');
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 10),
          AppointmentsFilterTriggerButtons(
            activeFilterCount: _activeFilterCount,
            hasActiveFilters: widget.hasActiveFilters,
            onOpenFilter: _openFilterDialog,
            onClearFilters: widget.onClearFilters,
          ),
        ],
      ),
    );
  }
}
