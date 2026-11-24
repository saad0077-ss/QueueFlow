import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_navigator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'queueflow_high_importance_channel',
    'QueueFlow Queue & Appointment Alerts',
    description:
        'High-priority notifications for live queue status and doctor consultations.',
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> initialize() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _setupLocalNotifications();
        _setupMessageListeners();
        await syncTokenToFirestore();

        _fcm.onTokenRefresh.listen(_saveToken);
        FirebaseAuth.instance.authStateChanges().listen((u) {
          if (u != null) syncTokenToFirestore();
        });

        if (!kIsWeb) {
          try {
            await _fcm.subscribeToTopic('broadcast_announcements');
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  static Future<void> _setupLocalNotifications() async {
    if (kIsWeb) return;

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (res) {
        NotificationNavigator.navigate(navigatorKey, res.payload);
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static void _setupMessageListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final n = message.notification;
      if (n != null && !kIsWeb) {
        _localNotifications.show(
          id: n.hashCode,
          title: n.title,
          body: n.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: message.notification?.android?.smallIcon ??
                  '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['route']?.toString(),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      NotificationNavigator.navigate(navigatorKey, msg.data['route']?.toString());
    });

    _fcm.getInitialMessage().then((msg) {
      if (msg != null) {
        NotificationNavigator.navigate(navigatorKey, msg.data['route']?.toString());
      }
    });
  }

  static Future<void> syncTokenToFirestore() async {
    try {
      if (kIsWeb) return;
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) await _saveToken(token);
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  static Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final platform = kIsWeb ? 'web' : Platform.operatingSystem;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'platform': platform,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving FCM token to Firestore: $e');
    }
  }
}
