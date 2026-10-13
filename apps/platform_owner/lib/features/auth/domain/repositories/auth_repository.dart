import '../entities/admin_entity.dart';

abstract class AuthRepository {
  Future<AdminEntity> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<AdminEntity?> get authStateChanges;
}
