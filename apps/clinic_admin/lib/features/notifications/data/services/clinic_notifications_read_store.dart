import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists read notification IDs per clinic across memory, SharedPreferences,
/// and Firestore `clinics/{clinicId}.readNotificationIds` so read state
/// survives sign-out, login, and cross-session refreshes.
class ClinicNotificationsReadStore {
  static const String _legacyKey = 'clinic_admin_read_notifications';
  static String _keyFor(String clinicId) =>
      clinicId.isEmpty ? _legacyKey : '${_legacyKey}_$clinicId';

  final FirebaseFirestore? _firestoreOverride;
  final Map<String, Set<String>> _memoryByClinic = {};
  final Set<String> _loadedRemotes = {};
  Future<void>? _pendingWrite;

  ClinicNotificationsReadStore({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  void resetSessionCache() {
    _memoryByClinic.clear();
    _loadedRemotes.clear();
  }

  Future<void> flushPending() async {
    try {
      await _pendingWrite;
    } catch (_) {}
  }

  FirebaseFirestore? get _fs {
    if (_firestoreOverride != null) return _firestoreOverride;
    return Firebase.apps.isEmpty ? null : FirebaseFirestore.instance;
  }

  /// Extracts `readNotificationIds` from a clinic document map.
  static Set<String> extractRemoteIds(Map<String, dynamic>? clinicData) {
    final raw = clinicData?['readNotificationIds'];
    if (raw is! Iterable) return const {};
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toSet();
  }

  void addToMemory(String clinicId, Iterable<String> ids) {
    final clean = ids.map((e) => e.trim()).where((e) => e.isNotEmpty);
    if (clean.isEmpty) return;
    _memoryByClinic.putIfAbsent(clinicId, () => <String>{}).addAll(clean);
  }

  Future<void> cacheRemote(String clinicId, Iterable<String> ids) async {
    final clean = ids.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (clean.isEmpty) return;
    addToMemory(clinicId, clean);
    _loadedRemotes.add(clinicId);
    await _saveLocal(clinicId, clean);
  }

  Future<Set<String>> loadReadIds(
    String clinicId, {
    Map<String, dynamic>? clinicData,
  }) async {
    final merged = <String>{...?_memoryByClinic[clinicId]};
    try {
      final prefs = await SharedPreferences.getInstance();
      merged.addAll(prefs.getStringList(_keyFor(clinicId)) ?? const []);
      merged.addAll(prefs.getStringList(_legacyKey) ?? const []);
    } catch (_) {}

    if (clinicData != null) {
      merged.addAll(extractRemoteIds(clinicData));
      _loadedRemotes.add(clinicId);
    } else if (clinicId.isNotEmpty && !_loadedRemotes.contains(clinicId)) {
      final fs = _fs;
      if (fs != null) {
        try {
          final snap = await fs.collection('clinics').doc(clinicId).get();
          merged.addAll(extractRemoteIds(snap.data()));
          _loadedRemotes.add(clinicId);
        } catch (_) {}
      }
    }

    if (merged.isNotEmpty) {
      addToMemory(clinicId, merged);
      await _saveLocal(clinicId, merged);
    }
    return merged;
  }

  Future<void> markRead(String clinicId, Iterable<String> ids) async {
    final clean = ids.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (clean.isEmpty) return;

    addToMemory(clinicId, clean);
    await _saveLocal(clinicId, clean);

    final fs = _fs;
    if (fs == null || clinicId.isEmpty) return;
    final op = fs.collection('clinics').doc(clinicId).set({
      'readNotificationIds': FieldValue.arrayUnion(clean),
      'notificationsReadAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _pendingWrite = op;
    try {
      await op;
    } catch (_) {
    } finally {
      if (identical(_pendingWrite, op)) _pendingWrite = null;
    }
  }

  Future<void> _saveLocal(String clinicId, Iterable<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyFor(clinicId);
      final updated = (prefs.getStringList(key) ?? const []).toSet()..addAll(ids);
      await prefs.setStringList(key, updated.toList());
    } catch (_) {}
  }
}
