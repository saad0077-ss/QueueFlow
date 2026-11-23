import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_card_style_helper.dart';

class PlatformTicketCardBadgeHelper {
  static (Color bg, Color text, String label) getStatusStyle(
    BuildContext context,
    PlatformSupportTicketEntity t,
  ) {
    final isDark = context.colors.isDark;
    final prio = t.priority.toLowerCase();
    final isUrgentOrHigh =
        prio == 'high' || prio == 'urgent' || t.slaMinutes < 15;

    if (t.status.toLowerCase() == 'resolved') {
      return (
        isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.35)
            : const Color(0xFFD1FAE5),
        isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
        'RESOLVED',
      );
    }
    if (t.status.toLowerCase() == 'in_progress') {
      return (
        isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.35)
            : const Color(0xFFFEF3C7),
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
        'IN PROGRESS',
      );
    }
    if (isUrgentOrHigh) {
      return (
        isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.45)
            : const Color(0xFFFEE2E2),
        isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
        'OPEN',
      );
    }
    return (
      isDark
          ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
          : const Color(0xFFFEE2E2),
      isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
      'OPEN',
    );
  }

  static (Color bg, Color text) getCategoryStyle(
    BuildContext context,
    PlatformSupportTicketEntity t,
  ) {
    final isDark = context.colors.isDark;
    final cat = t.category.toLowerCase();
    final isAppRelated = PlatformTicketCardStyleHelper.isTicketAppRelated(t);

    if (cat.contains('queue')) {
      return (
        isDark
            ? const Color(0xFF134E4A).withValues(alpha: 0.4)
            : const Color(0xFFCCFBF1),
        isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
      );
    }
    if (cat.contains('book') || cat.contains('appoint')) {
      return (
        isDark
            ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
            : const Color(0xFFDBEAFE),
        isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
      );
    }
    if (cat.contains('bill')) {
      return (
        isDark
            ? const Color(0xFF312E81).withValues(alpha: 0.4)
            : const Color(0xFFE0E7FF),
        isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
      );
    }
    if (cat.contains('tech') || cat.contains('app') || isAppRelated) {
      return (
        isDark
            ? const Color(0xFF0C4A6E).withValues(alpha: 0.4)
            : const Color(0xFFE0F2FE),
        isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
      );
    }
    return (
      isDark
          ? const Color(0xFF064E3B).withValues(alpha: 0.35)
          : const Color(0xFFD1FAE5),
      isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
    );
  }

  static (String icon, String text, Color bg, Color border, Color textColor)
  getSourceBadgeStyle(BuildContext context, PlatformSupportTicketEntity t) {
    final isDark = context.colors.isDark;
    final isAppRelated = PlatformTicketCardStyleHelper.isTicketAppRelated(t);
    final badgeIcon = isAppRelated ? '📱' : '🏥';
    final badgeText = isAppRelated
        ? 'QueueFlow App'
        : (t.clinicName.isNotEmpty ? t.clinicName : 'Platform Operations');
    final badgeBg = isAppRelated
        ? (isDark
              ? const Color(0xFF0C4A6E).withValues(alpha: 0.55)
              : const Color(0xFFE0F2FE))
        : (isDark
              ? const Color(0xFF1E1B4B).withValues(alpha: 0.6)
              : const Color(0xFFEEF2FF));
    final badgeBorder = isAppRelated
        ? (isDark
              ? const Color(0xFF0284C7).withValues(alpha: 0.45)
              : const Color(0xFFBAE6FD))
        : (isDark
              ? const Color(0xFF4338CA).withValues(alpha: 0.4)
              : const Color(0xFFC7D2FE));
    final badgeTextColor = isAppRelated
        ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
        : (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA));
    return (badgeIcon, badgeText, badgeBg, badgeBorder, badgeTextColor);
  }
}
