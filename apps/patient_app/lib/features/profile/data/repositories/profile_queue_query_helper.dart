import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/patient_queue_history_entity.dart';
import 'profile_firestore_queries.dart';
import 'profile_queue_doc_mapper.dart';
import 'profile_review_resolvers.dart';

class ProfileQueueQueryHelper {
  const ProfileQueueQueryHelper._();

  static bool _isQueueLinkedAppointment(Map<String, dynamic> data) {
    final s = (data['status'] ?? '').toString().trim().toLowerCase();
    return data['checkedInAt'] != null ||
        s == 'checkedin' ||
        s == 'checked-in' ||
        s == 'called' ||
        s == 'waiting' ||
        ((data['token'] ?? data['queueToken'])?.toString().isNotEmpty ?? false);
  }

  static Future<List<PatientQueueHistoryEntity>> _mapAndEnrich(
    FirebaseFirestore fs,
    Iterable<DocumentSnapshot<Map<String, dynamic>>> docs,
    Map<String, ResolvedClinicInfo> clinicCache,
    Map<String, ResolvedDoctorInfo> doctorCache,
  ) async {
    final list = <PatientQueueHistoryEntity>[];
    for (final doc in docs) {
      final data = Map<String, dynamic>.from(doc.data() ?? const {});
      final cid = (data['clinicId'] ?? '').toString().trim();
      final cname = (data['clinicName'] ?? '').toString().trim();
      final cInfo = await ProfileReviewResolvers.resolveClinicInfo(
        fs, cid, clinicCache, clinicNameHint: cname,
      );
      if (cInfo.id.isNotEmpty) data['clinicId'] = cInfo.id;
      if (cname.isEmpty) data['clinicName'] = cInfo.name;
      if (cInfo.imageUrl != null) data['clinicImageUrl'] = cInfo.imageUrl;
      if (cInfo.imageVersion > 0) data['clinicImageVersion'] = cInfo.imageVersion;

      final docId = (data['doctorId'] ?? '').toString().trim();
      final docName = (data['doctorName'] ?? data['doctor'] ?? '').toString().trim();
      if (docId.isNotEmpty ||
          (docName.isNotEmpty && docName.toLowerCase() != 'attending doctor')) {
        final dInfo = await ProfileReviewResolvers.resolveDoctorInfo(
          fs,
          cInfo.id.isNotEmpty ? cInfo.id : cid,
          docId,
          doctorCache,
          clinicDoctors: cInfo.doctors,
          doctorNameHint: docName,
        );
        if (docName.isEmpty || docName.toLowerCase() == 'attending doctor') {
          data['doctorName'] = dInfo.name;
        }
        if (dInfo.photoUrl.isNotEmpty) data['doctorPhotoUrl'] = dInfo.photoUrl;
      }
      list.add(ProfileQueueDocMapper.mapRaw(doc.id, data));
    }
    return ProfileQueueDocMapper.sortList(list);
  }

  static Future<List<PatientQueueHistoryEntity>> fetchQueueHistory(
    FirebaseFirestore fs, {
    String? uid,
    String? email,
  }) async {
    final tktQ = ProfileFirestoreQueries.forUser(fs, 'tickets', uid: uid, email: email);
    final aptQ = ProfileFirestoreQueries.forUser(fs, 'appointments', uid: uid, email: email);
    if (tktQ.isEmpty) return const [];

    final docsById = await ProfileFirestoreQueries.fetchMergedDocs(tktQ);
    final aptDocs = await ProfileFirestoreQueries.fetchMergedDocs(aptQ);
    for (final entry in aptDocs.entries) {
      if (!docsById.containsKey(entry.key) &&
          _isQueueLinkedAppointment(entry.value.data() ?? const {})) {
        docsById[entry.key] = entry.value;
      }
    }
    return _mapAndEnrich(fs, docsById.values, {}, {});
  }

  static Stream<List<PatientQueueHistoryEntity>> watchQueueHistory(
    FirebaseFirestore fs, {
    String? uid,
    String? email,
  }) {
    final tktQ = ProfileFirestoreQueries.forUser(fs, 'tickets', uid: uid, email: email);
    final aptQ = ProfileFirestoreQueries.forUser(fs, 'appointments', uid: uid, email: email);
    if (tktQ.isEmpty) return Stream.value(const []);

    late StreamController<List<PatientQueueHistoryEntity>> ctrl;
    StreamSubscription? subTkt;
    StreamSubscription? subApt;
    var latestTkts = <DocumentSnapshot<Map<String, dynamic>>>[];
    var latestApts = <DocumentSnapshot<Map<String, dynamic>>>[];
    final clinicCache = <String, ResolvedClinicInfo>{};
    final doctorCache = <String, ResolvedDoctorInfo>{};
    var generation = 0;

    Future<void> emit() async {
      final seq = ++generation;
      final merged = <String, DocumentSnapshot<Map<String, dynamic>>>{
        for (final d in latestTkts) d.id: d,
      };
      for (final d in latestApts) {
        if (!merged.containsKey(d.id) && _isQueueLinkedAppointment(d.data() ?? const {})) {
          merged[d.id] = d;
        }
      }
      final mapped = await _mapAndEnrich(fs, merged.values, clinicCache, doctorCache);
      if (!ctrl.isClosed && seq == generation) ctrl.add(mapped);
    }

    ctrl = StreamController.broadcast(
      onListen: () {
        subTkt = ProfileFirestoreQueries.watchMergedDocs(tktQ).listen((docs) {
          latestTkts = docs;
          unawaited(emit());
        });
        subApt = ProfileFirestoreQueries.watchMergedDocs(aptQ).listen((docs) {
          latestApts = docs;
          unawaited(emit());
        });
      },
      onCancel: () {
        subTkt?.cancel();
        subApt?.cancel();
      },
    );
    return ctrl.stream;
  }
}
