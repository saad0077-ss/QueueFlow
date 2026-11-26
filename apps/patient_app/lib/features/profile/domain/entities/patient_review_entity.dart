import 'package:equatable/equatable.dart';

class PatientReviewEntity extends Equatable {
  final String id;
  final String clinicId;
  final String clinicName;
  final String doctorName;
  final int rating;
  final List<String> tags;
  final String comment;
  final bool isAnonymous;
  final String date;
  final String service;
  final String doctorSpecialty;
  final int doctorRating;
  final int clinicRating;
  final List<String> doctorTags;
  final int helpfulCount;
  final String? clinicImageUrl;
  final int clinicImageVersion;
  final String doctorPhotoUrl;

  const PatientReviewEntity({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.doctorName,
    required this.rating,
    required this.tags,
    required this.comment,
    required this.isAnonymous,
    required this.date,
    this.service = 'General Consultation',
    this.doctorSpecialty = 'Senior Attending Specialist',
    this.doctorRating = 5,
    this.clinicRating = 5,
    this.doctorTags = const [],
    this.helpfulCount = 2,
    this.clinicImageUrl,
    this.clinicImageVersion = 0,
    this.doctorPhotoUrl = '',
  });

  @override
  List<Object?> get props => [
    id,
    clinicId,
    clinicName,
    doctorName,
    rating,
    tags,
    comment,
    isAnonymous,
    date,
    service,
    doctorSpecialty,
    doctorRating,
    clinicRating,
    doctorTags,
    helpfulCount,
    clinicImageUrl,
    clinicImageVersion,
    doctorPhotoUrl,
  ];
}
