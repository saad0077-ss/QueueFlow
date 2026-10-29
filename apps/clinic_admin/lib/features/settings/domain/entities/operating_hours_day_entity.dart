import 'package:equatable/equatable.dart';

class OperatingHoursDayEntity extends Equatable {
  final String dayKey;
  final String dayName;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final bool hasBreak;
  final String breakStart;
  final String breakEnd;

  const OperatingHoursDayEntity({
    required this.dayKey,
    required this.dayName,
    this.isOpen = true,
    this.openTime = '09:00',
    this.closeTime = '20:00',
    this.hasBreak = false,
    this.breakStart = '13:00',
    this.breakEnd = '14:00',
  });

  String get shortName => dayName.length >= 3 ? dayName.substring(0, 3) : dayName;

  static int parseMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  int get netMinutes {
    if (!isOpen) return 0;
    final o = parseMinutes(openTime);
    final c = parseMinutes(closeTime);
    if (c <= o) return 0;
    var span = c - o;
    if (hasBreak && breakStart.isNotEmpty && breakEnd.isNotEmpty) {
      final bs = parseMinutes(breakStart);
      final be = parseMinutes(breakEnd);
      if (be > bs && bs >= o && be <= c) span -= (be - bs);
    }
    return span > 0 ? span : 0;
  }

  String get netHoursText {
    if (!isOpen) return 'Closed';
    final hrs = netMinutes / 60.0;
    return hrs == hrs.roundToDouble() ? '${hrs.toInt()} hrs' : '${hrs.toStringAsFixed(1)} hrs';
  }

  OperatingHoursDayEntity copyWith({
    String? dayKey,
    String? dayName,
    bool? isOpen,
    String? openTime,
    String? closeTime,
    bool? hasBreak,
    String? breakStart,
    String? breakEnd,
  }) {
    return OperatingHoursDayEntity(
      dayKey: dayKey ?? this.dayKey,
      dayName: dayName ?? this.dayName,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      hasBreak: hasBreak ?? this.hasBreak,
      breakStart: breakStart ?? this.breakStart,
      breakEnd: breakEnd ?? this.breakEnd,
    );
  }

  @override
  List<Object?> get props => [dayKey, dayName, isOpen, openTime, closeTime, hasBreak, breakStart, breakEnd];
}
