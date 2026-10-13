import '../entities/admin_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  const SignInUseCase(this.repository);

  Future<AdminEntity> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(email: email, password: password);
  }
}
