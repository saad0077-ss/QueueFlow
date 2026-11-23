import '../../../domain/entities/platform_support_ticket_entity.dart';

class PlatformTicketChatHelpers {
  static final Map<String, DateTime> _anchorTimes = {};

  static String formatSlaCountdown(PlatformSupportTicketEntity t) {
    if (t.status.toLowerCase() == 'resolved') {
      return '00:00';
    }
    final slaMins = t.slaMinutes > 0 ? t.slaMinutes : 25;
    final created =
        t.createdAtDate ?? _anchorTimes.putIfAbsent(t.id, () => DateTime.now());
    final deadline = created.add(Duration(minutes: slaMins));
    final diff = deadline.difference(DateTime.now());

    if (diff.isNegative) {
      final past = diff.abs();
      final mins = past.inMinutes;
      final secs = past.inSeconds.remainder(60);
      return '-${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} Overdue';
    }

    final hours = diff.inHours;
    final mins = diff.inMinutes.remainder(60);
    final secs = diff.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} Left';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} Left';
  }

  static String formatMessageTime(DateTime? createdAt, String fallbackTime) {
    if (createdAt != null) {
      final diff = DateTime.now().difference(createdAt);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    }
    return fallbackTime;
  }

  static bool isTicketAppRelated(PlatformSupportTicketEntity t) {
    final cat = t.category.toLowerCase();
    final sub = t.subject.toLowerCase();
    final clinicId = t.clinicId.toLowerCase();
    if (!t.isClinicRelated) return true;
    if (clinicId == 'platform') return true;
    if (cat.contains('tech') ||
        cat.contains('app') ||
        cat.contains('bug') ||
        cat.contains('software')) {
      return true;
    }
    if (sub.contains('app') &&
        (sub.contains('gps') ||
            sub.contains('radar') ||
            sub.contains('tracking') ||
            sub.contains('crash') ||
            sub.contains('bug') ||
            sub.contains('error') ||
            sub.contains('issue') ||
            sub.contains('sync') ||
            sub.contains('not working'))) {
      return true;
    }
    return false;
  }

  static String getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('bill') || cat.contains('pay')) return '💳';
    if (cat.contains('queue') ||
        cat.contains('delay') ||
        cat.contains('token')) {
      return '⏱';
    }
    if (cat.contains('doc') || cat.contains('care') || cat.contains('medic')) {
      return '🩺';
    }
    if (cat.contains('app') || cat.contains('tech') || cat.contains('bug')) {
      return '📱';
    }
    return '💬';
  }
}
