import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists read notification IDs, received FCM push messages, and
/// deduplicated status-bar alert keys across isolates via SharedPreferences.
class NotificationLocalStore {
  const NotificationLocalStore._();

  static const String _readIdsKey = 'patient_read_notification_ids';
  static const String _fcmHistoryKey = 'patient_fcm_history_v1';
  static const String _shownAlertsKey = 'patient_shown_alert_keys_v1';
  static const String _seededFlagKey = 'patient_alerts_seeded_v1';

  static String _readKeyFor(String? uid) =>
      (uid != null && uid.isNotEmpty) ? '${_readIdsKey}_$uid' : _readIdsKey;

  static Future<Set<String>> getReadIds({String? uid}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _readKeyFor(uid);
      final set = (prefs.getStringList(key) ?? const []).toSet();
      if (uid != null && uid.isNotEmpty) {
        final legacy = prefs.getStringList(_readIdsKey);
        if (legacy != null && legacy.isNotEmpty) {
          set.addAll(legacy);
          await prefs.setStringList(key, set.toList());
          await prefs.remove(_readIdsKey);
        }
      }
      return set;
    } catch (_) {
      return {};
    }
  }

  static Future<void> markRead(Iterable<String> ids, {String? uid}) async {
    final list = ids.where((e) => e.trim().isNotEmpty).toList();
    if (list.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _readKeyFor(uid);
      final set = (prefs.getStringList(key) ?? const []).toSet()..addAll(list);
      await prefs.setStringList(key, set.toList());
    } catch (_) {}
  }

  static Future<void> recordPushEntry({
    required String id,
    required String title,
    required String body,
    required String route,
    required String category,
    String clinicName = '',
    String badgeLabel = 'FCM Push',
    bool isUrgent = false,
  }) async {
    if (title.trim().isEmpty && body.trim().isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_fcmHistoryKey) ?? const <String>[];
      final entry = jsonEncode({
        'id': id,
        'title': title.trim().isNotEmpty ? title.trim() : 'QueueFlow Alert',
        'body': body.trim(),
        'route': route.isNotEmpty ? route : '/home',
        'category': category,
        'clinicName': clinicName,
        'badgeLabel': badgeLabel,
        'isUrgent': isUrgent,
        'timestampMs': DateTime.now().millisecondsSinceEpoch,
      });

      final deduped = <String>[entry];
      for (final raw in existing) {
        try {
          final m = jsonDecode(raw) as Map<String, dynamic>;
          if (m['id'] == id) continue;
          deduped.add(raw);
          if (deduped.length >= 40) break;
        } catch (_) {}
      }
      await prefs.setStringList(_fcmHistoryKey, deduped);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> loadPushEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_fcmHistoryKey) ?? const <String>[];
      return [
        for (final item in raw)
          if (item.isNotEmpty) Map<String, dynamic>.from(jsonDecode(item) as Map),
      ];
    } catch (_) {
      return const [];
    }
  }

  static Future<bool> isSeedInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_seededFlagKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> markSeedInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seededFlagKey, true);
    } catch (_) {}
  }

  static Future<bool> claimAlertKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = (prefs.getStringList(_shownAlertsKey) ?? const <String>[]).toList();
      if (list.contains(key)) return false;
      list.add(key);
      if (list.length > 400) list.removeRange(0, list.length - 400);
      await prefs.setStringList(_shownAlertsKey, list);
      return true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> seedAlertKeys(Iterable<String> keys) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = (prefs.getStringList(_shownAlertsKey) ?? const <String>[]).toSet()
        ..addAll(keys);
      final trimmed = existing.length > 400
          ? existing.skip(existing.length - 400).toList()
          : existing.toList();
      await prefs.setStringList(_shownAlertsKey, trimmed);
    } catch (_) {}
  }
}
