import '../repositories/clinic_auth_repository.dart';

class ResetClinicPasswordUseCase {
  final ClinicAuthRepository repository;

  const ResetClinicPasswordUseCase(this.repository);

  Future<void> call(String email) {
    return repository.sendPasswordReset(email);
  }
}
