import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_notification_item.dart';

class ClinicNotificationTile extends StatelessWidget {
  final ClinicNotificationItem item;
  final VoidCallback onTap;

  const ClinicNotificationTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  (IconData, Color) _typeMeta(AppColorsExtension colors) {
    return switch (item.type) {
      ClinicNotificationType.appointment => (
        Icons.calendar_today_rounded,
        const Color(0xFF10B981),
      ),
      ClinicNotificationType.queue => (
        Icons.confirmation_number_outlined,
        colors.primary,
      ),
      ClinicNotificationType.support => (
        Icons.headset_mic_outlined,
        const Color(0xFFF59E0B),
      ),
      ClinicNotificationType.system => (
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
    final (icon, color) = _typeMeta(colors);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: item.isRead
              ? colors.surfaceSecondary.withValues(alpha: 0.5)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead
                ? colors.border.withValues(alpha: 0.5)
                : colors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timeAgo(item.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: colors.textMuted,
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
