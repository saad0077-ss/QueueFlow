import '../entities/favorite_clinic_entity.dart';
import '../entities/patient_payment_item_entity.dart';
import '../entities/patient_profile_entity.dart';
import '../entities/patient_queue_history_entity.dart';
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

  Future<void> toggleFavorite(String clinicId, {required bool isFavorite});

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

  Stream<List<SupportTicketEntity>> watchSupportTickets();

  Future<SupportTicketEntity> createSupportTicket({
    required String clinicId,
    required String clinicName,
    required String category,
    required String subject,
    required String description,
    String priority = 'medium',
    String? linkedTokenNumber,
    bool isClinicRelated = true,
  });

  Future<SupportTicketEntity> sendTicketReply({
    required String ticketId,
    required String text,
    required String senderName,
    String senderRole = 'patient',
  });

  Future<void> updateTicketStatus(String ticketId, String status);

  Future<void> rateTicket(String ticketId, int rating);

  Future<List<PatientQueueHistoryEntity>> getQueueHistory();

  Stream<List<PatientQueueHistoryEntity>> watchQueueHistory();

  Future<List<PatientPaymentItemEntity>> getPaymentHistory();

  Future<void> logout();

  Future<void> deleteAccount();
}
