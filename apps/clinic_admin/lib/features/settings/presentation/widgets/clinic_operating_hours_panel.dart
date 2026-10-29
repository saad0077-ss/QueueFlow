import 'package:flutter/material.dart';
import '../../domain/entities/clinic_operating_schedule_entity.dart';
import '../../domain/entities/operating_hours_day_entity.dart';
import 'hours_action_footer.dart';
import 'hours_policies_card.dart';
import 'hours_presets_toolbar.dart';
import 'hours_schedule_banner.dart';
import 'hours_visual_timeline.dart';
import 'operating_day_card.dart';

class ClinicOperatingHoursPanel extends StatefulWidget {
  final ClinicOperatingScheduleEntity schedule;
  final ValueChanged<OperatingHoursDayEntity> onDayChanged;
  final ValueChanged<String> onApplyPreset;
  final VoidCallback onCopyMonday;
  final ValueChanged<ClinicOperatingScheduleEntity> onSave;
  final VoidCallback? onRevert;

  const ClinicOperatingHoursPanel({
    super.key,
    required this.schedule,
    required this.onDayChanged,
    required this.onApplyPreset,
    required this.onCopyMonday,
    required this.onSave,
    this.onRevert,
  });

  @override
  State<ClinicOperatingHoursPanel> createState() => _ClinicOperatingHoursPanelState();
}

class _ClinicOperatingHoursPanelState extends State<ClinicOperatingHoursPanel> {
  late int _cutoff;
  late int _slot;
  late bool _emergency;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _noticeCtrl;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  void _initValues() {
    _cutoff = widget.schedule.queueCutoffMin;
    _slot = widget.schedule.slotDurationMin;
    _emergency = widget.schedule.emergencyOnCall;
    _phoneCtrl = TextEditingController(text: widget.schedule.emergencyPhone);
    _noticeCtrl = TextEditingController(text: widget.schedule.holidayNotice);
  }

  @override
  void didUpdateWidget(covariant ClinicOperatingHoursPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedule != widget.schedule) {
      _cutoff = widget.schedule.queueCutoffMin;
      _slot = widget.schedule.slotDurationMin;
      _emergency = widget.schedule.emergencyOnCall;
      _phoneCtrl.text = widget.schedule.emergencyPhone;
      _noticeCtrl.text = widget.schedule.holidayNotice;
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _noticeCtrl.dispose();
    super.dispose();
  }

  void _saveAll() {
    final updated = widget.schedule.copyWith(
      queueCutoffMin: _cutoff,
      slotDurationMin: _slot,
      emergencyOnCall: _emergency,
      emergencyPhone: _phoneCtrl.text.trim(),
      holidayNotice: _noticeCtrl.text.trim(),
    );
    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HoursScheduleBanner(
          totalWeeklyHours: widget.schedule.totalWeeklyHours,
          isEmergencyOnCall: _emergency,
          scheduleSummary: widget.schedule.scheduleSummary,
        ),
        const SizedBox(height: 12),
        HoursPresetsToolbar(
          onApplyPreset: widget.onApplyPreset,
          onCopyMonday: widget.onCopyMonday,
        ),
        const SizedBox(height: 14),
        ...widget.schedule.days.values.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OperatingDayCard(
            day: d,
            onDayChanged: widget.onDayChanged,
            onCopyDay: () => widget.onCopyMonday(),
          ),
        )),
        const SizedBox(height: 20),
        HoursVisualTimeline(days: widget.schedule.days),
        const SizedBox(height: 20),
        HoursPoliciesCard(
          cutoffMin: _cutoff,
          slotMin: _slot,
          emergencyOnCall: _emergency,
          emergencyPhoneCtrl: _phoneCtrl,
          holidayNoticeCtrl: _noticeCtrl,
          onCutoffChanged: (v) => setState(() => _cutoff = v),
          onSlotChanged: (v) => setState(() => _slot = v),
          onEmergencyToggled: (v) => setState(() => _emergency = v),
        ),
        const SizedBox(height: 16),
        HoursActionFooter(
          onRevert: () {
            widget.onRevert?.call();
            setState(_initValues);
          },
          onSave: _saveAll,
        ),
      ],
    );
  }
}
