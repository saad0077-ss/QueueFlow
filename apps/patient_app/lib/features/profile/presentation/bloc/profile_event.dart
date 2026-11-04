import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdated extends ProfileEvent {
  final String name;
  final String email;
  final String phone;
  final String initials;
  final int? age;
  final String? gender;
  final String? bloodGroup;
  final String? photoBase64;

  const ProfileUpdated({
    required this.name,
    required this.email,
    required this.phone,
    required this.initials,
    this.age,
    this.gender,
    this.bloodGroup,
    this.photoBase64,
  });

  @override
  List<Object?> get props => [name, email, phone, initials, age, gender, bloodGroup, photoBase64];
}

class ProfileDarkModeToggled extends ProfileEvent {
  final bool enabled;

  const ProfileDarkModeToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ProfileReviewSubmitted extends ProfileEvent {
  final String clinicId;
  final String clinicName;
  final String doctorName;
  final int rating;
  final List<String> tags;
  final String comment;
  final bool isAnonymous;

  const ProfileReviewSubmitted({
    required this.clinicId,
    required this.clinicName,
    required this.doctorName,
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
        rating,
        tags,
        comment,
        isAnonymous,
      ];
}

class ProfileReviewDeleted extends ProfileEvent {
  final String reviewId;

  const ProfileReviewDeleted(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

class ProfileSupportTicketCreated extends ProfileEvent {
  final String clinicId;
  final String clinicName;
  final String category;
  final String subject;
  final String description;

  const ProfileSupportTicketCreated({
    required this.clinicId,
    required this.clinicName,
    required this.category,
    required this.subject,
    required this.description,
  });

  @override
  List<Object?> get props => [
        clinicId,
        clinicName,
        category,
        subject,
        description,
      ];
}

class ProfileTicketReplySent extends ProfileEvent {
  final String ticketId;
  final String text;

  const ProfileTicketReplySent({
    required this.ticketId,
    required this.text,
  });

  @override
  List<Object?> get props => [ticketId, text];
}

class ProfileActiveTicketChanged extends ProfileEvent {
  final String ticketId;

  const ProfileActiveTicketChanged(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class ProfileLogoutRequested extends ProfileEvent {
  const ProfileLogoutRequested();
}

class ProfileDeleteAccountRequested extends ProfileEvent {
  const ProfileDeleteAccountRequested();
}
