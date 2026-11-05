import '../entities/clinic_doctor_profile_entity.dart';
import '../repositories/clinic_doctors_repository.dart';

class SaveClinicDoctorUseCase {
  final ClinicDoctorsRepository _repository;

  SaveClinicDoctorUseCase(this._repository);

  Future<void> call(ClinicDoctorProfileEntity doctor) => _repository.addDoctor(doctor);
}
