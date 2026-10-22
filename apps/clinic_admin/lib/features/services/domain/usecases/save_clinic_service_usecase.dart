import '../entities/clinic_service_entity.dart';
import '../repositories/clinic_services_repository.dart';

class SaveClinicServiceUseCase {
  final ClinicServicesRepository _repository;

  const SaveClinicServiceUseCase(this._repository);

  Future<void> call(ClinicServiceEntity service) {
    return _repository.saveService(service);
  }
}
