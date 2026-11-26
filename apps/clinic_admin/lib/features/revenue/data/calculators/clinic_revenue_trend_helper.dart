import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../../domain/entities/clinic_revenue_summary.dart';

/// Unified dated revenue point passed into trend bucketing.
class TrendRevenueItem {
  final DateTime date;
  final int hour;
  final double netAmount;

  const TrendRevenueItem({
    required this.date,
    required this.hour,
    required this.netAmount,
  });
}

/// Builds date filters and trend buckets for clinic revenue analytics.
class ClinicRevenueTrendHelper {
  ClinicRevenueTrendHelper._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static DateTime resolveDate(ClinicAppointmentEntity appt, {DateTime? fallback}) {
    final parsedRaw = DateTime.tryParse(appt.dateRaw.trim());
    if (parsedRaw != null) return parsedRaw;
    final m = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(appt.dateTime);
    final parsedInline = m != null ? DateTime.tryParse(m.group(0)!) : null;
    return parsedInline ?? fallback ?? DateTime.now();
  }

  static int resolveHour(String timeRaw, {int fallbackHour = 10}) {
    final m = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(AM|PM)?', caseSensitive: false)
        .firstMatch(timeRaw);
    if (m == null) return fallbackHour;
    var h = int.tryParse(m.group(1) ?? '') ?? fallbackHour;
    final mer = (m.group(3) ?? '').toUpperCase();
    if (mer == 'PM' && h < 12) h += 12;
    if (mer == 'AM' && h == 12) h = 0;
    return h;
  }

  static bool isDateInPeriod(
    DateTime date,
    ClinicRevenuePeriod period, {
    DateTime? anchor,
  }) {
    if (period == ClinicRevenuePeriod.all) return true;
    final now = anchor ?? DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final daysBack = switch (period) {
      ClinicRevenuePeriod.today => 0,
      ClinicRevenuePeriod.week => 6,
      ClinicRevenuePeriod.month => 29,
      ClinicRevenuePeriod.quarter => 89,
      ClinicRevenuePeriod.all => 0,
    };
    final start = todayStart.subtract(Duration(days: daysBack));
    return !date.isBefore(start) && !date.isAfter(todayEnd);
  }

  static List<DailyRevenuePoint> buildTrend({
    required List<TrendRevenueItem> items,
    required ClinicRevenuePeriod period,
    DateTime? anchor,
  }) {
    final now = anchor ?? DateTime.now();
    if (period == ClinicRevenuePeriod.today) return _buildIntraday(items);
    if (period == ClinicRevenuePeriod.all) return _buildMonthly(items, now);

    final totalDays = period == ClinicRevenuePeriod.week
        ? 7
        : (period == ClinicRevenuePeriod.month ? 30 : 90);
    final bucketDays = period == ClinicRevenuePeriod.week
        ? 1
        : (period == ClinicRevenuePeriod.month ? 5 : 15);
    final bucketCount = (totalDays / bucketDays).ceil();
    final rangeStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: totalDays - 1));
    final sums = List<double>.filled(bucketCount, 0);
    final counts = List<int>.filled(bucketCount, 0);

    for (final item in items) {
      if (item.netAmount <= 0) continue;
      final diff = DateTime(item.date.year, item.date.month, item.date.day)
          .difference(rangeStart)
          .inDays;
      if (diff < 0 || diff >= totalDays) continue;
      final idx = (diff ~/ bucketDays).clamp(0, bucketCount - 1);
      sums[idx] += item.netAmount;
      counts[idx]++;
    }
    return List.generate(bucketCount, (i) {
      final bs = rangeStart.add(Duration(days: i * bucketDays));
      return DailyRevenuePoint(
        label: '${bs.day} ${_months[bs.month - 1]}',
        amount: sums[i],
        count: counts[i],
      );
    });
  }

  static List<DailyRevenuePoint> _buildIntraday(List<TrendRevenueItem> items) {
    const labels = ['Morning', 'Midday', 'Afternoon', 'Evening'];
    final sums = List<double>.filled(4, 0);
    final counts = List<int>.filled(4, 0);
    for (final item in items) {
      if (item.netAmount <= 0) continue;
      final idx = item.hour < 12 ? 0 : (item.hour < 15 ? 1 : (item.hour < 18 ? 2 : 3));
      sums[idx] += item.netAmount;
      counts[idx]++;
    }
    return List.generate(
      4,
      (i) => DailyRevenuePoint(label: labels[i], amount: sums[i], count: counts[i]),
    );
  }

  static List<DailyRevenuePoint> _buildMonthly(List<TrendRevenueItem> items, DateTime now) {
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    final sums = List<double>.filled(6, 0);
    final counts = List<int>.filled(6, 0);
    for (final item in items) {
      if (item.netAmount <= 0) continue;
      final idx = months.indexWhere((m) => m.year == item.date.year && m.month == item.date.month);
      if (idx != -1) {
        sums[idx] += item.netAmount;
        counts[idx]++;
      }
    }
    return List.generate(
      6,
      (i) => DailyRevenuePoint(
        label: _months[months[i].month - 1],
        amount: sums[i],
        count: counts[i],
      ),
    );
  }
}
