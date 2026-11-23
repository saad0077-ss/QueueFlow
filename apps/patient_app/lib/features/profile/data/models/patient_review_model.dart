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
  });

  factory PatientReviewModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    final ratingVal = json['rating'] as int? ?? 5;
    final docName =
        json['doctorName'] as String? ??
        json['doctor'] as String? ??
        'Dr. Rahul Menon';
    String specialty = 'Senior Medical Specialist';
    if (docName.toLowerCase().contains('rahul')) {
      specialty = 'Senior Dental Surgeon';
    } else if (docName.toLowerCase().contains('priya')) {
      specialty = 'Chief General Physician';
    } else if (docName.toLowerCase().contains('marcus')) {
      specialty = 'Head Pediatrician';
    }

    return PatientReviewModel(
      id:
          docId ??
          json['id'] as String? ??
          'rev-${DateTime.now().millisecondsSinceEpoch}',
      clinicId: json['clinicId'] as String? ?? 'smile-dental',
      clinicName: json['clinicName'] as String? ?? 'Smile Dental Clinic',
      doctorName: docName,
      rating: ratingVal,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Zero Wait Time', 'Hygienic Facility'],
      comment: json['comment'] as String? ?? '',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      date: json['date'] as String? ?? json['createdAt'] as String? ?? 'Recent',
      service:
          (json['service'] ?? json['serviceName'] ?? 'General Consultation')
              .toString(),
      doctorSpecialty: (json['doctorSpecialty'] ?? specialty).toString(),
      doctorRating: (json['doctorRating'] as num?)?.toInt() ?? ratingVal,
      clinicRating: (json['clinicRating'] as num?)?.toInt() ?? ratingVal,
      doctorTags:
          (json['doctorTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (docName.toLowerCase().contains('rahul')
              ? const [
                  'Gentle Hand',
                  'Painless Treatment',
                  'Polite & Reassuring',
                ]
              : const [
                  'Attentive Listener',
                  'Accurate Diagnosis',
                  'Clear Explanation',
                ]),
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 2,
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

  static List<PatientReviewModel> get defaultReviews => const [
    PatientReviewModel(
      id: 'rev-001',
      clinicId: 'smile-dental',
      clinicName: 'Smile Dental Clinic',
      doctorName: 'Dr. Rahul Menon',
      doctorSpecialty: 'Senior Dental Surgeon',
      service: 'Teeth Cleaning & Scaling',
      rating: 5,
      doctorRating: 5,
      clinicRating: 5,
      doctorTags: ['Gentle Hand', 'Painless Treatment', 'Polite & Reassuring'],
      tags: ['Modern Equipment', 'Hygienic Operatory', 'Zero Wait Time'],
      comment: 'Dr. Rahul Menon was exceptionally polite and explained each step of ultrasonic scaling. Completely painless experience!',
      isAnonymous: false,
      date: '10 Jun 2026',
      helpfulCount: 4,
    ),
    PatientReviewModel(
      id: 'rev-002',
      clinicId: 'sunrise-health',
      clinicName: 'Sunrise Health Clinic',
      doctorName: 'Dr. Priya Sharma',
      doctorSpecialty: 'Chief General Physician',
      service: 'Comprehensive Health Checkup',
      rating: 5,
      doctorRating: 5,
      clinicRating: 5,
      doctorTags: [
        'Attentive Listener',
        'Accurate Diagnosis',
        'Clear Explanation',
      ],
      tags: ['Digital Token Triage', 'Fast Live Queue', 'Friendly Reception'],
      comment: 'The digital queue tracking saved me over 35 minutes of waiting in the lobby. Dr. Priya provided very detailed diagnosis notes.',
      isAnonymous: false,
      date: '02 Jun 2026',
      helpfulCount: 2,
    ),
  ];
}
