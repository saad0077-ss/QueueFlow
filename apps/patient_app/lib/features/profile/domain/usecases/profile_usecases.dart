import '../entities/favorite_clinic_entity.dart';
import '../entities/patient_profile_entity.dart';
import '../entities/patient_review_entity.dart';
import '../entities/support_ticket_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<PatientProfileEntity> call() => repository.getProfile();
}

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<PatientProfileEntity> call({
    required String name,
    required String email,
    required String phone,
    required String initials,
    int? age,
    String? gender,
    String? bloodGroup,
    String? photoBase64,
  }) {
    return repository.updateProfile(
      name: name,
      email: email,
      phone: phone,
      initials: initials,
      age: age,
      gender: gender,
      bloodGroup: bloodGroup,
      photoBase64: photoBase64,
    );
  }
}

class ToggleDarkModeUseCase {
  final ProfileRepository repository;
  ToggleDarkModeUseCase(this.repository);

  Future<PatientProfileEntity> call(bool enabled) => repository.toggleDarkMode(enabled);
}

class GetFavoriteClinicsUseCase {
  final ProfileRepository repository;
  GetFavoriteClinicsUseCase(this.repository);

  Future<List<FavoriteClinicEntity>> call() => repository.getFavoriteClinics();
}

class GetUserReviewsUseCase {
  final ProfileRepository repository;
  GetUserReviewsUseCase(this.repository);

  Future<List<PatientReviewEntity>> call() => repository.getUserReviews();
}

class AddReviewUseCase {
  final ProfileRepository repository;
  AddReviewUseCase(this.repository);

  Future<PatientReviewEntity> call({
    required String clinicId,
    required String clinicName,
    required String doctorName,
    required int rating,
    required List<String> tags,
    required String comment,
    required bool isAnonymous,
  }) {
    return repository.addReview(
      clinicId: clinicId,
      clinicName: clinicName,
      doctorName: doctorName,
      rating: rating,
      tags: tags,
      comment: comment,
      isAnonymous: isAnonymous,
    );
  }
}

class DeleteReviewUseCase {
  final ProfileRepository repository;
  DeleteReviewUseCase(this.repository);

  Future<void> call(String reviewId) => repository.deleteReview(reviewId);
}

class GetSupportTicketsUseCase {
  final ProfileRepository repository;
  GetSupportTicketsUseCase(this.repository);

  Future<List<SupportTicketEntity>> call() => repository.getSupportTickets();
}

class CreateSupportTicketUseCase {
  final ProfileRepository repository;
  CreateSupportTicketUseCase(this.repository);

  Future<SupportTicketEntity> call({
    required String clinicId,
    required String clinicName,
    required String category,
    required String subject,
    required String description,
  }) {
    return repository.createSupportTicket(
      clinicId: clinicId,
      clinicName: clinicName,
      category: category,
      subject: subject,
      description: description,
    );
  }
}

class SendTicketReplyUseCase {
  final ProfileRepository repository;
  SendTicketReplyUseCase(this.repository);

  Future<SupportTicketEntity> call({
    required String ticketId,
    required String text,
    required String senderName,
  }) {
    return repository.sendTicketReply(
      ticketId: ticketId,
      text: text,
      senderName: senderName,
    );
  }
}

class LogoutUseCase {
  final ProfileRepository repository;
  LogoutUseCase(this.repository);

  Future<void> call() => repository.logout();
}

class DeleteAccountUseCase {
  final ProfileRepository repository;
  DeleteAccountUseCase(this.repository);

  Future<void> call() => repository.deleteAccount();
}
