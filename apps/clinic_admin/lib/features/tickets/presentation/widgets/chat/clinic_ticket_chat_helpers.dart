import '../../../domain/entities/clinic_support_ticket_entity.dart';

class ClinicTicketChatHelpers {
  static final Map<String, DateTime> _anchorTimes = {};

  static String getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'billing':
        return '💳';
      case 'queue':
        return '⏱️';
      case 'appointment':
        return '📅';
      case 'doctor':
        return '🩺';
      case 'tech':
      case 'technical':
        return '💻';
      case 'app':
      case 'mobile_app':
      case 'platform':
        return '📱';
      default:
        return '🏷️';
    }
  }

  static bool isTicketAppRelated(ClinicSupportTicketEntity ticket) {
    final cat = ticket.category.toLowerCase();
    final subj = ticket.subject.toLowerCase();
    final firstMsg = ticket.messages.isNotEmpty
        ? ticket.messages.first.text.toLowerCase()
        : '';
    return cat == 'app' ||
        cat == 'tech' ||
        cat == 'technical' ||
        cat == 'platform' ||
        subj.contains('crash') ||
        subj.contains('bug') ||
        subj.contains('login') ||
        subj.contains('otp') ||
        subj.contains('update') ||
        subj.contains('app') ||
        firstMsg.contains('crash') ||
        firstMsg.contains('error');
  }

  static String formatSlaCountdown(ClinicSupportTicketEntity t) {
    if (t.status.toLowerCase() == 'resolved') {
      return 'SLA Met';
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
}
