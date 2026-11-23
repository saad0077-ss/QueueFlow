import 'package:equatable/equatable.dart';

abstract class MyReviewsEvent extends Equatable {
  const MyReviewsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMyReviewsEvent extends MyReviewsEvent {
  const LoadMyReviewsEvent();
}

class SetMyReviewsFilterEvent extends MyReviewsEvent {
  final String filter;
  const SetMyReviewsFilterEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}

class DeleteMyReviewEvent extends MyReviewsEvent {
  final String id;
  const DeleteMyReviewEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class AddMyReviewEvent extends MyReviewsEvent {
  final String clinicId;
  final String clinicName;
  final String doctorName;
  final String service;
  final int rating;
  final List<String> tags;
  final String comment;
  final bool isAnonymous;

  const AddMyReviewEvent({
    required this.clinicId,
    required this.clinicName,
    required this.doctorName,
    required this.service,
    required this.rating,
    required this.tags,
    required this.comment,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [
    clinicId,
    clinicName,
    doctorName,
    service,
    rating,
    tags,
    comment,
    isAnonymous,
  ];
}
