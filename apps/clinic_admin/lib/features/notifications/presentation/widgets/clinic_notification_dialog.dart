import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../data/services/clinic_notifications_service.dart';
import '../../domain/entities/clinic_notification_item.dart';
import 'clinic_notification_header.dart';
import 'clinic_notification_tile.dart';

class ClinicNotificationDialog extends StatefulWidget {
  final List<ClinicNotificationItem> notifications;
  final String? clinicId;
  final ValueChanged<String>? onNavigate;

  const ClinicNotificationDialog({
    super.key,
    required this.notifications,
    this.clinicId,
    this.onNavigate,
  });

  static Future<void> show(
    BuildContext context, {
    required List<ClinicNotificationItem> notifications,
    String? clinicId,
    ValueChanged<String>? onNavigate,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ClinicNotificationDialog(
        notifications: notifications,
        clinicId: clinicId,
        onNavigate: onNavigate,
      ),
    );
  }

  @override
  State<ClinicNotificationDialog> createState() =>
      _ClinicNotificationDialogState();
}

class _ClinicNotificationDialogState extends State<ClinicNotificationDialog> {
  int _filter = 0;

  List<ClinicNotificationItem> get _filtered => widget.notifications.where((n) {
    if (_filter == 1) return n.type == ClinicNotificationType.queue;
    if (_filter == 2) return n.type == ClinicNotificationType.appointment;
    if (_filter == 3) return n.type == ClinicNotificationType.support;
    return true;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unread = widget.notifications.where((n) => !n.isRead).length;

    return Dialog(
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClinicNotificationHeader(
                unread: unread,
                selectedFilter: _filter,
                onFilterChanged: (i) => setState(() => _filter = i),
                onMarkAllRead: () {
                  ClinicNotificationsService.instance.markAllAsRead(
                    widget.notifications.map((n) => n.id).toList(),
                    clinicId: widget.clinicId,
                  );
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 8),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications in this category',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: colors.textMuted,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) {
                          final item = _filtered[i];
                          return ClinicNotificationTile(
                            item: item,
                            onTap: () {
                              ClinicNotificationsService.instance.markAsRead(
                                item.id,
                                clinicId: widget.clinicId,
                              );
                              Navigator.of(context).pop();
                              widget.onNavigate?.call(item.routeNav);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
