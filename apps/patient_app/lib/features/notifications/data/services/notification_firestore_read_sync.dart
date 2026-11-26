import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/services/notification_local_store.dart';

/// Persists patient read notification IDs across memory, per-user SharedPreferences,
/// and Firestore `users/{uid}.readNotificationIds` (+ personal `/notifications`
/// `unread: false`) so read state survives sign-out, login, and reinstalls.
class NotificationFirestoreReadSync {
  final FirebaseFirestore? _firestoreOverride;
  final Map<String, Set<String>> _memoryByUid = {};
  final Set<String> _loadedRemotes = {};
  Future<void>? _pendingWrite;

  NotificationFirestoreReadSync({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  FirebaseFirestore? get _fs {
    if (_firestoreOverride != null) return _firestoreOverride;
    return Firebase.apps.isEmpty ? null : FirebaseFirestore.instance;
  }

  static Set<String> extractRemoteIds(Map<String, dynamic>? userData) {
    final raw = userData?['readNotificationIds'];
    if (raw is! Iterable) return const {};
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toSet();
  }

  void addToMemory(String uid, Iterable<String> ids) {
    if (uid.isEmpty) return;
    final clean = ids.map((e) => e.trim()).where((e) => e.isNotEmpty);
    if (clean.isEmpty) return;
    _memoryByUid.putIfAbsent(uid, () => <String>{}).addAll(clean);
  }

  void resetSessionCache() {
    _memoryByUid.clear();
    _loadedRemotes.clear();
  }

  Future<void> flushPending() async {
    try {
      await _pendingWrite;
    } catch (_) {}
  }

  Future<void> cacheRemote(String uid, Iterable<String> ids) async {
    if (uid.isEmpty) return;
    final clean = ids.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (clean.isEmpty) return;
    addToMemory(uid, clean);
    _loadedRemotes.add(uid);
    await NotificationLocalStore.markRead(clean, uid: uid);
  }

  Future<Set<String>> loadMergedReadIds(
    String uid, {
    Map<String, dynamic>? userData,
  }) async {
    final merged = <String>{
      ...?_memoryByUid[uid],
      ...await NotificationLocalStore.getReadIds(uid: uid),
    };
    if (userData != null) {
      merged.addAll(extractRemoteIds(userData));
      _loadedRemotes.add(uid);
    } else if (uid.isNotEmpty && !_loadedRemotes.contains(uid)) {
      final fs = _fs;
      if (fs != null) {
        try {
          final snap = await fs.collection('users').doc(uid).get();
          merged.addAll(extractRemoteIds(snap.data()));
          _loadedRemotes.add(uid);
        } catch (_) {}
      }
    }
    if (merged.isNotEmpty && uid.isNotEmpty) {
      addToMemory(uid, merged);
      await NotificationLocalStore.markRead(merged, uid: uid);
    }
    return merged;
  }

  Future<void> markRead(
    String uid,
    Iterable<String> ids, {
    Set<String> personalDocIds = const {},
  }) async {
    final clean = ids.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (clean.isEmpty) return;

    addToMemory(uid, clean);
    await NotificationLocalStore.markRead(clean, uid: uid);

    final fs = _fs;
    if (fs == null || uid.isEmpty) return;
    final op = _writeToFirestore(fs, uid, clean, personalDocIds);
    _pendingWrite = op;
    try {
      await op;
    } catch (_) {
    } finally {
      if (identical(_pendingWrite, op)) _pendingWrite = null;
    }
  }

  Future<void> _writeToFirestore(
    FirebaseFirestore fs,
    String uid,
    List<String> cleanIds,
    Set<String> personalDocIds,
  ) async {
    await fs.collection('users').doc(uid).set({
      'readNotificationIds': FieldValue.arrayUnion(cleanIds),
      'readNotificationsUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final toUpdate = cleanIds
        .where((id) => id.startsWith('broad_'))
        .map((id) => id.substring('broad_'.length))
        .where(personalDocIds.contains)
        .toList();
    if (toUpdate.isEmpty) return;
    final batch = fs.batch();
    for (final docId in toUpdate) {
      batch.set(
        fs.collection('notifications').doc(docId),
        {'unread': false},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
