import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/services/notification_navigator.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/services/patient_notifications_service.dart';
import '../../domain/entities/patient_notification_entity.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_filter_bar.dart';
import '../widgets/notification_item_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filterIndex = 0;

  List<PatientNotificationEntity> _applyFilter(
    List<PatientNotificationEntity> list,
  ) {
    if (_filterIndex == 1) {
      return list.where((n) => n.category == PatientNotificationCategory.queue).toList();
    }
    if (_filterIndex == 2) {
      return list.where((n) => n.category == PatientNotificationCategory.booking).toList();
    }
    if (_filterIndex == 3) {
      return list.where((n) => n.category == PatientNotificationCategory.support).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: StreamBuilder<List<PatientNotificationEntity>>(
        stream: PatientNotificationsService.instance.watchNotifications(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? const [];
          final unread = all.where((n) => !n.isRead).length;
          final filtered = _applyFilter(all);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  NotificationFilterBar(
                    selectedIndex: _filterIndex,
                    onFilterChanged: (i) => setState(() => _filterIndex = i),
                  ),
                  const SizedBox(height: 16),
                  if (unread > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => PatientNotificationsService.instance
                            .markAllAsRead(all.map((n) => n.id).toList()),
                        child: Text(
                          'Mark all as read',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  if (filtered.isEmpty)
                    const NotificationEmptyState()
                  else
                    for (final item in filtered)
                      NotificationItemCard(
                        notification: item,
                        onTap: () {
                          PatientNotificationsService.instance.markAsRead(item.id);
                          NotificationNavigator.navigate(
                            NotificationService.navigatorKey,
                            item.route,
                          );
                        },
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
