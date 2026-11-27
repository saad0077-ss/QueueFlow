import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../domain/entities/clinic_notification_item.dart';
import 'clinic_notification_mapper.dart';
import 'clinic_notifications_read_store.dart';

class ClinicNotificationsService {
  static final ClinicNotificationsService instance = ClinicNotificationsService._();

  ClinicNotificationsService._({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore,
      _readStore = ClinicNotificationsReadStore(firestore: firestore);

  ClinicNotificationsService.forTesting({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore,
      _readStore = ClinicNotificationsReadStore(firestore: firestore);

  final FirebaseFirestore? _firestoreOverride;
  final ClinicNotificationsReadStore _readStore;
  final StreamController<void> _localRefresh = StreamController<void>.broadcast();
  String _lastClinicId = '';

  FirebaseFirestore? get _fs {
    if (_firestoreOverride != null) return _firestoreOverride;
    return Firebase.apps.isEmpty ? null : FirebaseFirestore.instance;
  }

  void _notifyRefresh() {
    if (!_localRefresh.isClosed) _localRefresh.add(null);
  }

  Future<void> markAsRead(String id, {String? clinicId}) async {
    final cid = (clinicId != null && clinicId.isNotEmpty) ? clinicId : _lastClinicId;
    _readStore.addToMemory(cid, [id]);
    _notifyRefresh();
    await _readStore.markRead(cid, [id]);
    _notifyRefresh();
  }

  Future<void> markAllAsRead(List<String> ids, {String? clinicId}) async {
    final cid = (clinicId != null && clinicId.isNotEmpty) ? clinicId : _lastClinicId;
    _readStore.addToMemory(cid, ids);
    _notifyRefresh();
    await _readStore.markRead(cid, ids);
    _notifyRefresh();
  }

  Future<Set<String>> loadReadIds(String clinicId, {Map<String, dynamic>? clinicData}) =>
      _readStore.loadReadIds(clinicId, clinicData: clinicData);

  Future<void> flushPendingSync() => _readStore.flushPending();

  void resetSessionCache() {
    _readStore.resetSessionCache();
    _lastClinicId = '';
  }

  Stream<List<ClinicNotificationItem>> watchNotifications(String clinicId) {
    final fs = _fs;
    if (clinicId.isEmpty || fs == null) return Stream.value(const []);
    _lastClinicId = clinicId;

    late StreamController<List<ClinicNotificationItem>> ctrl;
    final subs = <StreamSubscription>[];
    var tkts = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    var apts = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    var supps = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    Map<String, dynamic>? clinicData;
    var generation = 0;

    Future<void> emit() async {
      final seq = ++generation;
      final readIds = await _readStore.loadReadIds(clinicId, clinicData: clinicData);
      final items = ClinicNotificationMapper.buildList(
        readIds: readIds, tkts: tkts, apts: apts, supps: supps,
      );
      if (!ctrl.isClosed && seq == generation) ctrl.add(items);
    }

    ctrl = StreamController.broadcast(
      onListen: () {
        void watchCol(String col, void Function(List<QueryDocumentSnapshot<Map<String, dynamic>>>) set) {
          subs.add(fs.collection(col).where('clinicId', isEqualTo: clinicId).limit(15).snapshots().listen(
            (s) {
              set(s.docs);
              unawaited(emit());
            },
            onError: (_) {},
          ));
        }
        watchCol('tickets', (d) => tkts = d);
        watchCol('appointments', (d) => apts = d);
        watchCol('support_tickets', (d) => supps = d);
        subs.add(fs.collection('clinics').doc(clinicId).snapshots().listen((snap) {
          clinicData = snap.data();
          final remoteIds = ClinicNotificationsReadStore.extractRemoteIds(clinicData);
          if (remoteIds.isNotEmpty) {
            unawaited(_readStore.cacheRemote(clinicId, remoteIds));
          }
          unawaited(emit());
        }, onError: (_) {}));
        subs.add(_localRefresh.stream.listen((_) => unawaited(emit())));
        unawaited(emit());
      },
      onCancel: () {
        for (final s in subs) {
          s.cancel();
        }
        subs.clear();
      },
    );
    return ctrl.stream;
  }
}
