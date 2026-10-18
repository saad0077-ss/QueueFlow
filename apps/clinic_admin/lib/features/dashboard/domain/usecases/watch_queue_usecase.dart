import '../entities/clinic_queue_entity.dart';
import '../repositories/clinic_dashboard_repository.dart';

/// Use case to watch live queue changes from Firestore.
class WatchQueueUseCase {
  final ClinicDashboardRepository repository;

  const WatchQueueUseCase(this.repository);

  Stream<ClinicQueueEntity> call() => repository.watchQueue();
}
