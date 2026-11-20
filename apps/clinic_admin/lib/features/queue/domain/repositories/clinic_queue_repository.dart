import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../entities/clinic_queue_item_entity.dart';
import '../entities/clinic_queue_summary_entity.dart';

abstract class ClinicQueueRepository {
  /// Watches aggregate live queue summary (now serving, waiting count, avg wait, pause status).
  Stream<ClinicQueueSummaryEntity> watchQueueSummary();

  /// Watches the list of live queue items.
  Stream<List<ClinicQueueItemEntity>> watchQueueItems();

  /// Gets the clinic's departments catalog.
  Future<List<ServiceDepartmentEntity>> getDepartments();

  /// Watches the clinic's active clinical services.
  Stream<List<ClinicServiceEntity>> watchServices();

  /// Calls the next waiting patient in line across all services or for a specific service.
  Future<void> callNextToken([String? serviceName]);

  /// Calls a specific token to the consultation counter.
  Future<void> callSpecificToken(String token);

  /// Marks a token consultation as complete.
  Future<void> completeToken(String token);

  /// Skips a token to the back of the queue.
  Future<void> skipToken(String token);

  /// Removes a token from the queue.
  Future<void> removeToken(String token);

  /// Toggles whether the queue is open or paused for walk-ins.
  Future<void> togglePauseQueue(bool isPaused);

  /// Closes (or reopens) a single service's queue for today.
  Future<void> setServiceClosedToday(String service, bool closed);

  /// Issues a new walk-in patient token.
  Future<ClinicQueueItemEntity> addWalkInPatient({
    required String name,
    required String phone,
    required String service,
    String? doctor,
    String? note,
    String? email,
    String? department,
  });

  /// Loads available services for walk-in selection.
  Future<List<String>> getAvailableServices();

  /// Loads available doctors for walk-in selection.
  Future<List<String>> getAvailableDoctors();
}
