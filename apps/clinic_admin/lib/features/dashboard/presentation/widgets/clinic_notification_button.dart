import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/services/clinic_session_manager.dart';
import '../../../notifications/data/services/clinic_notifications_service.dart';
import '../../../notifications/domain/entities/clinic_notification_item.dart';
import '../../../notifications/presentation/widgets/clinic_notification_dialog.dart';

class ClinicNotificationButton extends StatefulWidget {
  final String? clinicId;
  final ValueChanged<String>? onNavigate;

  const ClinicNotificationButton({
    super.key,
    this.clinicId,
    this.onNavigate,
  });

  @override
  State<ClinicNotificationButton> createState() =>
      _ClinicNotificationButtonState();
}

class _ClinicNotificationButtonState extends State<ClinicNotificationButton> {
  String _activeClinicId = '';

  @override
  void initState() {
    super.initState();
    _activeClinicId = widget.clinicId ?? '';
    if (_activeClinicId.isEmpty) {
      ClinicSessionManager.getSavedClinicId().then((id) {
        if (mounted && id != null && id.isNotEmpty) {
          setState(() => _activeClinicId = id);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ClinicNotificationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clinicId != null && widget.clinicId != _activeClinicId) {
      _activeClinicId = widget.clinicId!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_activeClinicId.isEmpty) {
      return IconButton(
        tooltip: 'Notifications',
        icon: Icon(
          Icons.notifications_none_rounded,
          color: colors.textMuted,
          size: 22,
        ),
        onPressed: () {},
      );
    }

    return StreamBuilder<List<ClinicNotificationItem>>(
      stream: ClinicNotificationsService.instance.watchNotifications(
        _activeClinicId,
      ),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Notifications ($unreadCount new)',
              icon: Icon(
                unreadCount > 0
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: unreadCount > 0 ? colors.primary : colors.textMuted,
                size: 22,
              ),
              onPressed: () {
                ClinicNotificationDialog.show(
                  context,
                  notifications: notifications,
                  onNavigate: widget.onNavigate,
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.surface, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
