import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<UserEntity> signInWithGoogle();

  UserEntity? getCurrentUser();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}
