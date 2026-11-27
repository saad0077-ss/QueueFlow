import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/notifications/data/services/patient_notifications_service.dart';
import '../../features/notifications/domain/entities/patient_notification_entity.dart';
import '../../firebase_options.dart';
import 'notification_background_worker.dart';
import 'notification_controller.dart';
import 'notification_navigator.dart';
import 'notification_payload_helper.dart';
import 'notification_token_sync.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (_) {}
  if (message.notification == null && !kIsWeb) {
    await NotificationController.ensureInitialized();
  }
  await NotificationPayloadHelper.handleIncomingPush(
    message,
    showLocalAlert: message.notification == null && !kIsWeb,
  );
}

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static StreamSubscription<List<PatientNotificationEntity>>? _liveSub;

  static Future<void> initialize() async {
    try {
      await NotificationController.ensureInitialized();
      await NotificationController.registerListeners();
      final initAction = !kIsWeb
          ? await AwesomeNotifications().getInitialNotificationAction(removeFromActionEvents: false)
          : null;
      if (initAction != null) NotificationNavigator.setPendingRoute(initAction.payload?['route']);
      await requestPermissions();
      await NotificationBackgroundWorker.register();
      FirebaseAuth.instance.authStateChanges().listen((u) {
        if (u == null) {
          _liveSub?.cancel();
          return;
        }
        NotificationTokenSync.syncToken(_fcm);
        _restartBridge();
      });
      if (FirebaseAuth.instance.currentUser != null) _restartBridge();
      await _initFcm();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  static Future<void> _initFcm() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      final s = await _fcm.requestPermission(alert: true, badge: true, sound: true);
      final ok = s.authorizationStatus == AuthorizationStatus.authorized ||
          s.authorizationStatus == AuthorizationStatus.provisional;
      if (!ok) return;
      _setupMessageListeners();
      await NotificationTokenSync.syncToken(_fcm);
      _fcm.onTokenRefresh.listen(NotificationTokenSync.saveToken);
      if (!kIsWeb) await _fcm.subscribeToTopic('broadcast_announcements').catchError((_) {});
    } catch (e) {
      debugPrint('FCM setup skipped: $e');
    }
  }

  static void _restartBridge() {
    if (kIsWeb) return;
    _liveSub?.cancel();
    _liveSub = NotificationPayloadHelper.startBridge();
  }

  static Future<bool> areAlertsAllowed() async {
    if (kIsWeb) return true;
    try {
      return await AwesomeNotifications().isNotificationAllowed();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    var allowed = false;
    try {
      final ok = await AwesomeNotifications().isNotificationAllowed();
      allowed = ok ? true : await AwesomeNotifications().requestPermissionToSendNotifications();
    } catch (_) {}
    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
    } catch (_) {}
    return allowed;
  }

  static Future<bool> sendTestAlert() async {
    final allowed = await requestPermissions();
    await NotificationController.showStatusBarNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '🔔 Your Turn Soon • Token QF-GC-001',
      body: 'Sunrise Family Care Center is ready for your consultation. Please proceed to reception.',
      route: '/live_queue',
      summary: 'Live Queue Alert',
      category: NotificationCategory.Reminder,
      wakeUpScreen: true,
    );
    return allowed;
  }

  static void _setupMessageListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await NotificationPayloadHelper.handleIncomingPush(
        message,
        showLocalAlert: !kIsWeb,
      );
      PatientNotificationsService.instance.notifyLocalUpdate();
    });
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      NotificationNavigator.navigate(navigatorKey, m.data['route']?.toString());
    });
    _fcm.getInitialMessage().then((m) {
      if (m != null) NotificationNavigator.setPendingRoute(m.data['route']?.toString());
    });
  }

}
