import '../../../domain/entities/clinic_queue_item_entity.dart';

class ServiceQueueDisplayListResolver {
  static List<ClinicQueueItemEntity> resolve({
    required String activeTab,
    required List<ClinicQueueItemEntity> sQueue,
    required List<ClinicQueueItemEntity> sWaiting,
    required ClinicQueueItemEntity? sServing,
    required List<ClinicQueueItemEntity> sCompleted,
    required List<ClinicQueueItemEntity> sSkipped,
  }) {
    switch (activeTab) {
      case 'waiting':
        return sWaiting;
      case 'called':
        return sServing != null ? [sServing] : [];
      case 'completed':
        return [...sCompleted, ...sSkipped];
      case 'all':
        return sQueue;
      case 'active':
      default:
        return [?sServing, ...sWaiting];
    }
  }
}
