import '../repositories/clinic_doctors_repository.dart';

class UpdateDoctorStatusUseCase {
  final ClinicDoctorsRepository _repository;

  UpdateDoctorStatusUseCase(this._repository);

  Future<void> call(String doctorId, String status) =>
      _repository.updateDoctorStatus(doctorId, status);
}
