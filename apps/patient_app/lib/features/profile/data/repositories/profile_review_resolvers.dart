import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'profile_review_doctor_resolver.dart';

export 'profile_review_doctor_resolver.dart' show ResolvedDoctorInfo;

typedef ResolvedClinicInfo = ({
  String id,
  String name,
  String? imageUrl,
  int imageVersion,
  List<Map<String, dynamic>> doctors,
});

class ProfileReviewResolvers {
  const ProfileReviewResolvers._();

  static Future<String> resolveClinicName(
    FirebaseFirestore fs,
    String clinicId,
    Map<String, String> cache,
  ) async {
    if (cache.containsKey(clinicId)) return cache[clinicId]!;
    final info = await resolveClinicInfo(fs, clinicId, {});
    return cache[clinicId] = info.name;
  }

  static Future<ResolvedClinicInfo> resolveClinicInfo(
    FirebaseFirestore fs,
    String clinicId,
    Map<String, ResolvedClinicInfo> cache, {
    String? clinicNameHint,
  }) async {
    final hintKey = (clinicNameHint ?? '').trim().toLowerCase();
    if (clinicId.isNotEmpty && cache.containsKey(clinicId)) {
      return cache[clinicId]!;
    }
    if (hintKey.isNotEmpty && cache.containsKey('n:$hintKey')) {
      return cache['n:$hintKey']!;
    }

    var resolvedId = clinicId;
    Map<String, dynamic>? d;
    try {
      if (clinicId.isNotEmpty) {
        final snap = await fs.collection('clinics').doc(clinicId).get();
        if (snap.exists) d = snap.data();
      }
      if (d == null && hintKey.isNotEmpty) {
        final all = await fs.collection('clinics').get();
        for (final doc in all.docs) {
          final n = (doc.data()['name'] ?? '').toString().trim().toLowerCase();
          if (n == hintKey) {
            resolvedId = doc.id;
            d = doc.data();
            break;
          }
        }
      }
    } catch (_) {}

    final rawName = (d?['name'] ?? clinicNameHint ?? '').toString().trim();
    final rawImg = (d?['imageUrl'] ?? d?['image'] ?? d?['photoUrl'])
        ?.toString()
        .trim();
    var imgVer = (d?['imageVersion'] as num?)?.toInt() ?? 0;
    if (imgVer <= 0 && (rawImg?.isEmpty ?? true) && resolvedId.isNotEmpty) {
      imgVer = await hasClinicImageDoc(fs, resolvedId) ? 1 : 0;
    }

    final doctors = <Map<String, dynamic>>[
      for (final item in (d?['doctors'] as List<dynamic>? ?? const []))
        if (item is Map) Map<String, dynamic>.from(item),
    ];

    final info = (
      id: resolvedId,
      name: rawName.isNotEmpty ? rawName : 'Clinic',
      imageUrl: (rawImg?.isNotEmpty ?? false) ? rawImg : null,
      imageVersion: imgVer,
      doctors: doctors,
    );
    if (resolvedId.isNotEmpty) cache[resolvedId] = info;
    if (clinicId.isNotEmpty) cache[clinicId] = info;
    if (hintKey.isNotEmpty) cache['n:$hintKey'] = info;
    return info;
  }

  /// Checks `clinic_images/{clinicId}` for legacy clinics lacking `imageVersion`.
  static Future<bool> hasClinicImageDoc(
    FirebaseFirestore fs,
    String clinicId,
  ) async {
    try {
      final snap = await fs.collection('clinic_images').doc(clinicId).get();
      final data = snap.data()?['data'];
      return data is String && data.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<ResolvedDoctorInfo> resolveDoctorInfo(
    FirebaseFirestore fs,
    String clinicId,
    String doctorId,
    Map<String, ResolvedDoctorInfo> cache, {
    List<Map<String, dynamic>>? clinicDoctors,
    String? doctorNameHint,
  }) => ProfileReviewDoctorResolver.resolve(
    fs,
    clinicId,
    doctorId,
    cache,
    clinicDoctors: clinicDoctors,
    doctorNameHint: doctorNameHint,
  );

  static Future<void> deleteReview(FirebaseFirestore fs, String reviewId) async {
    for (final col in ['reviews', 'doctor_reviews']) {
      try {
        await fs.collection(col).doc(reviewId).delete();
      } catch (e) {
        debugPrint('Delete skipped in $col/$reviewId: $e');
      }
    }
  }
}
