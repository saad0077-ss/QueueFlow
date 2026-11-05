import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_daily_schedule.dart';

class ManageDoctorScheduleDialog extends StatefulWidget {
  final ClinicDoctorProfileEntity doctor;
  final void Function(Map<String, DoctorDailySchedule> schedule, int slotDuration) onSave;

  const ManageDoctorScheduleDialog({
    super.key,
    required this.doctor,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required ClinicDoctorProfileEntity doctor,
    required void Function(Map<String, DoctorDailySchedule> schedule, int slotDuration) onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: ManageDoctorScheduleDialog(
          doctor: doctor,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  State<ManageDoctorScheduleDialog> createState() => _ManageDoctorScheduleDialogState();
}

class _ManageDoctorScheduleDialogState extends State<ManageDoctorScheduleDialog> {
  static const List<(String, String)> _dayDefs = [
    ('mon', 'Monday'),
    ('tue', 'Tuesday'),
    ('wed', 'Wednesday'),
    ('thu', 'Thursday'),
    ('fri', 'Friday'),
    ('sat', 'Saturday'),
    ('sun', 'Sunday'),
  ];

  late int _slotDuration;
  late Map<String, DoctorDailySchedule> _schedule;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _slotDuration = widget.doctor.slotDuration > 0 ? widget.doctor.slotDuration : 20;

    // Deep copy doctor's schedule or fallback to defaults
    final base = widget.doctor.weeklySchedule.isNotEmpty
        ? widget.doctor.weeklySchedule
        : DoctorDailySchedule.defaultWeekly();

    _schedule = {};
    for (final (key, name) in _dayDefs) {
      if (base.containsKey(key)) {
        final item = base[key]!;
        _schedule[key] = item.copyWith();
      } else {
        _schedule[key] = DoctorDailySchedule(
          dayKey: key,
          dayName: name,
          shortName: name.substring(0, 3),
          enabled: key != 'sun',
          start: '09:00',
          end: '17:00',
          breakStart: '13:00',
          breakEnd: '14:00',
        );
      }
    }
  }

  void _copyFirstWorkingDayToAll() {
    setState(() {
      _errorMessage = null;
    });

    final firstWorkingKey = _dayDefs.firstWhere(
      (d) => _schedule[d.$1]?.enabled == true,
      orElse: () => ('', ''),
    ).$1;

    if (firstWorkingKey.isEmpty) {
      setState(() {
        _errorMessage = 'Enable at least one working day first.';
      });
      return;
    }

    final source = _schedule[firstWorkingKey]!;
    setState(() {
      for (final (key, _) in _dayDefs) {
        if (key != firstWorkingKey && _schedule[key]?.enabled == true) {
          final target = _schedule[key]!;
          _schedule[key] = target.copyWith(
            start: source.start,
            end: source.end,
            breakStart: source.breakStart,
            breakEnd: source.breakEnd,
          );
        }
      }
    });
  }

  Future<void> _pickTime(String dayKey, String fieldType, String currentTime) async {
    final colors = context.colors;
    final parts = currentTime.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
    final initialMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (pickerCtx, child) {
        return Theme(
          data: Theme.of(pickerCtx).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: colors.primary,
              brightness: colors.isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) return;

    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    setState(() {
      _errorMessage = null;
      final current = _schedule[dayKey]!;
      switch (fieldType) {
        case 'start':
          _schedule[dayKey] = current.copyWith(start: formatted);
          break;
        case 'end':
          _schedule[dayKey] = current.copyWith(end: formatted);
          break;
        case 'breakStart':
          _schedule[dayKey] = current.copyWith(breakStart: formatted);
          break;
        case 'breakEnd':
          _schedule[dayKey] = current.copyWith(breakEnd: formatted);
          break;
      }
    });
  }

  void _clearBreak(String dayKey) {
    setState(() {
      final current = _schedule[dayKey]!;
      _schedule[dayKey] = current.copyWith(breakStart: '', breakEnd: '');
    });
  }

  void _submit() {
    for (final (key, name) in _dayDefs) {
      final slot = _schedule[key]!;
      if (!slot.enabled) continue;

      if (slot.start.isEmpty || slot.end.isEmpty || slot.start.compareTo(slot.end) >= 0) {
        setState(() {
          _errorMessage = 'Check $name: end time must be after start time.';
        });
        return;
      }

      final hasBreakStart = slot.breakStart.isNotEmpty;
      final hasBreakEnd = slot.breakEnd.isNotEmpty;

      if (hasBreakStart != hasBreakEnd) {
        setState(() {
          _errorMessage = 'Check $name: please set both break start and break end, or clear both.';
        });
        return;
      }

      if (hasBreakStart && hasBreakEnd) {
        if (slot.breakStart.compareTo(slot.breakEnd) >= 0 ||
            slot.breakStart.compareTo(slot.start) < 0 ||
            slot.breakEnd.compareTo(slot.end) > 0) {
          setState(() {
            _errorMessage = 'Check $name: break must fall completely inside working hours ($slot.start - $slot.end).';
          });
          return;
        }
      }
    }

    widget.onSave(_schedule, _slotDuration);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Schedule',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Weekly consultation hours for ${widget.doctor.name}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 20, color: colors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 16),

            // Top settings: slot duration and copy button
            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                // Appointment duration selector
                SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APPOINTMENT DURATION',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _slotDuration,
                            isExpanded: true,
                            dropdownColor: colors.surfaceSecondary,
                            style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
                            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: colors.textMuted),
                            items: const [
                              DropdownMenuItem(value: 10, child: Text('10 minutes')),
                              DropdownMenuItem(value: 15, child: Text('15 minutes')),
                              DropdownMenuItem(value: 20, child: Text('20 minutes')),
                              DropdownMenuItem(value: 30, child: Text('30 minutes')),
                              DropdownMenuItem(value: 45, child: Text('45 minutes')),
                              DropdownMenuItem(value: 60, child: Text('60 minutes')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _slotDuration = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Copy first working day button
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: OutlinedButton.icon(
                    onPressed: _copyFirstWorkingDayToAll,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.border),
                      backgroundColor: colors.surfaceSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: Icon(Icons.copy_rounded, size: 14, color: colors.textMuted),
                    label: Text(
                      'Copy first working day to all',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.errorTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 16, color: colors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Schedule Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: 580,
                        child: Column(
                          children: [
                            // Header Row
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              color: colors.surfaceSecondary,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 125,
                                    child: Text(
                                      'DAY',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 95,
                                    child: Text(
                                      'START',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 95,
                                    child: Text(
                                      'END',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 95,
                                    child: Text(
                                      'BREAK FROM',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 125,
                                    child: Text(
                                      'BREAK TO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: colors.border, height: 1),

                            // Day rows
                            for (var i = 0; i < _dayDefs.length; i++) ...[
                              _buildDayRow(context, _dayDefs[i].$1, _dayDefs[i].$2),
                              if (i < _dayDefs.length - 1)
                                Divider(color: colors.border, height: 1),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 14),

            // Modal Foot Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textMuted,
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Schedule',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, String key, String dayName) {
    final colors = context.colors;
    final slot = _schedule[key]!;
    final isEnabled = slot.enabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: isEnabled ? Colors.transparent : Colors.black.withValues(alpha: 0.05),
      child: Row(
        children: [
          // Day Checkbox + Label
          SizedBox(
            width: 125,
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: isEnabled,
                    activeColor: colors.primary,
                    side: BorderSide(color: colors.border, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      setState(() {
                        _schedule[key] = slot.copyWith(enabled: val ?? false);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dayName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w400,
                      color: isEnabled ? colors.textPrimary : colors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Start Time Picker Button
          SizedBox(
            width: 95,
            child: _buildTimePickerCell(
              context: context,
              key: key,
              field: 'start',
              value: slot.start,
              enabled: isEnabled,
            ),
          ),

          // End Time Picker Button
          SizedBox(
            width: 95,
            child: _buildTimePickerCell(
              context: context,
              key: key,
              field: 'end',
              value: slot.end,
              enabled: isEnabled,
            ),
          ),

          // Break Start Time Picker Button
          SizedBox(
            width: 95,
            child: _buildTimePickerCell(
              context: context,
              key: key,
              field: 'breakStart',
              value: slot.breakStart,
              enabled: isEnabled,
              isOptional: true,
            ),
          ),

          // Break End Time Picker Button
          SizedBox(
            width: 125,
            child: Row(
              children: [
                Expanded(
                  child: _buildTimePickerCell(
                    context: context,
                    key: key,
                    field: 'breakEnd',
                    value: slot.breakEnd,
                    enabled: isEnabled,
                    isOptional: true,
                  ),
                ),
                if (isEnabled && (slot.breakStart.isNotEmpty || slot.breakEnd.isNotEmpty))
                  IconButton(
                    icon: Icon(Icons.clear_rounded, size: 14, color: colors.textMuted),
                    tooltip: 'Clear break',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    onPressed: () => _clearBreak(key),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerCell({
    required BuildContext context,
    required String key,
    required String field,
    required String value,
    required bool enabled,
    bool isOptional = false,
  }) {
    final colors = context.colors;
    final displayText = value.isNotEmpty ? value : (isOptional ? 'None' : '--:--');

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: enabled ? () => _pickTime(key, field, value.isNotEmpty ? value : '09:00') : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: value.isNotEmpty ? colors.border : colors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  displayText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: value.isNotEmpty
                        ? colors.textPrimary
                        : (isOptional ? colors.textMuted : colors.error),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.access_time_rounded, size: 12, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
