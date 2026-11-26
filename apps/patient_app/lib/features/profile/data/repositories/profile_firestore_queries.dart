import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProfileFirestoreQueries {
  const ProfileFirestoreQueries._();

  static const defaultEmailFields = [
    'patientEmail',
    'userEmail',
    'customerEmail',
  ];
  static const defaultIdFields = ['patientId', 'userId', 'customerId'];

  static List<Query<Map<String, dynamic>>> forUser(
    FirebaseFirestore fs,
    String collection, {
    String? uid,
    String? email,
    List<String> emailFields = defaultEmailFields,
    List<String> idFields = defaultIdFields,
  }) {
    final queries = <Query<Map<String, dynamic>>>[];
    final rawEmail = email?.trim() ?? '';
    final emailLower = rawEmail.toLowerCase();

    if (emailLower.isNotEmpty) {
      for (final f in emailFields) {
        queries.add(fs.collection(collection).where(f, isEqualTo: emailLower));
        if (rawEmail != emailLower) {
          queries.add(fs.collection(collection).where(f, isEqualTo: rawEmail));
        }
      }
    }
    if (uid != null && uid.isNotEmpty) {
      for (final f in idFields) {
        queries.add(fs.collection(collection).where(f, isEqualTo: uid));
      }
    }
    return queries;
  }

  static Future<Map<String, DocumentSnapshot<Map<String, dynamic>>>>
      fetchMergedDocs(List<Query<Map<String, dynamic>>> queries) async {
    final docsById = <String, DocumentSnapshot<Map<String, dynamic>>>{};
    if (queries.isEmpty) return docsById;
    await Future.wait(
      queries.map((q) async {
        try {
          final snap = await q.get();
          for (final d in snap.docs) {
            docsById[d.id] = d;
          }
        } catch (e) {
          debugPrint('Firestore query skipped: $e');
        }
      }),
    );
    return docsById;
  }

  static Stream<List<DocumentSnapshot<Map<String, dynamic>>>> watchMergedDocs(
    List<Query<Map<String, dynamic>>> queries,
  ) {
    if (queries.isEmpty) return Stream.value(const []);

    late StreamController<List<DocumentSnapshot<Map<String, dynamic>>>> ctrl;
    final subs = <StreamSubscription>[];
    final byQuery = <int, List<DocumentSnapshot<Map<String, dynamic>>>>{};

    void emit() {
      if (ctrl.isClosed) return;
      final merged = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final list in byQuery.values) {
        for (final doc in list) {
          merged[doc.id] = doc;
        }
      }
      ctrl.add(merged.values.toList());
    }

    ctrl = StreamController.broadcast(
      onListen: () {
        for (var i = 0; i < queries.length; i++) {
          final idx = i;
          subs.add(
            queries[idx].snapshots().listen((snap) {
              byQuery[idx] = snap.docs;
              emit();
            }, onError: (_) {}),
          );
        }
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
