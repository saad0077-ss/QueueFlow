import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/patient_review_entity.dart';

class PatientReviewModel extends PatientReviewEntity {
  const PatientReviewModel({
    required super.id,
    required super.clinicId,
    required super.clinicName,
    required super.doctorName,
    required super.rating,
    required super.tags,
    required super.comment,
    required super.isAnonymous,
    required super.date,
    super.service,
    super.doctorSpecialty,
    super.doctorRating,
    super.clinicRating,
    super.doctorTags,
    super.helpfulCount,
    super.clinicImageUrl,
    super.clinicImageVersion,
    super.doctorPhotoUrl,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String formatTimestamp(Object? raw) {
    DateTime? d;
    if (raw is Timestamp) d = raw.toDate();
    if (raw is DateTime) d = raw;
    if (raw is String) d = DateTime.tryParse(raw);
    if (d == null) return 'Recent';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  factory PatientReviewModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    final ratingVal = (json['rating'] as num?)?.toInt() ?? 5;
    final docName = (json['doctorName'] ?? json['doctor'] ?? '').toString();
    final lowerDoc = docName.toLowerCase();
    var specialty = '';
    if (docName.isNotEmpty) {
      specialty = 'Senior Medical Specialist';
      if (lowerDoc.contains('rahul')) specialty = 'Senior Dental Surgeon';
      if (lowerDoc.contains('priya')) specialty = 'Chief General Physician';
      if (lowerDoc.contains('marcus')) specialty = 'Head Pediatrician';
    }

    final rawDate = json['date'];
    final dateStr = (rawDate is String && rawDate.trim().isNotEmpty)
        ? rawDate
        : formatTimestamp(json['createdAt']);

    final rawTags = json['tags'] as List<dynamic>?;
    final rawDocTags = json['doctorTags'] as List<dynamic>?;
    final rawClinicImg =
        (json['clinicImageUrl'] ?? json['imageUrl'])?.toString().trim();

    return PatientReviewModel(
      id: docId ?? (json['id'] ?? '').toString(),
      clinicId: (json['clinicId'] ?? '').toString(),
      clinicName: (json['clinicName'] ?? 'Clinic').toString(),
      doctorName: docName,
      rating: ratingVal,
      tags: rawTags?.map((e) => e.toString()).toList() ?? const [],
      comment: (json['comment'] ?? '').toString(),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      date: dateStr,
      service: (json['service'] ?? json['serviceName'] ?? 'Consultation')
          .toString(),
      doctorSpecialty: (json['doctorSpecialty'] ?? specialty).toString(),
      doctorRating: (json['doctorRating'] as num?)?.toInt() ?? ratingVal,
      clinicRating: (json['clinicRating'] as num?)?.toInt() ?? ratingVal,
      doctorTags: rawDocTags?.map((e) => e.toString()).toList() ?? const [],
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      clinicImageUrl:
          (rawClinicImg?.isNotEmpty ?? false) ? rawClinicImg : null,
      clinicImageVersion:
          (json['clinicImageVersion'] as num?)?.toInt() ??
          (json['imageVersion'] as num?)?.toInt() ??
          0,
      doctorPhotoUrl:
          (json['doctorPhotoUrl'] ?? json['photoUrl'] ?? '').toString().trim(),
    );
  }

  factory PatientReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PatientReviewModel.fromJson(data, docId: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'doctorName': doctorName,
      'rating': rating,
      'tags': tags,
      'comment': comment,
      'isAnonymous': isAnonymous,
      'date': date,
      'service': service,
      'doctorSpecialty': doctorSpecialty,
      'doctorRating': doctorRating,
      'clinicRating': clinicRating,
      'doctorTags': doctorTags,
      'helpfulCount': helpfulCount,
    };
  }
}
