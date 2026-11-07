import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateUtils;

/// One weekday of a doctor's availability, as set by the clinic admin.
class ClinicDoctorDayHours extends Equatable {
  final bool enabled;
  final String start; // 'HH:mm'
  final String end;
  final String breakStart;
  final String breakEnd;

  const ClinicDoctorDayHours({
    required this.enabled,
    required this.start,
    required this.end,
    this.breakStart = '',
    this.breakEnd = '',
  });

  @override
  List<Object?> get props => [enabled, start, end, breakStart, breakEnd];
}

class ClinicDoctorItem extends Equatable {
  final String id;
  final String name;
  final String initials;
  final String title;
  final String specialty;
  final String schedule;
  final bool isAvailable;
  final List<String> services;
  final String department;

  /// Photo uploaded by the clinic admin (data URI or http URL); empty if none.
  final String photoUrl;

  /// Average of patient ratings (0 when nobody has rated yet).
  final double rating;
  final int reviewCount;

  /// Keyed by 'mon'..'sun'. Empty means the clinic has set no availability.
  final Map<String, ClinicDoctorDayHours> weeklySchedule;

  /// Leave days as 'yyyy-MM-dd' — not bookable.
  final List<String> leaveDates;

  /// Appointment length (minutes) set by the clinic for this doctor.
  final int slotDuration;

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool isOnLeave(DateTime date) => leaveDates.contains(dateKey(date));

  /// Whether the weekday is a working day in the weekly schedule.
  bool worksOnWeekday(DateTime date) => _hoursOn(date) != null;

  static const _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

  ClinicDoctorDayHours? _hoursOn(DateTime date) {
    final h = weeklySchedule[_dayKeys[date.weekday - 1]];
    return (h != null && h.enabled) ? h : null;
  }

  static int? _minutes(String hhmm) {
    final p = hhmm.split(':');
    if (p.length < 2) return null;
    final h = int.tryParse(p[0].trim()), m = int.tryParse(p[1].trim());
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  /// Whether patients can book this doctor on [date] (not past, doctor is
  /// on duty, and the weekday is enabled in the clinic's availability).
  bool isBookableOn(DateTime date) {
    final today = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    if (day.isBefore(DateTime(today.year, today.month, today.day))) return false;
    if (!isAvailable || isOnLeave(date)) return false;
    return _hoursOn(date) != null;
  }

  /// Bookable start times for [date], in 'hh:mm AM' format, from the doctor's
  /// working hours minus the break, stepping by [slotMinutes].
  List<String> slotsFor(DateTime date, int slotMinutes) {
    if (!isBookableOn(date)) return const [];
    final h = _hoursOn(date)!;
    final start = _minutes(h.start), end = _minutes(h.end);
    if (start == null || end == null || slotMinutes <= 0) return const [];
    final bStart = _minutes(h.breakStart), bEnd = _minutes(h.breakEnd);
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(date, now);
    final nowMin = now.hour * 60 + now.minute;

    final slots = <String>[];
    for (var t = start; t + slotMinutes <= end; t += slotMinutes) {
      if (bStart != null && bEnd != null && t < bEnd && t + slotMinutes > bStart) continue;
      // Booking closes 1 hour before the consultation start (today only).
      if (isToday && t < nowMin + 60) continue;
      final hour = t ~/ 60, min = t % 60;
      final h12 = hour % 12 == 0 ? 12 : hour % 12;
      slots.add('${h12.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM'}');
    }
    return slots;
  }

  const ClinicDoctorItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.title,
    this.specialty = 'General Medicine',
    this.schedule = 'Mon–Sat, 9:00 AM – 5:00 PM',
    this.isAvailable = true,
    this.services = const [],
    this.department = '',
    this.photoUrl = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.weeklySchedule = const {},
    this.leaveDates = const [],
    this.slotDuration = 20,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        initials,
        title,
        specialty,
        schedule,
        isAvailable,
        services,
        department,
        photoUrl,
        rating,
        reviewCount,
        weeklySchedule,
        leaveDates,
        slotDuration,
      ];
}
