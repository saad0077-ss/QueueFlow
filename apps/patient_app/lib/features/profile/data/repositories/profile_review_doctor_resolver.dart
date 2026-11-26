import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_review_resolvers.dart';

typedef ResolvedDoctorInfo = ({
  String name,
  String specialty,
  String photoUrl,
});

/// Matches doctors across `clinics/{id}.doctors`, subcollections, and `staff`.
class ProfileReviewDoctorResolver {
  const ProfileReviewDoctorResolver._();

  static String _normName(String raw) =>
      raw.toLowerCase().replaceFirst(RegExp(r'^dr\.?\s*'), '').trim();

  static Map<String, dynamic>? _matchInList(
    List<Map<String, dynamic>> list,
    String clinicId,
    String doctorId,
    String doctorNameHint,
  ) {
    final targetName = _normName(doctorNameHint);
    for (var i = 0; i < list.length; i++) {
      final m = list[i];
      final mid = (m['id'] ?? '').toString().trim();
      if (doctorId.isNotEmpty &&
          (mid == doctorId || '$clinicId-doc-$i' == doctorId)) {
        return m;
      }
    }
    if (targetName.isNotEmpty && targetName != 'attending doctor') {
      for (final m in list) {
        final raw = (m['name'] ?? m['fullName'] ?? '').toString();
        if (_normName(raw) == targetName) return m;
      }
    }
    return null;
  }

  static Future<ResolvedDoctorInfo> resolve(
    FirebaseFirestore fs,
    String clinicId,
    String doctorId,
    Map<String, ResolvedDoctorInfo> cache, {
    List<Map<String, dynamic>>? clinicDoctors,
    String? doctorNameHint,
  }) async {
    final hint = (doctorNameHint ?? '').trim();
    final key = '${clinicId}_${doctorId}_${hint.toLowerCase()}';
    if (cache.containsKey(key)) return cache[key]!;

    Map<String, dynamic>? d;
    try {
      final list = clinicDoctors ??
          (clinicId.isNotEmpty
              ? (await ProfileReviewResolvers.resolveClinicInfo(
                  fs, clinicId, {},
                )).doctors
              : const <Map<String, dynamic>>[]);
      d = _matchInList(list, clinicId, doctorId, hint);

      if (d == null && clinicId.isNotEmpty && doctorId.isNotEmpty) {
        final sub = await fs
            .collection('clinics').doc(clinicId)
            .collection('doctors').doc(doctorId).get();
        if (sub.exists) d = sub.data();
      }
      if (d == null && doctorId.isNotEmpty) {
        d = (await fs.collection('staff').doc(doctorId).get()).data();
        d ??= (await fs.collection('doctors').doc(doctorId).get()).data();
      }
      if (d == null && clinicId.isNotEmpty) {
        final staff = await fs
            .collection('staff').where('clinicId', isEqualTo: clinicId).get();
        d = _matchInList(
          staff.docs.map((s) => {...s.data(), 'id': s.id}).toList(),
          clinicId, doctorId, hint,
        );
      }
    } catch (_) {}

    final rawName = (d?['name'] ?? d?['fullName'] ?? '').toString().trim();
    final rawSpec =
        (d?['specialty'] ?? d?['specialization'] ?? d?['department'] ?? '')
            .toString().trim();
    final rawPhoto =
        (d?['photoUrl'] ?? d?['imageUrl'] ?? d?['avatarUrl'] ?? '')
            .toString().trim();

    return cache[key] = (
      name: rawName.isNotEmpty ? rawName : 'Attending Doctor',
      specialty: rawSpec.isNotEmpty ? rawSpec : 'Medical Specialist',
      photoUrl: rawPhoto,
    );
  }
}
