import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patient_app/core/services/clinic_rating_aggregator.dart';
import 'package:patient_app/features/clinic_details/data/models/clinic_doctor_model.dart';
import 'package:patient_app/features/home/data/models/clinic_model.dart';
import 'package:patient_app/features/home/data/repositories/home_repository_impl.dart'
    show isTicketFromToday;
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';

import '../models/favorite_clinic_model.dart';
import 'profile_review_resolvers.dart';

class ProfileFavoritesQueryHelper {
  const ProfileFavoritesQueryHelper._();

  static Future<List<FavoriteClinicModel>> fetchFavorites(
    FirebaseFirestore firestore,
    String uid,
  ) async {
    final userData = (await firestore.collection('users').doc(uid).get()).data();
    final rawFavs = userData?['favoriteClinics'];
    if (rawFavs is! Map || rawFavs.isEmpty) return const [];

    final savedById = <String, Map<String, dynamic>>{};
    for (final entry in rawFavs.entries) {
      if (entry.value is! Map) continue;
      final m = Map<String, dynamic>.from(entry.value as Map);
      final id = (m['id'] ?? entry.key).toString().trim();
      if (id.isNotEmpty) savedById[id] = {...m, 'id': id};
    }
    if (savedById.isEmpty) return const [];

    final ids = savedById.keys.toList();
    final clinicDocsFuture = Future.wait(
      ids.map((id) => firestore.collection('clinics').doc(id).get()),
    );
    final doctorsFuture = Future.wait(
      ids.map(
        (id) => ClinicDoctorModel.fetchForClinic(firestore, id)
            .catchError((_) => <ClinicDoctorModel>[]),
      ),
    );
    QuerySnapshot<Map<String, dynamic>>? ticketSnap;
    try {
      ticketSnap = await firestore
          .collection('tickets')
          .where('status', whereIn: ['waiting', 'called'])
          .get();
    } catch (_) {}

    final clinicDocs = await clinicDocsFuture;
    final doctorLists = await doctorsFuture;

    final waitingByClinic = <String, int>{};
    if (ticketSnap != null) {
      for (final d in ticketSnap.docs) {
        final data = d.data();
        if (data['status'] == 'waiting' && isTicketFromToday(data)) {
          final cid = (data['clinicId'] ?? '').toString().trim();
          if (cid.isNotEmpty) {
            waitingByClinic[cid] = (waitingByClinic[cid] ?? 0) + 1;
          }
        }
      }
    }

    final namesById = <String, String>{};
    final clinicsById = <String, ClinicEntity>{};
    final rawClinicsById = <String, Map<String, dynamic>>{};
    for (var i = 0; i < ids.length; i++) {
      final snap = clinicDocs[i];
      final id = ids[i];
      if (snap.exists && snap.data() != null) {
        rawClinicsById[id] = snap.data()!;
        final parsed = ClinicModel.fromFirestore(snap);
        clinicsById[id] = parsed;
        namesById[id] = parsed.name;
      } else {
        namesById[id] = (savedById[id]!['name'] ?? '').toString();
      }
    }

    final summaries = await ClinicRatingAggregator.fetchAllClinicSummaries(
      firestore,
      clinicNamesById: namesById,
    );

    final results = <FavoriteClinicModel>[];
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      final saved = savedById[id]!;
      final live = clinicsById[id];
      final rawClinic = rawClinicsById[id];
      final sum = summaries[id];
      final docs = doctorLists[i];
      final waiting = waitingByClinic[id] ?? 0;
      final avgMin = (rawClinic?['avgConsultationTimeMin'] as num?)?.toInt() ?? 10;
      var imgUrl = live?.imageUrl ??
          (rawClinic?['photoUrl'] ?? '').toString().trim();
      var imgVer = live?.imageVersion ?? 0;
      if (imgVer <= 0 && imgUrl.trim().isEmpty) {
        if (await ProfileReviewResolvers.hasClinicImageDoc(firestore, id)) {
          imgVer = 1;
        }
      }
      final leadDoc = docs.isNotEmpty ? docs.first : null;

      results.add(
        FavoriteClinicModel.fromJson({
          ...saved,
          if (live != null) ...{
            'name': live.name,
            'department': live.category,
            'address': live.address,
            'initials': live.initials,
            'distance': live.distanceLabel,
            'openHours': _formatOpenStatus(live),
            'phone': (rawClinic?['phone'] ?? '').toString(),
          },
          if (imgUrl.trim().isNotEmpty) 'imageUrl': imgUrl.trim(),
          if (imgVer > 0) 'imageVersion': imgVer,
          'waitingCount': waiting,
          'estWaitTime': waiting > 0 ? '${waiting * avgMin} min' : '',
          'topDoctor': leadDoc?.name ?? '',
          'topDoctorPhotoUrl': leadDoc?.photoUrl ?? '',
          'rating': sum?.average ?? 0.0,
          'reviewsCount': sum?.count ?? 0,
        }),
      );
    }
    results.sort((a, b) => a.name.compareTo(b.name));
    return results;
  }

  static String _formatOpenStatus(ClinicEntity clinic) {
    final now = DateTime.now();
    final breakEnd = clinic.breakEndsAt(now);
    if (breakEnd != null) return 'On break till $breakEnd';
    if (!clinic.isOpen) return 'Closed';
    final hours = clinic.openingHours.trim();
    if (clinic.isOpenNow) {
      return hours.isNotEmpty ? 'Open $hours' : 'Open now';
    }
    return hours.isNotEmpty ? 'Closed · $hours' : 'Closed today';
  }
}
