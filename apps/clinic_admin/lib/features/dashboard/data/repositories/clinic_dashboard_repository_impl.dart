import 'dart:async';
import '../../../queue/data/repositories/clinic_queue_repository_impl.dart';
import '../../../queue/domain/entities/clinic_queue_item_entity.dart';
import '../../../queue/domain/entities/clinic_queue_summary_entity.dart';
import '../../../queue/domain/repositories/clinic_queue_repository.dart';
import '../../domain/entities/clinic_queue_entity.dart';
import '../../domain/repositories/clinic_dashboard_repository.dart';

/// Dashboard queue repository backed by the same live-queue source as the
/// Live Queue tab, so both screens always show identical data.
class ClinicDashboardRepositoryImpl implements ClinicDashboardRepository {
  final ClinicQueueRepository _queue;

  ClinicDashboardRepositoryImpl({ClinicQueueRepository? queueRepository})
    : _queue = queueRepository ?? ClinicQueueRepositoryImpl();

  @override
  Stream<ClinicQueueEntity> watchQueue() {
    late StreamController<ClinicQueueEntity> controller;
    StreamSubscription<List<ClinicQueueItemEntity>>? itemsSub;
    StreamSubscription<ClinicQueueSummaryEntity>? summarySub;
    var items = <ClinicQueueItemEntity>[];
    var paused = false;

    void emit() {
      final called = items.where((i) => i.isCalled).toList();
      controller.add(
        ClinicQueueEntity(
          currentToken: called.isEmpty ? '---' : called.first.token,
          totalIssued: items.length,
          waitingCount: items.where((i) => i.isWaiting).length,
          status: paused ? 'paused' : 'open',
          isPaused: paused,
        ),
      );
    }

    controller = StreamController<ClinicQueueEntity>(
      onListen: () {
        itemsSub = _queue.watchQueueItems().listen((v) {
          items = v;
          emit();
        }, onError: controller.addError);
        summarySub = _queue.watchQueueSummary().listen((v) {
          paused = v.isPaused;
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await itemsSub?.cancel();
        await summarySub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> callNextToken(int totalIssued) => _queue.callNextToken();

  @override
  Future<void> issueWalkInToken(int totalIssued, int waitingCount) =>
      _queue.addWalkInPatient(
        name: 'Walk-In Patient',
        phone: '',
        service: 'General Consultation',
      );

  @override
  Future<void> togglePauseQueue(bool isPaused) =>
      _queue.togglePauseQueue(isPaused);
}
