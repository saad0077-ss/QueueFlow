import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/patient_review_entity.dart';
import '../models/patient_review_model.dart';
import 'profile_firestore_queries.dart';
import 'profile_queue_doc_mapper.dart';
import 'profile_review_resolvers.dart';

class ProfileReviewsQueryHelper {
  const ProfileReviewsQueryHelper._();

  static Future<int> countUserAppointments(
    FirebaseFirestore fs, {
    String? uid,
    String? email,
  }) async {
    final queries = ProfileFirestoreQueries.forUser(
      fs, 'appointments', uid: uid, email: email,
    );
    return (await ProfileFirestoreQueries.fetchMergedDocs(queries)).length;
  }

  static Future<void> _applyAttachments(
    FirebaseFirestore fs,
    Map<String, dynamic> data,
    Map<String, ResolvedClinicInfo> clinicInfos,
    Map<String, ResolvedDoctorInfo> doctorInfos, {
    required bool isDoctorReview,
  }) async {
    final rawClinicId = (data['clinicId'] ?? '').toString().trim();
    final rawClinicName = (data['clinicName'] ?? '').toString().trim();
    final cInfo = await ProfileReviewResolvers.resolveClinicInfo(
      fs,
      rawClinicId == 'clinic-1' ? '' : rawClinicId,
      clinicInfos,
      clinicNameHint: rawClinicName,
    );
    if (cInfo.id.isNotEmpty) data['clinicId'] = cInfo.id;
    if (rawClinicName.isEmpty) data['clinicName'] = cInfo.name;
    if (cInfo.imageUrl != null) data['clinicImageUrl'] = cInfo.imageUrl;
    if (cInfo.imageVersion > 0) data['clinicImageVersion'] = cInfo.imageVersion;

    final doctorId = (data['doctorId'] ?? '').toString().trim();
    final docName =
        (data['doctorName'] ?? data['doctor'] ?? '').toString().trim();
    if (isDoctorReview || doctorId.isNotEmpty || docName.isNotEmpty) {
      final dInfo = await ProfileReviewResolvers.resolveDoctorInfo(
        fs,
        cInfo.id.isNotEmpty ? cInfo.id : rawClinicId,
        doctorId,
        doctorInfos,
        clinicDoctors: cInfo.doctors,
        doctorNameHint: docName,
      );
      if (docName.isEmpty || docName.toLowerCase() == 'attending doctor') {
        data['doctorName'] = dInfo.name;
      }
      final spec = (data['doctorSpecialty'] ?? '').toString().trim();
      if ((spec.isEmpty || spec == 'Medical Specialist') &&
          dInfo.specialty.isNotEmpty) {
        data['doctorSpecialty'] = dInfo.specialty;
      }
      if (dInfo.photoUrl.isNotEmpty) data['doctorPhotoUrl'] = dInfo.photoUrl;
    }
  }

  static Future<List<PatientReviewEntity>> fetchUserReviews(
    FirebaseFirestore fs, {
    String? uid,
    String? email,
  }) async {
    final clinicReviewDocs = await ProfileFirestoreQueries.fetchMergedDocs(
      ProfileFirestoreQueries.forUser(fs, 'reviews', uid: uid, email: email),
    );
    final doctorReviewDocs = await ProfileFirestoreQueries.fetchMergedDocs(
      ProfileFirestoreQueries.forUser(
        fs, 'doctor_reviews', uid: uid, email: email,
      ),
    );

    final clinicInfos = <String, ResolvedClinicInfo>{};
    final doctorInfos = <String, ResolvedDoctorInfo>{};
    final items = <({PatientReviewModel model, DateTime? ts})>[];

    Future<void> addEntry(
      DocumentSnapshot<Map<String, dynamic>> doc, {
      required bool isDoctorReview,
    }) async {
      final data = Map<String, dynamic>.from(doc.data() ?? const {});
      await _applyAttachments(
        fs, data, clinicInfos, doctorInfos, isDoctorReview: isDoctorReview,
      );
      data['service'] ??=
          isDoctorReview ? 'Doctor Consultation' : 'Clinic Experience';
      final ts = ProfileQueueDocMapper.parseDate(data['createdAt']);
      items.add((
        model: PatientReviewModel.fromJson(data, docId: doc.id),
        ts: ts,
      ));
    }

    for (final d in clinicReviewDocs.values) {
      await addEntry(d, isDoctorReview: false);
    }
    for (final d in doctorReviewDocs.values) {
      if (!clinicReviewDocs.containsKey(d.id)) {
        await addEntry(d, isDoctorReview: true);
      }
    }

    items.sort((a, b) => (b.ts ?? DateTime(2000)).compareTo(a.ts ?? DateTime(2000)));
    return items.map((e) => e.model).toList();
  }

  /// Resolves live clinic & doctor images for a newly submitted review.
  static Future<PatientReviewModel> enrichNewReview(
    FirebaseFirestore fs, {
    required String id,
    required String clinicId,
    required String clinicName,
    required String doctorName,
    required int rating,
    required List<String> tags,
    required String comment,
    required bool isAnonymous,
  }) async {
    final data = <String, dynamic>{
      'id': id,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'doctorName': doctorName,
      'rating': rating,
      'tags': tags,
      'comment': comment,
      'isAnonymous': isAnonymous,
      'date': 'Just now',
    };
    await _applyAttachments(fs, data, {}, {}, isDoctorReview: false);
    return PatientReviewModel.fromJson(data, docId: id);
  }
}
