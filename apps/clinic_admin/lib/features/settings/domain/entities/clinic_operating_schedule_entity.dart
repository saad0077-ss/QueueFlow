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
    this.holidayNotice = 'Clinic will operate on a half-day schedule on upcoming public holidays. Evening OPD remains closed.',
  });

  int get totalWeeklyHours {
    int totalMinutes = 0;
    for (final d in days.values) {
      totalMinutes += d.netMinutes;
    }
    return (totalMinutes / 60.0).round();
  }

  String get scheduleSummary {
    if (days.isEmpty) return 'Mon–Sat: 9:00 AM – 8:00 PM · Sun: Closed';
    final mon = days['monday'];
    final sat = days['saturday'];
    final sun = days['sunday'];
    final monTime = mon != null && mon.isOpen ? '${mon.openTime} – ${mon.closeTime}' : 'Closed';
    final satTime = sat != null && sat.isOpen ? '${sat.openTime} – ${sat.closeTime}' : 'Closed';
    final sunTime = sun != null && sun.isOpen ? '${sun.openTime} – ${sun.closeTime}' : 'Closed';
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
  List<Object?> get props => [days, queueCutoffMin, slotDurationMin, emergencyOnCall, emergencyPhone, holidayNotice];
}
