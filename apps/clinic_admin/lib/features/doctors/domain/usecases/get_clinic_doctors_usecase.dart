import '../entities/clinic_doctor_profile_entity.dart';
import '../repositories/clinic_doctors_repository.dart';

class GetClinicDoctorsUseCase {
  final ClinicDoctorsRepository _repository;

  GetClinicDoctorsUseCase(this._repository);

  Stream<List<ClinicDoctorProfileEntity>> call() => _repository.watchDoctors();
}
