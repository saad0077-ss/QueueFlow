import '../entities/clinic_staff_entity.dart';
import '../repositories/clinic_auth_repository.dart';

class ActivateClinicAccountUseCase {
  final ClinicAuthRepository repository;

  const ActivateClinicAccountUseCase(this.repository);

  Future<ClinicStaffEntity> call({
    required String email,
    required String password,
    required String doctorName,
    required String role,
    required String clinicName,
  }) {
    return repository.activateAccount(
      email: email,
      password: password,
      doctorName: doctorName,
      role: role,
      clinicName: clinicName,
    );
  }
}
