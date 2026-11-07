const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "7 Nov 2026"
String formatBillingDate(DateTime d) {
  final l = d.toLocal();
  return '${l.day} ${_months[l.month - 1]} ${l.year}';
}

/// "7 Nov 2026, 02:35 PM"
String formatBillingDateTime(DateTime d) {
  final l = d.toLocal();
  final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final m = l.minute.toString().padLeft(2, '0');
  return '${formatBillingDate(l)}, ${h.toString().padLeft(2, '0')}:$m ${l.hour >= 12 ? 'PM' : 'AM'}';
}

/// "12 days left", "5 hours left", "Expired"
String formatRemaining(DateTime end) {
  final diff = end.difference(DateTime.now());
  if (diff.isNegative) return 'Expired';
  if (diff.inDays >= 1) return '${diff.inDays + (diff.inHours % 24 > 0 ? 1 : 0)} days left';
  if (diff.inHours >= 1) return '${diff.inHours} hours left';
  return '${diff.inMinutes.clamp(1, 59)} minutes left';
}
