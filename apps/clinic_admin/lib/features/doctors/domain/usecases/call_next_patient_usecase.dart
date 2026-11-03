import '../repositories/clinic_doctors_repository.dart';

class CallNextPatientUseCase {
  final ClinicDoctorsRepository _repository;

  CallNextPatientUseCase(this._repository);

  Future<String?> call(String doctorName) =>
      _repository.callNextPatient(doctorName);
}
