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

  (IconData, Color) _meta(AppColorsExtension colors) {
    return switch (notification.category) {
      PatientNotificationCategory.queue => (
        Icons.confirmation_number_outlined,
        const Color(0xFF38BDF8),
      ),
      PatientNotificationCategory.booking => (
        Icons.calendar_month_rounded,
        const Color(0xFF10B981),
      ),
      PatientNotificationCategory.support => (
        Icons.chat_bubble_outline_rounded,
        const Color(0xFFF59E0B),
      ),
      PatientNotificationCategory.broadcast => (
        Icons.campaign_outlined,
        const Color(0xFF8B5CF6),
      ),
    };
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, color) = _meta(colors);
    final isUnread = !notification.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isUnread ? colors.surface : colors.surfaceSecondary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnread
                    ? colors.primary.withValues(alpha: 0.25)
                    : colors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(notification.timestamp),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: colors.textMuted,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colors.textMuted,
                          height: 1.4,
                        ),
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
}
