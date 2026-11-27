import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'profile_firestore_queries.dart';

class ProfileRealtimeSync {
  const ProfileRealtimeSync._();

  static Stream<void> watchChanges({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    if (Firebase.apps.isEmpty && (auth == null || firestore == null)) {
      return const Stream.empty();
    }

    late StreamController<void> ctrl;
    StreamSubscription<User?>? authSub;
    final dataSubs = <StreamSubscription>[];
    Timer? debounce;

    void clearDataSubs() {
      for (final s in dataSubs) {
        s.cancel();
      }
      dataSubs.clear();
    }

    void trigger() {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 300), () {
        if (!ctrl.isClosed) ctrl.add(null);
      });
    }

    void attachForUser(User? user) {
      clearDataSubs();
      if (user == null) {
        trigger();
        return;
      }
      final fs = firestore ?? FirebaseFirestore.instance;
      final uid = user.uid;
      final email = user.email;

      void watchCollection(String col) {
        final queries = ProfileFirestoreQueries.forUser(
          fs,
          col,
          uid: uid,
          email: email,
        );
        if (queries.isEmpty) return;
        dataSubs.add(
          ProfileFirestoreQueries.watchMergedDocs(
            queries,
          ).listen((_) => trigger(), onError: (_) {}),
        );
      }

      dataSubs.add(
        fs
            .collection('users')
            .doc(uid)
            .snapshots()
            .listen((_) => trigger(), onError: (_) {}),
      );
      for (final col in ['tickets', 'appointments', 'reviews', 'doctor_reviews']) {
        watchCollection(col);
      }
      trigger();
    }

    ctrl = StreamController<void>.broadcast(
      onListen: () {
        final fa = auth ?? FirebaseAuth.instance;
        authSub = fa.authStateChanges().listen(attachForUser, onError: (_) {});
      },
      onCancel: () {
        debounce?.cancel();
        authSub?.cancel();
        clearDataSubs();
      },
    );
    return ctrl.stream;
  }
}
