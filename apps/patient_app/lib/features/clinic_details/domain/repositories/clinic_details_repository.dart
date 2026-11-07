import '../../../home/domain/entities/clinic_entity.dart';
import '../entities/clinic_details_entity.dart';

abstract class ClinicDetailsRepository {
  Future<ClinicDetailsEntity> getClinicDetails(
    String clinicId,
    ClinicEntity? initialClinic,
  );

  Future<void> submitReview({
    required String clinicId,
    required int rating,
    required String comment,
    required List<String> tags,
  });

  /// One rating per patient per doctor; rating again updates the earlier one.
  Future<void> submitDoctorReview({
    required String clinicId,
    required String doctorId,
    required int rating,
    required String comment,
  });

  Future<void> markReviewHelpful(String reviewId);

  Future<bool> isClinicFavorite(String clinicId);

  /// Saves or removes the clinic from the signed-in patient's favorites.
  Future<void> setClinicFavorite(ClinicEntity clinic, bool favorite);
}
