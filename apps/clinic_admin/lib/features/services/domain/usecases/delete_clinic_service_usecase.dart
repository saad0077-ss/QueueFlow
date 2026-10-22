import '../repositories/clinic_services_repository.dart';

class DeleteClinicServiceUseCase {
  final ClinicServicesRepository _repository;

  const DeleteClinicServiceUseCase(this._repository);

  Future<void> call(String serviceId) {
    return _repository.deleteService(serviceId);
  }
}
