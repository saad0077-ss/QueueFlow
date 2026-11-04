import '../entities/favorite_clinic_entity.dart';
import '../entities/patient_profile_entity.dart';
import '../entities/patient_review_entity.dart';
import '../entities/support_ticket_entity.dart';

abstract class ProfileRepository {
  Future<PatientProfileEntity> getProfile();
  
  Future<PatientProfileEntity> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String initials,
    int? age,
    String? gender,
    String? bloodGroup,
    String? photoBase64,
  });

  Future<PatientProfileEntity> toggleDarkMode(bool enabled);

  Future<List<FavoriteClinicEntity>> getFavoriteClinics();

  Future<List<PatientReviewEntity>> getUserReviews();

  Future<PatientReviewEntity> addReview({
    required String clinicId,
    required String clinicName,
    required String doctorName,
    required int rating,
    required List<String> tags,
    required String comment,
    required bool isAnonymous,
  });

  Future<void> deleteReview(String reviewId);

  Future<List<SupportTicketEntity>> getSupportTickets();

  Future<SupportTicketEntity> createSupportTicket({
    required String clinicId,
    required String clinicName,
    required String category,
    required String subject,
    required String description,
  });

  Future<SupportTicketEntity> sendTicketReply({
    required String ticketId,
    required String text,
    required String senderName,
  });

  Future<void> logout();

  Future<void> deleteAccount();
}
