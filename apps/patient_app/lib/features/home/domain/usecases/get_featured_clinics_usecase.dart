import '../entities/clinic_entity.dart';
import '../repositories/home_repository.dart';

class GetFeaturedClinicsUseCase {
  final HomeRepository repository;

  GetFeaturedClinicsUseCase(this.repository);

  Future<List<ClinicEntity>> call() => repository.getFeaturedClinics();
}
