import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/notifications/data/services/patient_notifications_service.dart';
import '../../features/notifications/domain/entities/patient_notification_entity.dart';
import 'notification_controller.dart';
import 'notification_local_store.dart';

typedef ParsedRemotePush = ({
  String id,
  String title,
  String body,
  String route,
  String categoryKey,
  String clinicName,
  String badgeLabel,
  bool isUrgent,
  NotificationCategory awesomeCategory,
});

/// Parses FCM RemoteMessages and bridges live Firestore transitions into
/// OS status-bar notifications via Awesome Notifications.
class NotificationPayloadHelper {
  const NotificationPayloadHelper._();

  static ParsedRemotePush extract(RemoteMessage message) {
    final data = message.data;
    final n = message.notification;
    final rawType = (data['type'] ?? '').toString().toLowerCase();
    final title = (n?.title ?? data['title'] ?? 'QueueFlow Alert').toString();
    final body = (n?.body ?? data['body'] ?? data['message'] ?? '').toString();
    final route = (data['route'] ?? '/home').toString();
    final id = 'fcm_${message.messageId ?? '${title.hashCode}_${body.hashCode}'}';

    var cat = 'broadcast';
    var awesomeCat = NotificationCategory.Recommendation;
    var badge = 'FCM Push';
    var urgent = false;
    if (rawType.contains('queue') || route.startsWith('/live_queue')) {
      cat = 'queue';
      awesomeCat = NotificationCategory.Reminder;
      badge = 'Queue Alert';
      urgent = true;
    } else if (rawType.contains('support') || route.startsWith('/support_chat')) {
      cat = 'support';
      awesomeCat = NotificationCategory.Message;
      badge = 'Support Reply';
      urgent = true;
    } else if (rawType.contains('appoint') || route.startsWith('/my_bookings')) {
      cat = 'booking';
      awesomeCat = NotificationCategory.Event;
      badge = 'Appointment';
      urgent = true;
    }
    return (
      id: id,
      title: title,
      body: body,
      route: route,
      categoryKey: cat,
      clinicName: (data['clinicName'] ?? '').toString(),
      badgeLabel: badge,
      isUrgent: urgent,
      awesomeCategory: awesomeCat,
    );
  }

  static String alertKeyFor(PatientNotificationEntity item) =>
      '${item.id}|${item.title}|${item.body}';

  static NotificationCategory awesomeCategoryFor(
    PatientNotificationCategory category,
  ) => switch (category) {
    PatientNotificationCategory.support => NotificationCategory.Message,
    PatientNotificationCategory.booking => NotificationCategory.Event,
    PatientNotificationCategory.broadcast => NotificationCategory.Recommendation,
    PatientNotificationCategory.queue => NotificationCategory.Reminder,
  };

  /// Persists an incoming FCM payload and optionally raises a tray notification.
  static Future<void> handleIncomingPush(
    RemoteMessage message, {
    required bool showLocalAlert,
  }) async {
    final p = extract(message);
    await NotificationLocalStore.recordPushEntry(
      id: p.id, title: p.title, body: p.body, route: p.route,
      category: p.categoryKey, clinicName: p.clinicName,
      badgeLabel: p.badgeLabel, isUrgent: p.isUrgent,
    );
    if (showLocalAlert) {
      await NotificationController.showStatusBarNotification(
        id: p.id.hashCode, title: p.title, body: p.body, route: p.route,
        summary: p.clinicName.isNotEmpty ? p.clinicName : 'QueueFlow',
        notifId: p.id, category: p.awesomeCategory, wakeUpScreen: p.isUrgent,
      );
    }
  }

  static Future<void> _dispatchLock = Future.value();

  /// Shows Android/iOS status-bar notifications for newly seen unread updates.
  static Future<void> dispatchUnreadAlerts(
    List<PatientNotificationEntity> items,
  ) {
    final next = _dispatchLock.then((_) => _runDispatch(items)).catchError((_) {});
    _dispatchLock = next;
    return next;
  }

  static Future<void> _runDispatch(List<PatientNotificationEntity> items) async {
    if (items.isEmpty) return;
    if (!await NotificationLocalStore.isSeedInitialized()) {
      final cutoff = DateTime.now().subtract(const Duration(minutes: 2));
      final oldKeys = items
          .where((e) => e.timestamp.isBefore(cutoff))
          .map(alertKeyFor);
      await NotificationLocalStore.seedAlertKeys(oldKeys);
      await NotificationLocalStore.markSeedInitialized();
    }
    for (final item in items) {
      if (item.isRead || item.isPushReceived) continue;
      final key = alertKeyFor(item);
      if (await NotificationLocalStore.claimAlertKey(key)) {
        await NotificationController.showStatusBarNotification(
          id: key.hashCode,
          title: item.title,
          body: item.body,
          route: item.route,
          summary: item.clinicName.isNotEmpty ? item.clinicName : 'QueueFlow',
          notifId: item.id,
          category: awesomeCategoryFor(item.category),
          wakeUpScreen: item.isUrgent,
        );
      }
    }
  }

  static StreamSubscription<List<PatientNotificationEntity>> startBridge() {
    return PatientNotificationsService.instance.watchNotifications().listen(
      (items) async => dispatchUnreadAlerts(items),
      onError: (_) {},
    );
  }
}
