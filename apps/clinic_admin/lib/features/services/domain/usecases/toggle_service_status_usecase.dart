import '../repositories/clinic_services_repository.dart';

class ToggleServiceStatusUseCase {
  final ClinicServicesRepository _repository;

  const ToggleServiceStatusUseCase(this._repository);

  Future<void> call(String serviceId, String currentStatus) {
    return _repository.toggleServiceStatus(serviceId, currentStatus);
  }
}
