/// Currency formatting helpers for clinic revenue amounts (INR).
class ClinicRevenueFormatter {
  ClinicRevenueFormatter._();

  /// Formats [amount] using Indian comma grouping, e.g. `₹1,24,500`.
  static String formatInr(double amount) {
    final rounded = amount.round();
    final negative = rounded < 0;
    final s = rounded.abs().toString();
    if (s.length <= 3) return '${negative ? '-' : ''}₹$s';

    final lastThree = s.substring(s.length - 3);
    final remaining = s.substring(0, s.length - 3);
    final grouped = remaining.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+$)'),
      (m) => '${m[1]},',
    );
    return '${negative ? '-' : ''}₹$grouped,$lastThree';
  }

  /// Formats large revenue figures compactly (`₹1.25Cr`, `₹2.40L`) for dense charts.
  static String formatCompactInr(double amount) {
    final abs = amount.abs();
    if (abs >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
    }
    if (abs >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    }
    if (abs >= 1000 && abs % 1000 == 0) {
      return '₹${(amount / 1000).toStringAsFixed(0)}k';
    }
    return formatInr(amount);
  }
}
