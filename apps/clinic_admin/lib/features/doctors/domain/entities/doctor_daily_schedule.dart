import 'package:equatable/equatable.dart';

/// Schedule entry for a single day of the week.
class DoctorDailySchedule extends Equatable {
  final String dayKey; // 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'
  final String dayName; // 'Monday', 'Tuesday', etc.
  final String shortName; // 'Mon', 'Tue', etc.
  final bool enabled;
  final String start; // '09:00'
  final String end; // '17:00'
  final String breakStart; // '13:00'
  final String breakEnd; // '14:00'

  const DoctorDailySchedule({
    required this.dayKey,
    required this.dayName,
    required this.shortName,
    this.enabled = true,
    this.start = '09:00',
    this.end = '17:00',
    this.breakStart = '13:00',
    this.breakEnd = '14:00',
  });

  DoctorDailySchedule copyWith({
    String? dayKey,
    String? dayName,
    String? shortName,
    bool? enabled,
    String? start,
    String? end,
    String? breakStart,
    String? breakEnd,
  }) {
    return DoctorDailySchedule(
      dayKey: dayKey ?? this.dayKey,
      dayName: dayName ?? this.dayName,
      shortName: shortName ?? this.shortName,
      enabled: enabled ?? this.enabled,
      start: start ?? this.start,
      end: end ?? this.end,
      breakStart: breakStart ?? this.breakStart,
      breakEnd: breakEnd ?? this.breakEnd,
    );
  }

  static String formatTime12h(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final mStr = minute.toString().padLeft(2, '0');
    return '$h12:$mStr $period';
  }

  static Map<String, DoctorDailySchedule> defaultWeekly() {
    const days = [
      ('mon', 'Monday', 'Mon', true),
      ('tue', 'Tuesday', 'Tue', true),
      ('wed', 'Wednesday', 'Wed', true),
      ('thu', 'Thursday', 'Thu', true),
      ('fri', 'Friday', 'Fri', true),
      ('sat', 'Saturday', 'Sat', true),
      ('sun', 'Sunday', 'Sun', true),
    ];

    return {
      for (final (key, name, short, isWork) in days)
        key: DoctorDailySchedule(
          dayKey: key,
          dayName: name,
          shortName: short,
          enabled: isWork,
          start: '08:00',
          end: '17:00',
          breakStart: '13:00',
          breakEnd: '14:00',
        ),
    };
  }

  @override
  List<Object?> get props => [
    dayKey,
    dayName,
    shortName,
    enabled,
    start,
    end,
    breakStart,
    breakEnd,
  ];
}
