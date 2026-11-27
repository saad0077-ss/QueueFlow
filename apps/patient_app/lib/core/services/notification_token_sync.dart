import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Persists device FCM push tokens to Firestore for the signed-in patient.
class NotificationTokenSync {
  const NotificationTokenSync._();

  static Future<void> syncToken(FirebaseMessaging fcm) async {
    if (kIsWeb) return;
    try {
      final token = await fcm.getToken();
      if (token != null && token.isNotEmpty) await saveToken(token);
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  static Future<void> saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'platform': Platform.operatingSystem,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving FCM token to Firestore: $e');
    }
  }
}
