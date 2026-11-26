import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/services/notification_local_store.dart';
import '../../../profile/data/repositories/profile_firestore_queries.dart';
import '../../domain/entities/patient_notification_entity.dart';
import 'notification_firestore_read_sync.dart';
import 'patient_notification_broadcast_mapper.dart';
import 'patient_notification_mapper.dart';

typedef _Doc = DocumentSnapshot<Map<String, dynamic>>;

class PatientNotificationsService {
  static final PatientNotificationsService instance = PatientNotificationsService._();

  PatientNotificationsService._({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _fsOverride = firestore,
      _authOverride = auth,
      _readSync = NotificationFirestoreReadSync(firestore: firestore);

  final FirebaseFirestore? _fsOverride;
  final FirebaseAuth? _authOverride;
  final NotificationFirestoreReadSync _readSync;
  final StreamController<void> _localRefresh = StreamController<void>.broadcast();
  final Set<String> _personalNotifDocIds = {};

  FirebaseFirestore? get _fs =>
      _fsOverride ?? (Firebase.apps.isEmpty ? null : FirebaseFirestore.instance);
  FirebaseAuth? get _auth =>
      _authOverride ?? (Firebase.apps.isEmpty ? null : FirebaseAuth.instance);

  void notifyLocalUpdate() {
    if (!_localRefresh.isClosed) _localRefresh.add(null);
  }

  Future<void> flushPendingSync() => _readSync.flushPending();

  void resetSessionCache() {
    _readSync.resetSessionCache();
    _personalNotifDocIds.clear();
  }

  Future<void> markAsRead(String id, {String? uidOverride}) =>
      markAllAsRead([id], uidOverride: uidOverride);

  Future<void> markAllAsRead(List<String> ids, {String? uidOverride}) async {
    final uid = (uidOverride != null && uidOverride.isNotEmpty)
        ? uidOverride
        : (_auth?.currentUser?.uid ?? '');
    _readSync.addToMemory(uid, ids);
    notifyLocalUpdate();
    await _readSync.markRead(uid, ids, personalDocIds: Set.from(_personalNotifDocIds));
    notifyLocalUpdate();
  }

  Stream<int> watchUnreadCount() =>
      watchNotifications().map((list) => list.where((n) => !n.isRead).length);

  Future<List<PatientNotificationEntity>> fetchAllOnce() async {
    final fs = _fs;
    final user = _auth?.currentUser;
    if (fs == null || user == null) return const [];
    Future<List<_Doc>> qCol(String col) async {
      final q = ProfileFirestoreQueries.forUser(fs, col, uid: user.uid, email: user.email);
      return (await ProfileFirestoreQueries.fetchMergedDocs(q)).values.toList();
    }
    final res = await Future.wait([
      qCol('tickets'), qCol('appointments'), qCol('support_tickets'),
      fs.collection('notifications').limit(30).get().then((s) => s.docs),
    ]);
    return _assemble(user: user, tkts: res[0], apts: res[1], supps: res[2], broads: res[3]);
  }

  Stream<List<PatientNotificationEntity>> watchNotifications() {
    final fs = _fs;
    final user = _auth?.currentUser;
    if (fs == null || user == null) return Stream.value(const []);

    late StreamController<List<PatientNotificationEntity>> ctrl;
    final subs = <StreamSubscription>[];
    var tkts = <_Doc>[], apts = <_Doc>[], supps = <_Doc>[], broads = <_Doc>[];
    Map<String, dynamic>? userData;
    var generation = 0;

    Future<void> emit() async {
      final seq = ++generation;
      final items = await _assemble(
        user: user, tkts: tkts, apts: apts, supps: supps, broads: broads, userData: userData,
      );
      if (!ctrl.isClosed && seq == generation) ctrl.add(items);
    }

    ctrl = StreamController.broadcast(
      onListen: () {
        void watchCol(String col, void Function(List<_Doc>) set) {
          final q = ProfileFirestoreQueries.forUser(fs, col, uid: user.uid, email: user.email);
          subs.add(ProfileFirestoreQueries.watchMergedDocs(q).listen((d) { set(d); unawaited(emit()); }, onError: (_) {}));
        }
        watchCol('tickets', (d) => tkts = d);
        watchCol('appointments', (d) => apts = d);
        watchCol('support_tickets', (d) => supps = d);
        subs.add(fs.collection('notifications').limit(30).snapshots().listen((s) { broads = s.docs; unawaited(emit()); }, onError: (_) {}));
        subs.add(fs.collection('users').doc(user.uid).snapshots().listen((snap) {
          userData = snap.data();
          final remote = NotificationFirestoreReadSync.extractRemoteIds(userData);
          if (remote.isNotEmpty) unawaited(_readSync.cacheRemote(user.uid, remote));
          unawaited(emit());
        }, onError: (_) {}));
        subs.add(_localRefresh.stream.listen((_) => unawaited(emit())));
      },
      onCancel: () {
        for (final s in subs) { s.cancel(); }
        subs.clear();
      },
    );
    return ctrl.stream;
  }

  Future<List<PatientNotificationEntity>> _assemble({
    required User user, required List<_Doc> tkts, required List<_Doc> apts,
    required List<_Doc> supps, required List<_Doc> broads, Map<String, dynamic>? userData,
  }) async {
    final readIds = await _readSync.loadMergedReadIds(user.uid, userData: userData);
    final email = (user.email ?? '').trim().toLowerCase();
    final items = <PatientNotificationEntity>[
      for (final d in tkts) PatientNotificationMapper.fromTicket(d, readIds.contains('ticket_${d.id}')),
      for (final d in apts) PatientNotificationMapper.fromAppointment(d, readIds.contains('appt_${d.id}')),
      for (final d in supps) PatientNotificationMapper.fromSupport(d, readIds.contains('supp_${d.id}')),
    ];
    final matched = PatientNotificationBroadcastMapper.collectBroadcasts(
      docs: broads, uid: user.uid, email: email, readIds: readIds,
    );
    _personalNotifDocIds.addAll(matched.personalDocIds);
    items.addAll(matched.items);
    final seen = items.map((e) => '${e.title}|${e.body}').toSet();
    for (final p in await NotificationLocalStore.loadPushEntries()) {
      final entity = PatientNotificationMapper.fromPushMap(p, readIds.contains((p['id'] ?? '').toString()));
      if (seen.add('${entity.title}|${entity.body}')) items.add(entity);
    }
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }
}
