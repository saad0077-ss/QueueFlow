import '../entities/platform_user_entity.dart';

abstract class PlatformUsersRepository {
  Stream<List<PlatformUserEntity>> watchPlatformUsers();
  Future<void> deletePatientAccount(String userId, {String? email});
}
