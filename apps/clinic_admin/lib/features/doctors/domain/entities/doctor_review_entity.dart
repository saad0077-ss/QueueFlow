import 'package:equatable/equatable.dart';

/// Patient review entity for doctor feedback.
class DoctorReviewEntity extends Equatable {
  final String id;
  final String userName;
  final double rating;
  final String date;
  final String service;
  final String comment;
  final List<String> tags;

  const DoctorReviewEntity({
    required this.id,
    required this.userName,
    required this.rating,
    required this.date,
    this.service = 'General Consultation',
    required this.comment,
    this.tags = const [],
  });

  String get initials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'P';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [
    id,
    userName,
    rating,
    date,
    service,
    comment,
    tags,
  ];
}
