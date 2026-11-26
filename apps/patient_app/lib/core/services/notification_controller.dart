import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/notifications/data/services/patient_notifications_service.dart';
import '../../firebase_options.dart';
import 'notification_navigator.dart';
import 'notification_service.dart';

/// Configures Awesome Notifications channels, status-bar alerts, and tap/action listeners.
class NotificationController {
  const NotificationController._();

  static const String channelKey = 'queueflow_high_importance_channel';
  static const String channelGroupKey = 'queueflow_alerts_group';
  static const String _smallIcon = 'resource://drawable/ic_launcher_monochrome';
  static const String _largeIcon = 'asset://assets/images/queueflow_icon.png';
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized || kIsWeb) return;
    try {
      await AwesomeNotifications().initialize(
        _smallIcon,
        [
          NotificationChannel(
            channelGroupKey: channelGroupKey,
            channelKey: channelKey,
            channelName: 'QueueFlow Queue & Appointment Alerts',
            channelDescription: 'Status-bar alerts for queue calls, bookings, and support.',
            defaultColor: const Color(0xFF2563EB),
            ledColor: const Color(0xFF38BDF8),
            importance: NotificationImportance.Max,
            playSound: true, enableVibration: true, enableLights: true,
            channelShowBadge: true, criticalAlerts: true,
          ),
        ],
        channelGroups: [
          NotificationChannelGroup(channelGroupKey: channelGroupKey, channelGroupName: 'QueueFlow Alerts'),
        ],
        debug: kDebugMode,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('AwesomeNotifications init skipped: $e');
    }
  }

  static Future<void> registerListeners() async {
    if (kIsWeb) return;
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> dismissAllAlerts() async {
    if (kIsWeb) return;
    try {
      await AwesomeNotifications().cancelAll();
    } catch (_) {}
  }

  static String _openLabelForRoute(String route) {
    if (route.startsWith('/live_queue')) return 'Track Live Queue';
    if (route.startsWith('/my_bookings')) return 'View Booking';
    if (route.startsWith('/support_chat')) return 'Reply in Chat';
    return 'Open QueueFlow';
  }

  static Future<void> showStatusBarNotification({
    required int id, required String title, required String body,
    String route = '/home', String summary = 'QueueFlow', String? notifId,
    NotificationCategory category = NotificationCategory.Status, bool wakeUpScreen = true,
  }) async {
    if (kIsWeb) return;
    await ensureInitialized();
    try {
      final uid = Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser?.uid;
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id.abs() % 2147483000, channelKey: channelKey,
          title: title, body: body, summary: summary,
          icon: _smallIcon, largeIcon: _largeIcon, roundedLargeIcon: true,
          notificationLayout: NotificationLayout.BigText, category: category,
          wakeUpScreen: wakeUpScreen, displayOnForeground: true, displayOnBackground: true,
          color: const Color(0xFF2563EB),
          payload: {
            'route': route,
            if (notifId != null && notifId.isNotEmpty) 'notifId': notifId,
            if (uid != null && uid.isNotEmpty) 'uid': uid,
          },
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'OPEN_ROUTE', label: _openLabelForRoute(route),
            color: const Color(0xFF2563EB), actionType: ActionType.Default,
          ),
          NotificationActionButton(
            key: 'MARK_READ', label: 'Mark Read',
            actionType: ActionType.SilentBackgroundAction,
          ),
        ],
      );
    } catch (e) {
      debugPrint('showStatusBarNotification failed: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(ReceivedNotification n) async {}
  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification n) async {}
  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(ReceivedAction a) async {}

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction a) async {
    if (a.id != null) {
      try { await AwesomeNotifications().dismiss(a.id!); } catch (_) {}
    }
    if (Firebase.apps.isEmpty) {
      try { await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); } catch (_) {}
    }
    final payload = a.payload ?? const {};
    final notifId = payload['notifId'];
    if (notifId != null && notifId.isNotEmpty) {
      await PatientNotificationsService.instance.markAsRead(notifId, uidOverride: payload['uid']);
    }
    if (a.buttonKeyPressed == 'MARK_READ') return;
    NotificationNavigator.navigate(NotificationService.navigatorKey, payload['route']);
  }
}
