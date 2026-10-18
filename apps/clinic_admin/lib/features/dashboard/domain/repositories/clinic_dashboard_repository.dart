import '../entities/clinic_queue_entity.dart';

/// Contract interface for clinic dashboard and live queue operations.
abstract class ClinicDashboardRepository {
  /// Stream to watch real-time updates of the clinic queue.
  Stream<ClinicQueueEntity> watchQueue();

  /// Call the next patient in the queue.
  Future<void> callNextToken(int totalIssued);

  /// Issue a new walk-in token for an incoming outpatient.
  Future<void> issueWalkInToken(int totalIssued, int waitingCount);

  /// Toggle pause/resume on the live queue.
  Future<void> togglePauseQueue(bool isPaused);
}
