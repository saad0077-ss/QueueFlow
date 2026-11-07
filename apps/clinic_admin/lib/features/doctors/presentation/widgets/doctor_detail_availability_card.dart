import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_daily_schedule.dart';

/// Availability section of the doctor detail page: weekly working hours plus
/// time off / leave. Leave dates are what patients see as blocked (red) when
/// booking.
class DoctorDetailAvailabilityCard extends StatefulWidget {
  final ClinicDoctorProfileEntity doctor;
  final VoidCallback onEditSchedule;
  final ValueChanged<List<String>> onLeaveChanged;

  const DoctorDetailAvailabilityCard({
    super.key,
    required this.doctor,
    required this.onEditSchedule,
    required this.onLeaveChanged,
  });

  @override
  State<DoctorDetailAvailabilityCard> createState() =>
      _DoctorDetailAvailabilityCardState();
}

class _DoctorDetailAvailabilityCardState
    extends State<DoctorDetailAvailabilityCard> {
  static const _days = [
    ('mon', 'Mon', 'Monday'),
    ('tue', 'Tue', 'Tuesday'),
    ('wed', 'Wed', 'Wednesday'),
    ('thu', 'Thu', 'Thursday'),
    ('fri', 'Fri', 'Friday'),
    ('sat', 'Sat', 'Saturday'),
    ('sun', 'Sun', 'Sunday'),
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late String _selectedDayKey;

  @override
  void initState() {
    super.initState();
    _selectedDayKey = _days[DateTime.now().weekday - 1].$1;
  }

  // ── helpers ────────────────────────────────────────────────────────────
  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? _parse(String s) => DateTime.tryParse(s);

  static String _short(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  static int _mins(String t) {
    final p = t.split(':');
    if (p.length < 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  int _slotCount(DoctorDailySchedule s) {
    final slot = widget.doctor.slotDuration > 0 ? widget.doctor.slotDuration : 20;
    var total = _mins(s.end) - _mins(s.start);
    if (s.breakStart.isNotEmpty && s.breakEnd.isNotEmpty) {
      total -= (_mins(s.breakEnd) - _mins(s.breakStart));
    }
    return total <= 0 ? 0 : total ~/ slot;
  }

  /// Upcoming leave grouped into consecutive ranges.
  List<List<DateTime>> _leaveRanges() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final dates = widget.doctor.leaveDates
        .map(_parse)
        .whereType<DateTime>()
        .where((d) => !d.isBefore(start))
        .toSet()
        .toList()
      ..sort();
    final ranges = <List<DateTime>>[];
    for (final d in dates) {
      if (ranges.isNotEmpty && d.difference(ranges.last.last).inDays == 1) {
        ranges.last.add(d);
      } else {
        ranges.add([d]);
      }
    }
    return ranges;
  }

  Future<void> _addLeave() async {
    final colors = context.colors;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Widget themed(BuildContext ctx, Widget? child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: colors.primary,
              brightness: colors.isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
    // Compact dialog pickers (From, then To) instead of the full-screen range picker.
    final from = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Leave from',
      builder: themed,
    );
    if (from == null || !mounted) return;
    final to = await showDatePicker(
      context: context,
      initialDate: from,
      firstDate: from,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Leave until',
      builder: themed,
    );
    if (to == null) return;

    final set = widget.doctor.leaveDates.toSet();
    var d = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!d.isAfter(end)) {
      set.add(_key(d));
      d = d.add(const Duration(days: 1));
    }
    widget.onLeaveChanged(set.toList()..sort());
  }

  void _removeRange(List<DateTime> range) {
    final remove = range.map(_key).toSet();
    widget.onLeaveChanged(
      widget.doctor.leaveDates.where((k) => !remove.contains(k)).toList(),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final schedule = widget.doctor.weeklySchedule.isNotEmpty
        ? widget.doctor.weeklySchedule
        : DoctorDailySchedule.defaultWeekly();
    final working = _days.where((d) => schedule[d.$1]?.enabled ?? false).toList();
    final slot = widget.doctor.slotDuration > 0 ? widget.doctor.slotDuration : 20;
    final leave = _leaveRanges();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient accent strip
          Container(height: 4, decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(colors),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(colors, Icons.event_available_rounded,
                        '${working.length} working day${working.length == 1 ? '' : 's'}', colors.success),
                    _chip(colors, Icons.timelapse_rounded, '$slot min slots', colors.primary),
                    _chip(colors, Icons.beach_access_rounded,
                        leave.isEmpty ? 'No upcoming leave' : '${leave.length} leave period${leave.length == 1 ? '' : 's'}',
                        leave.isEmpty ? colors.textMuted : colors.error),
                  ],
                ),
                const SizedBox(height: 18),
                _sectionLabel(colors, 'WEEKLY HOURS'),
                const SizedBox(height: 10),
                LayoutBuilder(builder: (context, c) {
                  final cols = c.maxWidth >= 560 ? 7 : 4;
                  final w = (c.maxWidth - (cols - 1) * 8) / cols;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (key, short, _) in _days)
                        _dayTile(colors, w, key, short, schedule[key]),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                _dayDetail(colors, schedule),
                const SizedBox(height: 20),
                Divider(color: colors.border, height: 1),
                const SizedBox(height: 16),
                _leaveSection(colors, leave),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(AppColorsExtension colors) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.calendar_month_rounded, size: 19, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Availability',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary)),
              Text('Working hours & time off shown to patients',
                  style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: widget.onEditSchedule,
          icon: Icon(Icons.edit_calendar_rounded, size: 15, color: colors.primary),
          label: Text('Edit hours',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: colors.primary)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _chip(AppColorsExtension colors, IconData icon, String text, Color tone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tone),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: tone)),
        ],
      ),
    );
  }

  Widget _sectionLabel(AppColorsExtension colors, String text) => Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: colors.textMuted),
      );

  Widget _dayTile(AppColorsExtension colors, double width, String key, String short,
      DoctorDailySchedule? s) {
    final on = s?.enabled ?? false;
    final selected = key == _selectedDayKey;
    return InkWell(
      onTap: () => setState(() => _selectedDayKey = key),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          gradient: selected && on ? AppColors.primaryGradient : null,
          color: selected && on
              ? null
              : (on ? colors.surfaceSecondary : colors.background),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(short,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: selected && on
                      ? Colors.white
                      : (on ? colors.textPrimary : colors.textMuted),
                )),
            const SizedBox(height: 6),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? (selected ? Colors.white : colors.success) : colors.textMuted.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              on ? DoctorDailySchedule.formatTime12h(s!.start).replaceAll(':00', '') : 'Off',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: selected && on ? Colors.white70 : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayDetail(AppColorsExtension colors, Map<String, DoctorDailySchedule> schedule) {
    final (key, _, full) = _days.firstWhere((d) => d.$1 == _selectedDayKey);
    final s = schedule[key];
    final on = s?.enabled ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: !on || s == null
          ? Row(
              children: [
                Icon(Icons.bedtime_rounded, size: 18, color: colors.textMuted),
                const SizedBox(width: 10),
                Text('$full · Day off — not bookable',
                    style: GoogleFonts.inter(
                        fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.textMuted)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(full,
                          style: GoogleFonts.inter(
                              fontSize: 13.5, fontWeight: FontWeight.w800, color: colors.textPrimary)),
                    ),
                    Text('${_slotCount(s)} slots',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w700, color: colors.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${DoctorDailySchedule.formatTime12h(s.start)} – ${DoctorDailySchedule.formatTime12h(s.end)}',
                  style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
                ),
                const SizedBox(height: 12),
                _timeline(colors, s),
                if (s.breakStart.isNotEmpty && s.breakEnd.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.free_breakfast_rounded, size: 13, color: colors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Break ${DoctorDailySchedule.formatTime12h(s.breakStart)} – ${DoctorDailySchedule.formatTime12h(s.breakEnd)}',
                        style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  /// Bar showing working time with the break carved out.
  Widget _timeline(AppColorsExtension colors, DoctorDailySchedule s) {
    final start = _mins(s.start), end = _mins(s.end);
    final span = (end - start).clamp(1, 24 * 60);
    final hasBreak = s.breakStart.isNotEmpty && s.breakEnd.isNotEmpty;
    final b0 = hasBreak ? ((_mins(s.breakStart) - start) / span).clamp(0.0, 1.0) : 0.0;
    final b1 = hasBreak ? ((_mins(s.breakEnd) - start) / span).clamp(0.0, 1.0) : 0.0;

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return SizedBox(
        height: 10,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            if (hasBreak && b1 > b0)
              Positioned(
                left: w * b0,
                width: w * (b1 - b0),
                top: 0,
                bottom: 0,
                child: Container(color: colors.surfaceSecondary),
              ),
          ],
        ),
      );
    });
  }

  Widget _leaveSection(AppColorsExtension colors, List<List<DateTime>> leave) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionLabel(colors, 'TIME OFF & LEAVE')),
            TextButton.icon(
              onPressed: _addLeave,
              icon: Icon(Icons.add_rounded, size: 16, color: colors.error),
              label: Text('Add leave',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700, color: colors.error)),
              style: TextButton.styleFrom(
                backgroundColor: colors.error.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (leave.isEmpty)
          Text(
            'No leave scheduled. Add dates the doctor is away — they will show in red '
            'and be blocked when patients book.',
            style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted, height: 1.4),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in leave)
                Container(
                  padding: const EdgeInsets.only(left: 11, right: 4, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.error.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 7, color: colors.error),
                      const SizedBox(width: 7),
                      Text(
                        r.length == 1
                            ? _short(r.first)
                            : '${_short(r.first)} – ${_short(r.last)} · ${r.length} days',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w700, color: colors.error),
                      ),
                      InkWell(
                        onTap: () => _removeRange(r),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(Icons.close_rounded, size: 14, color: colors.error),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
