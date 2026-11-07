import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/clinic_entity.dart';

abstract class ClinicDetailsEvent extends Equatable {
  const ClinicDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadClinicDetails extends ClinicDetailsEvent {
  final String clinicId;
  final ClinicEntity? initialClinic;

  const LoadClinicDetails({
    required this.clinicId,
    this.initialClinic,
  });

  @override
  List<Object?> get props => [clinicId, initialClinic];
}

class SelectClinicTab extends ClinicDetailsEvent {
  final int tabIndex;

  const SelectClinicTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class ToggleClinicFavorite extends ClinicDetailsEvent {
  const ToggleClinicFavorite();
}

class MarkReviewHelpfulEvent extends ClinicDetailsEvent {
  final String reviewId;

  const MarkReviewHelpfulEvent(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

class SubmitDoctorReviewEvent extends ClinicDetailsEvent {
  final String doctorId;
  final int rating;
  final String comment;

  const SubmitDoctorReviewEvent({
    required this.doctorId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [doctorId, rating, comment];
}

class SubmitClinicReviewEvent extends ClinicDetailsEvent {
  final int rating;
  final String comment;
  final List<String> tags;

  const SubmitClinicReviewEvent({
    required this.rating,
    required this.comment,
    required this.tags,
  });

  @override
  List<Object?> get props => [rating, comment, tags];
}
