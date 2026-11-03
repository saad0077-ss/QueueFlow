import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<ClinicDetailsEntity> getClinicDetails(
    String clinicId,
    ClinicEntity? initialClinic,
  ) async {
    final clinic = initialClinic ??
        const ClinicEntity(
          id: '',
          name: 'Clinic',
          initials: 'CL',
          category: 'General',
          rating: 0,
          reviewCount: 0,
          distance: '1.2 km',
          city: 'Kochi',
          address: 'Main Road',
          phone: '+91 484 987 6543',
          consultationFee: '₹400',
          openingHours: 'Mon–Sat, 9:00 AM – 8:00 PM',
        );

    String description = ClinicFallbackData.getDescription(clinic.name, clinic.category);
    List<String> features = ClinicFallbackData.getFeatures(clinic.category);
    String? holidayNotice;

    try {
      final doc = await _firestore.collection('clinics').doc(clinicId).get();
      if (doc.exists) {
        final d = doc.data() ?? {};
        if ((d['description'] ?? '').toString().isNotEmpty) description = d['description'].toString();
        if (d['features'] is List) features = (d['features'] as List).map((e) => e.toString()).toList();
        if ((d['holidayNotice'] ?? '').toString().isNotEmpty) holidayNotice = d['holidayNotice'].toString();
      }
    } catch (e) {
      debugPrint('Error fetching clinic doc: $e');
    }

    final services = await _fetchServices(clinicId, clinic.category);
    final doctors = await _fetchDoctors(clinicId, clinic.category);
    final reviews = await _fetchReviews(clinicId);
    final summary = _summarize(reviews.map((r) => r.rating));

    return ClinicDetailsEntity(
      clinic: clinic.withRating(rating: summary.average, reviewCount: reviews.length),
      starPercents: summary.starPercents,
      description: description,
      features: features,
      holidayNotice: holidayNotice,
      services: services,
      doctors: doctors,
      reviews: reviews,
    );
  }

  Future<List<ClinicServiceModel>> _fetchServices(String clinicId, String cat) async {
    try {
      final snap = await _firestore.collection('services').where('clinicId', isEqualTo: clinicId).get();
      if (snap.docs.isNotEmpty) return snap.docs.map(ClinicServiceModel.fromFirestore).toList();
    } catch (_) {}
    return ClinicFallbackData.getServices(cat);
  }

  Future<List<ClinicDoctorModel>> _fetchDoctors(String clinicId, String cat) async {
    try {
      final snap = await _firestore.collection('staff').where('clinicId', isEqualTo: clinicId).get();
      if (snap.docs.isNotEmpty) return snap.docs.map(ClinicDoctorModel.fromFirestore).toList();
    } catch (_) {}
    return ClinicFallbackData.getDoctors(cat);
  }

  Future<List<ClinicReviewModel>> _fetchReviews(String clinicId) async {
    try {
      final snap = await _firestore.collection('reviews').where('clinicId', isEqualTo: clinicId).get();
      // Newest first; sorted here to avoid needing a composite index.
      final docs = snap.docs.toList()
        ..sort((a, b) {
          final ta = a.data()['createdAt'], tb = b.data()['createdAt'];
          if (ta is! Timestamp || tb is! Timestamp) return 0;
          return tb.compareTo(ta);
        });
      return docs.map(ClinicReviewModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return const [];
    }
  }

  /// Average rating and the share of each star (5★ → 1★) for [ratings].
  static ({double average, List<int> starPercents}) _summarize(Iterable<int> ratings) {
    final counts = List<int>.filled(5, 0);
    var total = 0, sum = 0;
    for (final r in ratings) {
      final star = r.clamp(1, 5);
      counts[5 - star]++;
      sum += star;
      total++;
    }
    if (total == 0) return (average: 0, starPercents: const [0, 0, 0, 0, 0]);
    return (
      average: sum / total,
      starPercents: counts.map((c) => (c * 100 / total).round()).toList(),
    );
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
    await _firestore.collection('reviews').add({
      'clinicId': clinicId,
      'patientId': user.uid,
      'patientName': name.isNotEmpty ? name : 'Verified Patient',
      'patientEmail': user.email ?? '',
      'rating': rating.clamp(1, 5),
      'comment': comment,
      'tags': tags,
      'verified': true,
      'helpfulCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _syncClinicRating(clinicId);
  }

  /// Stores the average rating on the clinic doc so lists and the platform console can show it.
  Future<void> _syncClinicRating(String clinicId) async {
    try {
      final snap = await _firestore.collection('reviews').where('clinicId', isEqualTo: clinicId).get();
      final ratings = snap.docs.map((d) => (d.data()['rating'] as num?)?.toInt() ?? 0).where((r) => r > 0).toList();
      final summary = _summarize(ratings);
      await _firestore.collection('clinics').doc(clinicId).set({
        'rating': double.parse(summary.average.toStringAsFixed(2)),
        'reviewCount': ratings.length,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing clinic rating: $e');
    }
  }

  @override
  Future<void> markReviewHelpful(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({'helpfulCount': FieldValue.increment(1)});
    } catch (_) {}
  }

  @override
  Future<bool> toggleFavoriteClinic(String clinicId) async => true;
}
