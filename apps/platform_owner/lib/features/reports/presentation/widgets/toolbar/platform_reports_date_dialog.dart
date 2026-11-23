import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'platform_reports_date_inputs.dart';
import 'platform_reports_date_presets.dart';

class PlatformReportsDateDialog extends StatefulWidget {
  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange?> onApply;

  const PlatformReportsDateDialog({
    super.key,
    required this.initialRange,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTimeRange? initialRange,
    required ValueChanged<DateTimeRange?> onApply,
  }) {
    return AppFilterDialogScaffold.show(
      context,
      builder: (ctx) => PlatformReportsDateDialog(
        initialRange: initialRange,
        onApply: onApply,
      ),
    );
  }

  @override
  State<PlatformReportsDateDialog> createState() => _PlatformReportsDateDialogState();
}

class _PlatformReportsDateDialogState extends State<PlatformReportsDateDialog> {
  late DateTime _start;
  late DateTime _end;
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = widget.initialRange?.start ?? now.subtract(const Duration(days: 30));
    _end = widget.initialRange?.end ?? now;
  }

  void _applyPreset(String key) {
    final now = DateTime.now();
    setState(() {
      _selectedPreset = key;
      if (key == '7d') {
        _start = now.subtract(const Duration(days: 7));
        _end = now;
      } else if (key == '30d') {
        _start = now.subtract(const Duration(days: 30));
        _end = now;
      } else if (key == '90d') {
        _start = now.subtract(const Duration(days: 90));
        _end = now;
      } else if (key == 'month') {
        _start = DateTime(now.year, now.month, 1);
        _end = now;
      }
    });
  }

  void _reset() {
    final now = DateTime.now();
    setState(() {
      _selectedPreset = '30d';
      _start = now.subtract(const Duration(days: 30));
      _end = now;
    });
  }

  void _apply() {
    if (_start.isAfter(_end)) {
      final tmp = _start;
      _start = _end;
      _end = tmp;
    }
    widget.onApply(DateTimeRange(start: _start, end: _end));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppFilterDialogScaffold(
      maxWidth: 520,
      header: AppFilterHeader(
        title: 'Filter Reports by Date',
        subtitle: 'Select custom start & end dates or choose a preset',
        onClose: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppFilterSectionTitle('QUICK DURATION PRESETS'),
            const SizedBox(height: 10),
            PlatformReportsDatePresets(
              selectedPreset: _selectedPreset,
              onSelectPreset: _applyPreset,
            ),
            const SizedBox(height: 20),
            const AppFilterSectionTitle('CUSTOM DATE RANGE'),
            const SizedBox(height: 10),
            PlatformReportsDateInputs(
              startDate: _start,
              endDate: _end,
              onStartDateChanged: (d) => setState(() {
                _start = d;
                _selectedPreset = null;
              }),
              onEndDateChanged: (d) => setState(() {
                _end = d;
                _selectedPreset = null;
              }),
            ),
          ],
        ),
      ),
      footer: AppFilterFooter(
        onResetAll: _reset,
        onCancel: () => Navigator.pop(context),
        onApply: _apply,
        applyLabel: 'Apply Date Range',
      ),
    );
  }
}
