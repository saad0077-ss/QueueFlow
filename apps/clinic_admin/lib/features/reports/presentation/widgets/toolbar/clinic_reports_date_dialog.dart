import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'clinic_reports_date_field_tile.dart';

class ClinicReportsDateDialog extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final ValueChanged<DateTimeRange> onApply;

  const ClinicReportsDateDialog({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialStart,
    required DateTime initialEnd,
    required ValueChanged<DateTimeRange> onApply,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ClinicReportsDateDialog(
        initialStart: initialStart,
        initialEnd: initialEnd,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ClinicReportsDateDialog> createState() =>
      _ClinicReportsDateDialogState();
}

class _ClinicReportsDateDialogState extends State<ClinicReportsDateDialog> {
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  String _format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
          if (_start.isAfter(_end)) _end = _start;
        } else {
          _end = picked;
          if (_end.isBefore(_start)) _start = _end;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Range',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            ClinicReportsDateFieldTile(
              label: 'Start Date',
              value: _format(_start),
              onTap: () => _pickDate(true),
            ),
            const SizedBox(height: 12),
            ClinicReportsDateFieldTile(
              label: 'End Date',
              value: _format(_end),
              onTap: () => _pickDate(false),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: colors.textMuted),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply(DateTimeRange(start: _start, end: _end));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply Range'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
