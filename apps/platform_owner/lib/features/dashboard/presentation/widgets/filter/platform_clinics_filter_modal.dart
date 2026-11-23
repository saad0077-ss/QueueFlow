import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'platform_clinics_filter_plan_section.dart';
import 'platform_clinics_filter_status_section.dart';

class PlatformClinicsFilterModal extends StatefulWidget {
  final String initialPlan;
  final String initialStatus;
  final void Function({required String plan, required String status}) onApply;

  const PlatformClinicsFilterModal({
    super.key,
    required this.initialPlan,
    required this.initialStatus,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required String initialPlan,
    required String initialStatus,
    required void Function({required String plan, required String status})
    onApply,
  }) {
    return AppFilterDialogScaffold.show(
      context,
      builder: (_) => PlatformClinicsFilterModal(
        initialPlan: initialPlan,
        initialStatus: initialStatus,
        onApply: onApply,
      ),
    );
  }

  @override
  State<PlatformClinicsFilterModal> createState() =>
      _PlatformClinicsFilterModalState();
}

class _PlatformClinicsFilterModalState
    extends State<PlatformClinicsFilterModal> {
  late String _selectedPlan;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.initialPlan;
    _selectedStatus = widget.initialStatus;
  }

  void _resetAll() => setState(() {
    _selectedPlan = 'All Plans';
    _selectedStatus = 'All Statuses';
  });

  void _apply() {
    widget.onApply(plan: _selectedPlan, status: _selectedStatus);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppFilterDialogScaffold(
      header: AppFilterHeader(
        title: 'Filter Healthcare Clinics',
        subtitle: 'Select subscription tier and facility operational status',
        onClose: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppFilterSectionTitle('SUBSCRIPTION PLAN / TIER'),
            const SizedBox(height: 10),
            PlatformClinicsFilterPlanSection(
              selectedPlan: _selectedPlan,
              onSelectPlan: (p) => setState(() => _selectedPlan = p),
            ),
            const SizedBox(height: 20),
            const AppFilterSectionTitle('FACILITY OPERATIONAL STATUS'),
            const SizedBox(height: 10),
            PlatformClinicsFilterStatusSection(
              selectedStatus: _selectedStatus,
              onSelectStatus: (s) => setState(() => _selectedStatus = s),
            ),
          ],
        ),
      ),
      footer: AppFilterFooter(
        onResetAll: _resetAll,
        onCancel: () => Navigator.of(context).pop(),
        onApply: _apply,
      ),
    );
  }
}
