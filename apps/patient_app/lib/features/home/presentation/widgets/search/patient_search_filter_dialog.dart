import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'patient_search_dialog_actions.dart';
import 'patient_search_filter_dropdowns.dart';
import 'patient_search_filter_resolver.dart';
import 'patient_search_quick_prefs.dart';

class PatientSearchFilterDialog extends StatefulWidget {
  final List<String> allDepartments;
  final String initialDepartment;
  final String initialService;
  final Set<String> initialQuickFilters;
  final void Function(String dept, String service, Set<String> quick) onApply;

  const PatientSearchFilterDialog({
    super.key,
    required this.allDepartments,
    required this.initialDepartment,
    required this.initialService,
    required this.initialQuickFilters,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> allDepartments,
    required String initialDepartment,
    required String initialService,
    required Set<String> initialQuickFilters,
    required void Function(String dept, String service, Set<String> quick)
    onApply,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => PatientSearchFilterDialog(
        allDepartments: allDepartments,
        initialDepartment: initialDepartment,
        initialService: initialService,
        initialQuickFilters: initialQuickFilters,
        onApply: onApply,
      ),
    );
  }

  @override
  State<PatientSearchFilterDialog> createState() =>
      _PatientSearchFilterDialogState();
}

class _PatientSearchFilterDialogState extends State<PatientSearchFilterDialog> {
  late String _tempDept;
  late String _tempService;
  late Set<String> _tempQuick;

  @override
  void initState() {
    super.initState();
    _tempDept = widget.initialDepartment;
    _tempService = widget.initialService;
    _tempQuick = Set<String>.from(widget.initialQuickFilters);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final availableServices =
        PatientSearchFilterResolver.getServicesForDepartment(_tempDept);

    return Dialog(
      backgroundColor: colors.surfaceElevated,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.border, width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, colors),
                const SizedBox(height: 18),
                PatientSearchFilterDropdowns(
                  allDepartments: widget.allDepartments,
                  tempDept: _tempDept,
                  tempService: _tempService,
                  availableServices: availableServices,
                  onDeptChanged: (d) => setState(() {
                    _tempDept = d;
                    _tempService = 'all';
                  }),
                  onServiceChanged: (s) => setState(() => _tempService = s),
                  colors: colors,
                ),
                const SizedBox(height: 18),
                PatientSearchQuickPrefs(
                  tempQuick: _tempQuick,
                  onToggle: (k) => setState(
                    () => _tempQuick.contains(k)
                        ? _tempQuick.remove(k)
                        : _tempQuick.add(k),
                  ),
                  colors: colors,
                ),
                const SizedBox(height: 24),
                PatientSearchDialogActions(
                  onReset: () => setState(() {
                    _tempDept = 'all';
                    _tempService = 'all';
                    _tempQuick.clear();
                  }),
                  onApply: () {
                    Navigator.of(context).pop();
                    widget.onApply(_tempDept, _tempService, _tempQuick);
                  },
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppColorsExtension colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.tune_rounded, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Filter Clinics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: colors.textSubtle),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
