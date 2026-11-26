import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/patient_notification_entity.dart';

class NotificationItemCard extends StatelessWidget {
  final PatientNotificationEntity notification;
  final VoidCallback onTap;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  (IconData, Color) _meta() => switch (notification.category) {
    PatientNotificationCategory.queue => (Icons.confirmation_number_rounded, const Color(0xFF0EA5E9)),
    PatientNotificationCategory.booking => (Icons.calendar_month_rounded, const Color(0xFF10B981)),
    PatientNotificationCategory.support => (Icons.chat_bubble_rounded, const Color(0xFFF59E0B)),
    PatientNotificationCategory.broadcast => (Icons.campaign_rounded, const Color(0xFF8B5CF6)),
  };

  String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, color) = _meta();
    final isUnread = !notification.isRead;
    final borderColor = notification.isUrgent && isUnread
        ? color.withValues(alpha: 0.45)
        : (isUnread ? colors.primary.withValues(alpha: 0.28) : colors.border.withValues(alpha: 0.5));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isUnread ? colors.surface : colors.surfaceSecondary.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: isUnread ? 1.3 : 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_timeLabel(notification.timestamp), style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle)),
                          ],
                        ],
                      ),
                      if (notification.body.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted, height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (notification.badgeLabel.isNotEmpty) _pill(notification.badgeLabel, color, color),
                          if (notification.clinicName.trim().isNotEmpty)
                            _pill(notification.clinicName.trim(), colors.textMuted, colors.border),
                          if (notification.isPushReceived) _pill('FCM Push', colors.primary, colors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, Color fg, Color border) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: fg.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: border.withValues(alpha: 0.25)),
    ),
    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
  );
}
