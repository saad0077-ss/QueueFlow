import '../entities/clinic_staff_entity.dart';
import '../repositories/clinic_auth_repository.dart';

class ClinicSignInUseCase {
  final ClinicAuthRepository repository;

  const ClinicSignInUseCase(this.repository);

  Future<ClinicStaffEntity> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(email: email, password: password);
  }
}
