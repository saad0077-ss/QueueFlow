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

  Future<void> markReviewHelpful(String reviewId);

  Future<bool> toggleFavoriteClinic(String clinicId);
}
