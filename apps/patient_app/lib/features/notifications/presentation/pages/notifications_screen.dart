import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/services/notification_controller.dart';
import '../../../../core/services/notification_navigator.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/services/patient_notifications_service.dart';
import '../../domain/entities/patient_notification_entity.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_filter_bar.dart';
import '../widgets/notification_hero_banner.dart';
import '../widgets/notification_item_card.dart';

class NotificationsScreen extends StatefulWidget {
  final Stream<List<PatientNotificationEntity>>? streamOverride;
  final bool? initialPushEnabled;
  const NotificationsScreen({super.key, this.streamOverride, this.initialPushEnabled});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filterIndex = 0;
  late bool _pushEnabled;

  @override
  void initState() {
    super.initState();
    _pushEnabled = widget.initialPushEnabled ?? true;
    if (widget.initialPushEnabled == null) {
      NotificationService.areAlertsAllowed().then((ok) {
        if (mounted) setState(() => _pushEnabled = ok);
      });
    }
  }

  Future<void> _sendTestAlert() async {
    final ok = await NotificationService.sendTestAlert();
    if (!mounted) return;
    setState(() => _pushEnabled = ok);
    final msg = ok
        ? 'System alert sent! Pull down your notification bar to view it.'
        : 'Enable notifications in Android Settings to view alerts.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List<PatientNotificationEntity> _applyFilter(List<PatientNotificationEntity> list) => switch (_filterIndex) {
    1 => list.where((n) => n.category == PatientNotificationCategory.queue).toList(),
    2 => list.where((n) => n.category == PatientNotificationCategory.booking).toList(),
    3 => list.where((n) => n.category == PatientNotificationCategory.support).toList(),
    4 => list.where((n) => n.category == PatientNotificationCategory.broadcast).toList(),
    _ => list,
  };

  List<int> _countsFor(List<PatientNotificationEntity> all) => [
    all.length,
    all.where((n) => n.category == PatientNotificationCategory.queue).length,
    all.where((n) => n.category == PatientNotificationCategory.booking).length,
    all.where((n) => n.category == PatientNotificationCategory.support).length,
    all.where((n) => n.category == PatientNotificationCategory.broadcast).length,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return StreamBuilder<List<PatientNotificationEntity>>(
      stream: widget.streamOverride ?? PatientNotificationsService.instance.watchNotifications(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const [];
        final unread = all.where((n) => !n.isRead).length;
        final queueAndBooking = all.where((n) =>
            n.category == PatientNotificationCategory.queue ||
            n.category == PatientNotificationCategory.booking).length;
        final filtered = _applyFilter(all);
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.surface, elevation: 0, scrolledUnderElevation: 0, centerTitle: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.textPrimary),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(
              'Notifications',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
            ),
            actions: [
              IconButton(
                tooltip: 'Test System Alert',
                icon: Icon(Icons.notifications_active_outlined, size: 20, color: colors.textPrimary),
                onPressed: _sendTestAlert,
              ),
              if (unread > 0)
                TextButton(
                  onPressed: () {
                    PatientNotificationsService.instance.markAllAsRead(all.map((n) => n.id).toList());
                    NotificationController.dismissAllAlerts();
                  },
                  child: Text('Mark all read', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => PatientNotificationsService.instance.notifyLocalUpdate(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    NotificationHeroBanner(
                      totalCount: all.length,
                      unreadCount: unread,
                      queueAndBookingCount: queueAndBooking,
                      pushEnabled: _pushEnabled,
                      onEnablePushTap: () async {
                        final ok = await NotificationService.requestPermissions();
                        if (mounted) setState(() => _pushEnabled = ok);
                      },
                    ),
                    const SizedBox(height: 14),
                    NotificationFilterBar(
                      selectedIndex: _filterIndex,
                      counts: _countsFor(all),
                      onFilterChanged: (i) => setState(() => _filterIndex = i),
                    ),
                    const SizedBox(height: 14),
                    if (filtered.isEmpty) const NotificationEmptyState(),
                    for (final item in filtered)
                      NotificationItemCard(
                        notification: item,
                        onTap: () {
                          PatientNotificationsService.instance.markAsRead(item.id);
                          NotificationNavigator.navigate(NotificationService.navigatorKey, item.route);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
