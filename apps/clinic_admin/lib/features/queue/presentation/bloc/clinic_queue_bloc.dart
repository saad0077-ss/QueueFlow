import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../domain/repositories/clinic_queue_repository.dart';
import 'clinic_queue_actions_handler.dart';
import 'clinic_queue_event.dart';
import 'clinic_queue_filter_handler.dart';
import 'clinic_queue_state.dart';

class ClinicQueueBloc extends Bloc<ClinicQueueEvent, ClinicQueueState> {
  final ClinicQueueRepository _repository;
  final ClinicQueueActionsHandler _actionsHandler;

  StreamSubscription? _summarySub;
  StreamSubscription? _itemsSub;
  StreamSubscription? _servicesSub;

  ClinicQueueBloc({required ClinicQueueRepository repository})
    : _repository = repository,
      _actionsHandler = ClinicQueueActionsHandler(repository),
      super(const ClinicQueueState()) {
    on<QueueSubscriptionRequested>(_onSubscriptionRequested);
    on<QueueSummaryUpdated>((e, emit) => emit(state.copyWith(status: ClinicQueueStatus.success, summary: e.summary)));
    on<QueueItemsUpdated>(_onItemsUpdated);
    on<QueueCatalogUpdated>(_onCatalogUpdated);
    on<QueueCallNextPressed>((e, emit) => _actionsHandler.onCallNext(e, state, emit));
    on<QueueCallSpecificPressed>((e, emit) => _actionsHandler.onCallSpecific(e, state, emit));
    on<QueueCompletePressed>((e, emit) => _actionsHandler.onComplete(e, state, emit));
    on<QueueSkipPressed>((e, emit) => _actionsHandler.onSkip(e, state, emit));
    on<QueueRemovePressed>((e, emit) => _actionsHandler.onRemove(e, state, emit));
    on<QueueTogglePausePressed>((e, emit) => _actionsHandler.onTogglePause(e, state, emit));
    on<QueueToggleServiceClosedPressed>((e, emit) => _actionsHandler.onToggleServiceClosed(e, state, emit));
    on<QueueAddWalkInSubmitted>((e, emit) => _actionsHandler.onAddWalkIn(e, state, emit));
    on<QueueDrillDownService>((e, emit) => ClinicQueueFilterHandler.onDrillDownService(e, state, emit));
    on<QueueSearchChanged>((e, emit) => emit(state.copyWith(searchQuery: e.query)));
    on<QueueDeptFilterChanged>((e, emit) => emit(state.copyWith(departmentFilter: e.departmentId)));
    on<QueueStatusFilterChanged>((e, emit) => emit(state.copyWith(statusFilter: e.status)));
    on<QueueSortByChanged>((e, emit) => emit(state.copyWith(sortBy: e.sortBy)));
    on<QueueResetFilters>((e, emit) => ClinicQueueFilterHandler.onResetFilters(e, state, emit));
    on<QueueToggleDeptCollapsed>((e, emit) => ClinicQueueFilterHandler.onToggleDeptCollapsed(e, state, emit));
    on<QueueToggleAllDeptsCollapsed>((e, emit) => ClinicQueueFilterHandler.onToggleAllDeptsCollapsed(e, state, emit));
    on<QueueServiceTabChanged>((e, emit) => emit(state.copyWith(serviceTab: e.tab)));
    on<QueueSelectPatient>((e, emit) => ClinicQueueFilterHandler.onSelectPatient(e, state, emit));
    on<QueueClearFeedback>((e, emit) => emit(state.copyWith(clearToast: true)));
  }

  Future<void> _onSubscriptionRequested(
    QueueSubscriptionRequested event,
    Emitter<ClinicQueueState> emit,
  ) async {
    emit(state.copyWith(status: ClinicQueueStatus.loading));
    await _summarySub?.cancel();
    await _itemsSub?.cancel();
    await _servicesSub?.cancel();

    _summarySub = _repository.watchQueueSummary().listen(
      (summary) => add(QueueSummaryUpdated(summary)),
    );
    _itemsSub = _repository.watchQueueItems().listen(
      (items) => add(QueueItemsUpdated(items)),
    );

    try {
      final depts = await _repository.getDepartments();
      _servicesSub = _repository.watchServices().listen(
        (services) => add(QueueCatalogUpdated(departments: depts, services: services)),
      );
    } catch (_) {}
  }

  void _onItemsUpdated(QueueItemsUpdated event, Emitter<ClinicQueueState> emit) {
    final updatedSelected = state.selectedPatient == null
        ? null
        : event.items.cast().firstWhere(
            (i) => i.token == state.selectedPatient!.token,
            orElse: () => null,
          );

    emit(state.copyWith(
      status: ClinicQueueStatus.success,
      items: event.items,
      selectedPatient: updatedSelected,
    ));
  }

  void _onCatalogUpdated(QueueCatalogUpdated event, Emitter<ClinicQueueState> emit) {
    final Map<String, ServiceDepartmentEntity> uniqueDepts = {};
    for (final dept in event.departments) {
      final key = dept.name.trim().toLowerCase();
      uniqueDepts.putIfAbsent(key, () => dept);
    }

    final Map<String, ClinicServiceEntity> uniqueServices = {};
    for (final s in event.services) {
      final key = '${s.departmentName.trim().toLowerCase()}_${s.name.trim().toLowerCase()}';
      uniqueServices.putIfAbsent(key, () => s);
    }

    emit(state.copyWith(
      departments: uniqueDepts.values.toList(),
      services: uniqueServices.values.toList(),
    ));
  }

  @override
  Future<void> close() {
    _summarySub?.cancel();
    _itemsSub?.cancel();
    _servicesSub?.cancel();
    return super.close();
  }
}
