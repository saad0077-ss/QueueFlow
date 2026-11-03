import '../repositories/clinic_doctors_repository.dart';

class DeleteClinicDoctorUseCase {
  final ClinicDoctorsRepository _repository;

  DeleteClinicDoctorUseCase(this._repository);

  Future<void> call(String doctorId) => _repository.deleteDoctor(doctorId);
}
