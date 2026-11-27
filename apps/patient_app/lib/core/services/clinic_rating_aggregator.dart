import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

typedef ClinicRatingSummary = ({
  double average,
  int count,
  List<int> starPercents,
});

class ClinicRatingAggregator {
  const ClinicRatingAggregator._();

  static ClinicRatingSummary summarize(Iterable<int> ratings) {
    final counts = List<int>.filled(5, 0);
    var total = 0;
    var sum = 0;
    for (final r in ratings) {
      if (r <= 0) continue;
      final star = r.clamp(1, 5);
      counts[5 - star]++;
      sum += star;
      total++;
    }
    if (total == 0) {
      return (average: 0.0, count: 0, starPercents: const [0, 0, 0, 0, 0]);
    }
    return (
      average: double.parse((sum / total).toStringAsFixed(2)),
      count: total,
      starPercents: counts.map((c) => (c * 100 / total).round()).toList(),
    );
  }

  static Map<String, ClinicRatingSummary> aggregateFromMaps({
    required Iterable<Map<String, dynamic>> clinicReviewMaps,
    required Iterable<Map<String, dynamic>> doctorReviewMaps,
    Map<String, String> clinicNamesById = const {},
  }) {
    final nameToId = <String, String>{};
    clinicNamesById.forEach((id, name) {
      final key = name.trim().toLowerCase();
      if (key.isNotEmpty) nameToId[key] = id;
    });

    final grouped = <String, List<int>>{};
    void collect(Map<String, dynamic> m) {
      final rating = (m['rating'] as num?)?.toInt() ?? 0;
      if (rating <= 0) return;
      var cid = (m['clinicId'] ?? '').toString().trim();
      if (cid.isEmpty ||
          (clinicNamesById.isNotEmpty && !clinicNamesById.containsKey(cid))) {
        final cname = (m['clinicName'] ?? '').toString().trim().toLowerCase();
        if (nameToId.containsKey(cname)) cid = nameToId[cname]!;
      }
      if (cid.isEmpty) return;
      grouped.putIfAbsent(cid, () => []).add(rating);
    }

    for (final m in clinicReviewMaps) {
      collect(m);
    }
    for (final m in doctorReviewMaps) {
      collect(m);
    }
    return {
      for (final e in grouped.entries) e.key: summarize(e.value),
    };
  }

  static Future<Map<String, ClinicRatingSummary>> fetchAllClinicSummaries(
    FirebaseFirestore fs, {
    Map<String, String> clinicNamesById = const {},
  }) async {
    try {
      final fClinic = fs.collection('reviews').get();
      final fDoctor = fs.collection('doctor_reviews').get();
      final results = await Future.wait([fClinic, fDoctor]);
      return aggregateFromMaps(
        clinicReviewMaps: results[0].docs.map((d) => d.data()),
        doctorReviewMaps: results[1].docs.map((d) => d.data()),
        clinicNamesById: clinicNamesById,
      );
    } catch (e) {
      debugPrint('Error aggregating clinic ratings: $e');
      return const {};
    }
  }

  static Future<ClinicRatingSummary> syncClinicRating(
    FirebaseFirestore fs,
    String clinicId, {
    String? clinicName,
  }) async {
    try {
      final fRev = fs
          .collection('reviews')
          .where('clinicId', isEqualTo: clinicId)
          .get();
      final fDoc = fs
          .collection('doctor_reviews')
          .where('clinicId', isEqualTo: clinicId)
          .get();
      final res = await Future.wait([fRev, fDoc]);
      final ratings = <int>[
        for (final d in res[0].docs) (d.data()['rating'] as num?)?.toInt() ?? 0,
        for (final d in res[1].docs) (d.data()['rating'] as num?)?.toInt() ?? 0,
      ];
      final summary = summarize(ratings);
      await fs.collection('clinics').doc(clinicId).set({
        'rating': summary.average,
        'reviewCount': summary.count,
      }, SetOptions(merge: true));
      return summary;
    } catch (e) {
      debugPrint('Error syncing clinic rating: $e');
      return summarize(const []);
    }
  }

  static Future<String> resolveClinicIdByName(
    FirebaseFirestore fs,
    String clinicName,
    String fallbackId,
  ) async {
    final target = clinicName.trim().toLowerCase();
    if (target.isEmpty) return fallbackId;
    try {
      if (fallbackId.isNotEmpty && fallbackId != 'clinic-1') {
        final doc = await fs.collection('clinics').doc(fallbackId).get();
        if (doc.exists) return fallbackId;
      }
      final snap = await fs.collection('clinics').get();
      for (final d in snap.docs) {
        final name = (d.data()['name'] ?? '').toString().trim().toLowerCase();
        if (name == target) return d.id;
      }
    } catch (_) {}
    return fallbackId;
  }
}
