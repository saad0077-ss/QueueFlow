import 'package:equatable/equatable.dart';

class ClinicReviewItem extends Equatable {
  final String id;
  final String patientName;
  final String initials;
  final int rating;
  final String date;
  final String comment;
  final List<String> tags;
  final String doctor;
  final bool verified;
  final int helpfulCount;

  const ClinicReviewItem({
    required this.id,
    required this.patientName,
    required this.initials,
    required this.rating,
    required this.date,
    required this.comment,
    this.tags = const [],
    this.doctor = '',
    this.verified = true,
    this.helpfulCount = 0,
  });

  ClinicReviewItem copyWith({
    String? id,
    String? patientName,
    String? initials,
    int? rating,
    String? date,
    String? comment,
    List<String>? tags,
    String? doctor,
    bool? verified,
    int? helpfulCount,
  }) {
    return ClinicReviewItem(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      initials: initials ?? this.initials,
      rating: rating ?? this.rating,
      date: date ?? this.date,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      doctor: doctor ?? this.doctor,
      verified: verified ?? this.verified,
      helpfulCount: helpfulCount ?? this.helpfulCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientName,
        initials,
        rating,
        date,
        comment,
        tags,
        doctor,
        verified,
        helpfulCount,
      ];
}
