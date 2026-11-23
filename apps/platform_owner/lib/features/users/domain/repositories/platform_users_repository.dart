import '../entities/platform_user_entity.dart';

abstract class PlatformUsersRepository {
  Stream<List<PlatformUserEntity>> watchPlatformUsers();
  Future<void> deletePatientAccount(String userId, {String? email});
  Future<void> setUserStatus(String userId, String status);
  Future<void> registerPatient({
    required String name,
    required String phone,
    required String email,
    String? age,
    String? gender,
    String? bloodGroup,
    String? clinicId,
    String? clinicName,
    String? emergencyContact,
    String? notes,
  });
  Future<void> sendNotification({
    required String targetUserId,
    required String title,
    required String message,
    String? targetEmail,
    String? type,
  });
  Future<List<Map<String, String>>> getActiveClinics();
}
