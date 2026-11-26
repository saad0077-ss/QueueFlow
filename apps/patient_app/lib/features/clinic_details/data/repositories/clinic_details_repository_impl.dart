import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:patient_app/core/services/clinic_rating_aggregator.dart';
import 'package:patient_app/features/profile/data/repositories/profile_review_resolvers.dart';

import '../../../home/domain/entities/clinic_entity.dart';
import '../../domain/entities/clinic_details_entity.dart';
import '../../domain/repositories/clinic_details_repository.dart';
import '../models/clinic_doctor_model.dart';
import '../models/clinic_fallback_data.dart';
import '../models/clinic_review_model.dart';
import '../models/clinic_service_model.dart';

class ClinicDetailsRepositoryImpl implements ClinicDetailsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ClinicDetailsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<ClinicDetailsEntity> getClinicDetails(
    String clinicId,
    ClinicEntity? initialClinic,
  ) async {
    final clinic =
        initialClinic ??
        const ClinicEntity(
          id: '',
          name: 'Clinic',
          initials: 'CL',
          category: 'General',
          rating: 0,
          reviewCount: 0,
          distance: '',
          city: 'Kochi',
          address: 'Main Road',
          phone: '+91 484 987 6543',
          consultationFee: '₹400',
          openingHours: '',
        );

    String description = ClinicFallbackData.getDescription(
      clinic.name,
      clinic.category,
    );
    List<String> features = const [];
    String? holidayNotice;

    try {
      final doc = await _firestore.collection('clinics').doc(clinicId).get();
      if (doc.exists) {
        final d = doc.data() ?? {};
        if ((d['description'] ?? '').toString().isNotEmpty) {
          description = d['description'].toString();
        }
        features = _featuresFrom(d);
        if ((d['holidayNotice'] ?? '').toString().isNotEmpty) {
          holidayNotice = d['holidayNotice'].toString();
        }
      }
    } catch (e) {
      debugPrint('Error fetching clinic doc: $e');
    }

    final services = await _fetchServices(clinicId, clinic.category);
    final doctors = await _fetchDoctors(clinicId, clinic.category);
    final reviews = await _fetchReviews(
      clinicId,
      clinicName: clinic.name,
      doctors: doctors,
    );
    final summary = ClinicRatingAggregator.summarize(
      reviews.map((r) => r.rating),
    );

    return ClinicDetailsEntity(
      clinic: clinic.withRating(
        rating: summary.average,
        reviewCount: summary.count,
      ),
      starPercents: summary.starPercents,
      description: description,
      features: features,
      holidayNotice: holidayNotice,
      services: services,
      doctors: doctors,
      reviews: reviews,
    );
  }

  /// Only what the clinic admin actually selected in Clinic Settings:
  /// parking choice (+ wheelchair access) and the emergency on-call switch.
  static List<String> _featuresFrom(Map<String, dynamic> d) {
    final out = <String>[];
    final loc = d['location'] is Map
        ? Map<String, dynamic>.from(d['location'] as Map)
        : const <String, dynamic>{};
    final parking = (loc['parking'] ?? '').toString().toLowerCase();
    if (parking.isNotEmpty) {
      if (parking.startsWith('free parking')) {
        out.add('Free parking');
      } else if (parking.startsWith('paid parking')) {
        out.add('Paid parking');
      } else if (parking.startsWith('street parking')) {
        out.add('Street parking');
      }
      if (parking.contains('wheelchair accessible') &&
          !parking.contains('not wheelchair')) {
        out.add('Wheelchair access');
      }
    }
    if (d['emergencyOnCall'] == true) out.add('Emergency on-call');
    return out;
  }

  Future<List<ClinicServiceModel>> _fetchServices(
    String clinicId,
    String cat,
  ) async {
    try {
      final snap = await _firestore
          .collection('services')
          .where('clinicId', isEqualTo: clinicId)
          .get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map(ClinicServiceModel.fromFirestore).toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<ClinicDoctorModel>> _fetchDoctors(
    String clinicId,
    String cat,
  ) async {
    try {
      final doctors = await ClinicDoctorModel.fetchForClinic(
        _firestore,
        clinicId,
      );
      final ratings = await _fetchDoctorRatings(clinicId);
      return doctors.map((d) {
        final r = ratings[d.id];
        if (r == null || r.isEmpty) return d;
        return d.withRating(
          rating: r.reduce((a, b) => a + b) / r.length,
          reviewCount: r.length,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
    }
    return const [];
  }

  /// Star ratings per doctor id; empty if none or unreadable.
  Future<Map<String, List<int>>> _fetchDoctorRatings(String clinicId) async {
    final out = <String, List<int>>{};
    try {
      final snap = await _firestore
          .collection('doctor_reviews')
          .where('clinicId', isEqualTo: clinicId)
          .get();
      for (final d in snap.docs) {
        final data = d.data();
        final id = (data['doctorId'] ?? '').toString();
        final r = (data['rating'] as num?)?.toInt() ?? 0;
        if (id.isNotEmpty && r > 0) {
          out.putIfAbsent(id, () => []).add(r.clamp(1, 5));
        }
      }
    } catch (e) {
      debugPrint('Error fetching doctor ratings: $e');
    }
    return out;
  }

  Future<List<ClinicReviewModel>> _fetchReviews(
    String clinicId, {
    String clinicName = '',
    List<ClinicDoctorModel> doctors = const [],
  }) async {
    try {
      final fRev = _firestore
          .collection('reviews')
          .where('clinicId', isEqualTo: clinicId)
          .get();
      final fDoc = _firestore
          .collection('doctor_reviews')
          .where('clinicId', isEqualTo: clinicId)
          .get();
      final fNamed = clinicName.trim().isNotEmpty
          ? _firestore
                .collection('reviews')
                .where('clinicName', isEqualTo: clinicName.trim())
                .get()
          : null;

      final revSnap = await fRev;
      final docSnap = await fDoc;
      final namedSnap = fNamed != null ? await fNamed : null;

      final doctorById = {for (final d in doctors) d.id: d.name};
      final combined = <({String id, ClinicReviewModel model, Object? ts})>[];
      final seen = <String>{};

      void addDoc(
        QueryDocumentSnapshot<Map<String, dynamic>> d, {
        bool isDoctor = false,
      }) {
        if (!seen.add(d.id)) return;
        final map = Map<String, dynamic>.from(d.data());
        if (isDoctor) {
          final did = (map['doctorId'] ?? '').toString();
          final dName = (map['doctorName'] ?? doctorById[did] ?? '').toString();
          if (dName.isNotEmpty) {
            map['doctor'] = dName;
            final rawTags = (map['tags'] as List<dynamic>?) ?? const [];
            if (rawTags.isEmpty) map['tags'] = ['👨‍⚕️ $dName'];
          }
          if ((map['comment'] ?? '').toString().trim().isEmpty) {
            final star = (map['rating'] as num?)?.toInt() ?? 5;
            map['comment'] = dName.isNotEmpty
                ? 'Rated $dName ($star★)'
                : 'Doctor Consultation ($star★)';
          }
        }
        combined.add((
          id: d.id,
          model: ClinicReviewModel.fromMap(map, id: d.id),
          ts: map['createdAt'],
        ));
      }

      for (final d in revSnap.docs) {
        addDoc(d);
      }
      if (namedSnap != null) {
        for (final d in namedSnap.docs) {
          addDoc(d);
        }
      }
      for (final d in docSnap.docs) {
        addDoc(d, isDoctor: true);
      }

      combined.sort((a, b) {
        final ta = a.ts, tb = b.ts;
        if (ta is! Timestamp || tb is! Timestamp) return 0;
        return tb.compareTo(ta);
      });
      return combined.map((e) => e.model).toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return const [];
    }
  }

  @override
  Future<void> submitReview({
    required String clinicId,
    required int rating,
    required String comment,
    required List<String> tags,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please sign in to rate this clinic.');
    final name = user.displayName?.trim() ?? '';
    final emailLower = (user.email ?? '').trim().toLowerCase();
    final clinicName = await ProfileReviewResolvers.resolveClinicName(
      _firestore,
      clinicId,
      {},
    );
    await _firestore.collection('reviews').add({
      'clinicId': clinicId,
      'clinicName': clinicName,
      'patientId': user.uid,
      'userId': user.uid,
      'patientName': name.isNotEmpty ? name : 'Verified Patient',
      'patientEmail': emailLower,
      'userEmail': emailLower,
      'rating': rating.clamp(1, 5),
      'comment': comment,
      'tags': tags,
      'verified': true,
      'helpfulCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await ClinicRatingAggregator.syncClinicRating(
      _firestore,
      clinicId,
      clinicName: clinicName,
    );
  }

  @override
  Future<void> submitDoctorReview({
    required String clinicId,
    required String doctorId,
    required int rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please sign in to rate this doctor.');
    final name = user.displayName?.trim() ?? '';
    final emailLower = (user.email ?? '').trim().toLowerCase();
    final clinicName = await ProfileReviewResolvers.resolveClinicName(
      _firestore,
      clinicId,
      {},
    );
    final docInfo = await ProfileReviewResolvers.resolveDoctorInfo(
      _firestore,
      clinicId,
      doctorId,
      {},
    );
    await _firestore
        .collection('doctor_reviews')
        .doc('${doctorId}_${user.uid}')
        .set({
          'clinicId': clinicId,
          'clinicName': clinicName,
          'doctorId': doctorId,
          'doctorName': docInfo.name,
          'doctorSpecialty': docInfo.specialty,
          'patientId': user.uid,
          'userId': user.uid,
          'patientName': name.isNotEmpty ? name : 'Verified Patient',
          'patientEmail': emailLower,
          'userEmail': emailLower,
          'rating': rating.clamp(1, 5),
          'comment': comment,
          'createdAt': FieldValue.serverTimestamp(),
        });
    await ClinicRatingAggregator.syncClinicRating(
      _firestore,
      clinicId,
      clinicName: clinicName,
    );
  }

  @override
  Future<void> markReviewHelpful(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'helpfulCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  @override
  Future<bool> isClinicFavorite(String clinicId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final data = (await _firestore.collection('users').doc(user.uid).get())
          .data();
      final favs = data?['favoriteClinics'];
      return favs is Map && favs.containsKey(clinicId);
    } catch (e) {
      debugPrint('Error reading favorite state: $e');
      return false;
    }
  }

  @override
  Future<void> setClinicFavorite(ClinicEntity clinic, bool favorite) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please sign in to save clinics.');
    final ref = _firestore.collection('users').doc(user.uid);
    if (favorite) {
      await ref.set({
        'favoriteClinics': {
          clinic.id: {
            'id': clinic.id,
            'name': clinic.name,
            'department': clinic.category,
            'rating': clinic.rating,
            'reviewsCount': clinic.reviewCount,
            'address': clinic.address,
            'initials': clinic.initials,
            if (clinic.imageUrl != null && clinic.imageUrl!.isNotEmpty)
              'imageUrl': clinic.imageUrl,
            if (clinic.imageVersion > 0) 'imageVersion': clinic.imageVersion,
            'savedAt': FieldValue.serverTimestamp(),
          },
        },
      }, SetOptions(merge: true));
    } else {
      await ref.set({
        'favoriteClinics': {clinic.id: FieldValue.delete()},
      }, SetOptions(merge: true));
    }
  }
}
