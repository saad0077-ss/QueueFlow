import '../entities/clinic_service_entity.dart';
import '../repositories/clinic_services_repository.dart';

class GetClinicServicesUseCase {
  final ClinicServicesRepository _repository;

  const GetClinicServicesUseCase(this._repository);

  Stream<List<ClinicServiceEntity>> call() {
    return _repository.watchServices();
  }
}
