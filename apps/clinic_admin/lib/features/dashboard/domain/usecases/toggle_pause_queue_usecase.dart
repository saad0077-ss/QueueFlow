import '../repositories/clinic_dashboard_repository.dart';

/// Use case to toggle pause and resume status of the live queue.
class TogglePauseQueueUseCase {
  final ClinicDashboardRepository repository;

  const TogglePauseQueueUseCase(this.repository);

  Future<void> call(bool isCurrentlyPaused) {
    return repository.togglePauseQueue(!isCurrentlyPaused);
  }
}
