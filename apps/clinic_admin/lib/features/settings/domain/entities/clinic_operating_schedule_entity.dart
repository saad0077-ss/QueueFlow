import 'package:equatable/equatable.dart';
import 'operating_hours_day_entity.dart';

class ClinicOperatingScheduleEntity extends Equatable {
  final Map<String, OperatingHoursDayEntity> days;
  final int queueCutoffMin;
  final int slotDurationMin;
  final bool emergencyOnCall;
  final String emergencyPhone;
  final String holidayNotice;

  const ClinicOperatingScheduleEntity({
    this.days = const {},
    this.queueCutoffMin = 60,
    this.slotDurationMin = 15,
    this.emergencyOnCall = true,
    this.emergencyPhone = '+91 98470 12345',
    this.holidayNotice =
        'Clinic will operate on a half-day schedule on upcoming public holidays. Evening OPD remains closed.',
  });

  int get totalWeeklyHours {
    int totalMinutes = 0;
    for (final d in days.values) {
      totalMinutes += d.netMinutes;
    }
    return (totalMinutes / 60.0).round();
  }

  /// Today's hours as of [now]: null when nothing is configured.
  /// Returns (isOpenNow, label) e.g. (true, 'OPEN NOW · CLOSES 20:00').
  ({bool isOpen, String label})? statusAt(DateTime now) {
    if (days.isEmpty) return null;
    const keys = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final d = days[keys[now.weekday - 1]];
    if (d == null || !d.isOpen) return (isOpen: false, label: 'CLOSED TODAY');
    final cur = now.hour * 60 + now.minute;
    final o = OperatingHoursDayEntity.parseMinutes(d.openTime);
    final c = OperatingHoursDayEntity.parseMinutes(d.closeTime);
    final open = c > o ? (cur >= o && cur < c) : (cur >= o || cur < c);
    if (open) return (isOpen: true, label: 'OPEN NOW · CLOSES ${d.closeTime}');
    return (
      isOpen: false,
      label: cur < o
          ? 'CLOSED · OPENS ${d.openTime}'
          : 'CLOSED · OPENS TOMORROW',
    );
  }

  String get scheduleSummary {
    // Nothing configured yet: don't publish made-up hours to patients.
    if (days.isEmpty) return '';
    final mon = days['monday'];
    final sat = days['saturday'];
    final sun = days['sunday'];
    final monTime = mon != null && mon.isOpen
        ? '${mon.openTime} – ${mon.closeTime}'
        : 'Closed';
    final satTime = sat != null && sat.isOpen
        ? '${sat.openTime} – ${sat.closeTime}'
        : 'Closed';
    final sunTime = sun != null && sun.isOpen
        ? '${sun.openTime} – ${sun.closeTime}'
        : 'Closed';
    if (monTime == satTime && sunTime == 'Closed') {
      return 'Mon–Sat: $monTime · Sun: Closed';
    }
    return 'Mon–Fri: $monTime · Sat: $satTime · Sun: $sunTime';
  }

  ClinicOperatingScheduleEntity copyWith({
    Map<String, OperatingHoursDayEntity>? days,
    int? queueCutoffMin,
    int? slotDurationMin,
    bool? emergencyOnCall,
    String? emergencyPhone,
    String? holidayNotice,
  }) {
    return ClinicOperatingScheduleEntity(
      days: days ?? this.days,
      queueCutoffMin: queueCutoffMin ?? this.queueCutoffMin,
      slotDurationMin: slotDurationMin ?? this.slotDurationMin,
      emergencyOnCall: emergencyOnCall ?? this.emergencyOnCall,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      holidayNotice: holidayNotice ?? this.holidayNotice,
    );
  }

  @override
  List<Object?> get props => [
    days,
    queueCutoffMin,
    slotDurationMin,
    emergencyOnCall,
    emergencyPhone,
    holidayNotice,
  ];
}
