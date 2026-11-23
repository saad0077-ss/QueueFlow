import 'package:flutter/material.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';

class PlatformTicketCardStyleHelper {
  static final Map<String, DateTime> _anchorTimes = {};

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
    return sub.contains('app') &&
        (sub.contains('gps') ||
            sub.contains('radar') ||
            sub.contains('tracking') ||
            sub.contains('crash') ||
            sub.contains('bug') ||
            sub.contains('error') ||
            sub.contains('issue') ||
            sub.contains('sync') ||
            sub.contains('not working'));
  }

  static String formatSlaCountdown(PlatformSupportTicketEntity t) {
    if (t.status.toLowerCase() == 'resolved') return 'SLA Met';
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

  static String formatTimeAgo(PlatformSupportTicketEntity t) {
    if (t.createdAtDate != null) {
      final diff = DateTime.now().difference(t.createdAtDate!);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return '${diff.inHours} hrs ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays}d ago';
    }
    return t.createdAt.isNotEmpty ? t.createdAt : 'Just now';
  }

  static Color getAccentColor(PlatformSupportTicketEntity t) {
    final prio = t.priority.toLowerCase();
    final isUrgentOrHigh =
        prio == 'high' || prio == 'urgent' || t.slaMinutes < 15;
    if (t.status.toLowerCase() == 'resolved') return const Color(0xFF10B981);
    if (t.status.toLowerCase() == 'in_progress') return const Color(0xFFF59E0B);
    if (isUrgentOrHigh) return const Color(0xFFEF4444);
    return const Color(0xFF2563EB);
  }
}
