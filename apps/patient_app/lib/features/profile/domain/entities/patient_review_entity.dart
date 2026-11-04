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
      ];
}
