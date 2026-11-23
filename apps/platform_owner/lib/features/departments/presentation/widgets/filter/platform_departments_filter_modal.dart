import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'platform_departments_filter_status_section.dart';

class PlatformDepartmentsFilterModal extends StatefulWidget {
  final String initialStatus;
  final ValueChanged<String> onApply;

  const PlatformDepartmentsFilterModal({
    super.key,
    required this.initialStatus,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required String initialStatus,
    required ValueChanged<String> onApply,
  }) {
    return AppFilterDialogScaffold.show(
      context,
      builder: (_) => PlatformDepartmentsFilterModal(
        initialStatus: initialStatus,
        onApply: onApply,
      ),
    );
  }

  @override
  State<PlatformDepartmentsFilterModal> createState() =>
      _PlatformDepartmentsFilterModalState();
}

class _PlatformDepartmentsFilterModalState
    extends State<PlatformDepartmentsFilterModal> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
  }

  void _resetAll() => setState(() => _selectedStatus = 'All Statuses');

  void _apply() {
    widget.onApply(_selectedStatus);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppFilterDialogScaffold(
      header: AppFilterHeader(
        title: 'Filter Departments',
        subtitle:
            'Select specialty operational status and active clinician triage',
        onClose: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppFilterSectionTitle('SPECIALTY OPERATIONAL STATUS'),
            const SizedBox(height: 10),
            PlatformDepartmentsFilterStatusSection(
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
