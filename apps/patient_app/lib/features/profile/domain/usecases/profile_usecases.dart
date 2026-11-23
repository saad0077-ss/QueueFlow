import '../entities/favorite_clinic_entity.dart';
import '../entities/patient_payment_item_entity.dart';
import '../entities/patient_profile_entity.dart';
import '../entities/patient_queue_history_entity.dart';
import '../entities/patient_review_entity.dart';
import '../repositories/profile_repository.dart';
export 'ticket_usecases.dart';

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

  Future<PatientProfileEntity> call(bool enabled) =>
      repository.toggleDarkMode(enabled);
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

class GetQueueHistoryUseCase {
  final ProfileRepository repository;
  GetQueueHistoryUseCase(this.repository);

  Future<List<PatientQueueHistoryEntity>> call() =>
      repository.getQueueHistory();
}

class WatchQueueHistoryUseCase {
  final ProfileRepository repository;
  WatchQueueHistoryUseCase(this.repository);

  Stream<List<PatientQueueHistoryEntity>> call() =>
      repository.watchQueueHistory();
}

class GetPaymentHistoryUseCase {
  final ProfileRepository repository;
  GetPaymentHistoryUseCase(this.repository);

  Future<List<PatientPaymentItemEntity>> call() =>
      repository.getPaymentHistory();
}
