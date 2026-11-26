import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/clinic_rating_aggregator.dart';
import '../../domain/entities/clinic_entity.dart';

class HomeClinicsRatingOverlay {
  const HomeClinicsRatingOverlay._();

  static List<ClinicEntity> apply(
    List<ClinicEntity> clinics,
    Map<String, ClinicRatingSummary> summaries,
  ) {
    return clinics.map((c) {
      final sum = summaries[c.id];
      return c.withRating(
        rating: sum?.average ?? 0.0,
        reviewCount: sum?.count ?? 0,
      );
    }).toList();
  }

  static Future<List<ClinicEntity>> loadAndApply(
    FirebaseFirestore fs,
    List<ClinicEntity> clinics,
  ) async {
    if (clinics.isEmpty) return clinics;
    try {
      final fRev = fs.collection('reviews').get();
      final fDoc = fs.collection('doctor_reviews').get();
      final res = await Future.wait([fRev, fDoc]);
      final summaries = ClinicRatingAggregator.aggregateFromMaps(
        clinicReviewMaps: res[0].docs.map((d) => d.data()),
        doctorReviewMaps: res[1].docs.map((d) => d.data()),
        clinicNamesById: {for (final c in clinics) c.id: c.name},
      );
      return apply(clinics, summaries);
    } catch (_) {
      return clinics;
    }
  }

  static Stream<List<ClinicEntity>> watchClinicsWithLiveRatings(
    FirebaseFirestore fs,
    List<ClinicEntity> Function(List<QueryDocumentSnapshot<Map<String, dynamic>>>)
        mapClinics,
  ) {
    late StreamController<List<ClinicEntity>> ctrl;
    StreamSubscription? subClinics;
    StreamSubscription? subReviews;
    StreamSubscription? subDocReviews;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> latestClinics = const [];
    List<Map<String, dynamic>> latestReviews = const [];
    List<Map<String, dynamic>> latestDocReviews = const [];
    var hasClinics = false;

    void emit() {
      if (ctrl.isClosed || !hasClinics) return;
      final clinics = mapClinics(latestClinics);
      final summaries = ClinicRatingAggregator.aggregateFromMaps(
        clinicReviewMaps: latestReviews,
        doctorReviewMaps: latestDocReviews,
        clinicNamesById: {for (final c in clinics) c.id: c.name},
      );
      ctrl.add(apply(clinics, summaries));
    }

    ctrl = StreamController<List<ClinicEntity>>.broadcast(
      onListen: () {
        subClinics = fs.collection('clinics').snapshots().listen((snap) {
          latestClinics = snap.docs;
          hasClinics = true;
          emit();
        }, onError: (_) {});
        subReviews = fs.collection('reviews').snapshots().listen((snap) {
          latestReviews = snap.docs.map((d) => d.data()).toList();
          emit();
        }, onError: (_) {});
        subDocReviews =
            fs.collection('doctor_reviews').snapshots().listen((snap) {
          latestDocReviews = snap.docs.map((d) => d.data()).toList();
          emit();
        }, onError: (_) {});
      },
      onCancel: () {
        subClinics?.cancel();
        subReviews?.cancel();
        subDocReviews?.cancel();
      },
    );
    return ctrl.stream;
  }
}
