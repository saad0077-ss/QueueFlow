import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';

/// Date/time parsing and human-readable status labels for queue gating.
class BookingQueueTimeHelpers {
  const BookingQueueTimeHelpers._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _weekdays = [
    'monday', 'tuesday', 'wednesday', 'thursday',
    'friday', 'saturday', 'sunday',
  ];

  static String formatShortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  static DateTime? parseDateOnly(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(trimmed);
    if (m != null) {
      return DateTime(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      );
    }
    final parsed = DateTime.tryParse(trimmed);
    return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static int? parseMinutes(dynamic v) {
    final m = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AaPp][Mm])?\s*$').firstMatch('$v');
    if (m == null) return null;
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ap = m.group(3)?.toLowerCase();
    if (ap == 'pm' && h < 12) h += 12;
    if (ap == 'am' && h == 12) h = 0;
    return h * 60 + min;
  }

  static String formatMinutes(int totalMinutes) {
    final h24 = (totalMinutes ~/ 60) % 24;
    final m = totalMinutes % 60;
    final period = h24 >= 12 ? 'PM' : 'AM';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }

  static String formatBreakEnd(String breakEnd) {
    final mins = parseMinutes(breakEnd);
    return mins != null ? formatMinutes(mins) : breakEnd;
  }

  static String closedHoursReason(ClinicEntity clinic, DateTime now) {
    final cur = now.hour * 60 + now.minute;
    dynamic openRaw;
    dynamic closeRaw;

    if (clinic.schedule.isNotEmpty) {
      final day = clinic.schedule[_weekdays[now.weekday - 1]];
      if (day is! Map || day['isOpen'] != true) return 'Clinic closed today';
      openRaw = day['openTime'];
      closeRaw = day['closeTime'];
    } else if (clinic.openingHours.isNotEmpty) {
      final m = RegExp(
        r'(\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)?)\s*[-–—]\s*(\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)?)',
      ).firstMatch(clinic.openingHours);
      if (m != null) {
        openRaw = m.group(1);
        closeRaw = m.group(2);
      }
    }

    final openMins = parseMinutes(openRaw);
    final closeMins = parseMinutes(closeRaw);
    if (openMins != null && cur < openMins) {
      return 'Opens at ${formatMinutes(openMins)}';
    }
    if (closeMins != null && closeMins > (openMins ?? 0) && cur >= closeMins) {
      return 'Hours ended today';
    }
    return 'Clinic closed now';
  }
}
