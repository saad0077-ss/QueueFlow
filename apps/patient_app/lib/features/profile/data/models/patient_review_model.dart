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
  });

  factory PatientReviewModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    return PatientReviewModel(
      id:
          docId ??
          json['id'] as String? ??
          'rev-${DateTime.now().millisecondsSinceEpoch}',
      clinicId: json['clinicId'] as String? ?? 'smile-dental',
      clinicName: json['clinicName'] as String? ?? 'Smile Dental Clinic',
      doctorName:
          json['doctorName'] as String? ??
          json['doctor'] as String? ??
          'Dr. Rahul Menon',
      rating: json['rating'] as int? ?? 5,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Zero Wait Time', 'Friendly Doctor'],
      comment: json['comment'] as String? ?? '',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      date: json['date'] as String? ?? json['createdAt'] as String? ?? 'Recent',
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
    };
  }
}
