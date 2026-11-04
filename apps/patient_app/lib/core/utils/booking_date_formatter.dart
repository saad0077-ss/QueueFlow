class BookingDateFormatter {
  static const List<String> _weekdaysShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _monthsFull = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String weekdayShort(int weekday) {
    if (weekday >= 1 && weekday <= 7) return _weekdaysShort[weekday - 1];
    return 'Mon';
  }

  static String monthShort(int month) {
    if (month >= 1 && month <= 12) return _monthsShort[month - 1];
    return 'Jan';
  }

  static String monthFull(int month) {
    if (month >= 1 && month <= 12) return _monthsFull[month - 1];
    return 'January';
  }

  /// Formats date as: "Tue, 10 Nov"
  static String formatDateShort(DateTime date) {
    final wd = weekdayShort(date.weekday);
    final m = monthShort(date.month);
    return '$wd, ${date.day} $m';
  }

  /// Formats date and time as: "Tue, 10 Nov · 11:00 AM"
  static String formatDateTime(DateTime date, String timeSlot) {
    final short = formatDateShort(date);
    return '$short · $timeSlot';
  }

  /// Formats date as ISO YYYY-MM-DD
  static String formatRawDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Formats month and year header: "November 2026"
  static String formatMonthYear(DateTime date) {
    return '${monthFull(date.month)} ${date.year}';
  }
}
