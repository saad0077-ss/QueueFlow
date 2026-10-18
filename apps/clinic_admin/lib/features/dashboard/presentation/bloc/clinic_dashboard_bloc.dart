import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/call_next_token_usecase.dart';
import '../../domain/usecases/issue_walk_in_token_usecase.dart';
import '../../domain/usecases/toggle_pause_queue_usecase.dart';
import '../../domain/usecases/watch_queue_usecase.dart';
import 'clinic_dashboard_event.dart';
import 'clinic_dashboard_state.dart';

/// Pure BLoC managing live queue state, sidebar navigation, and outpatient caller actions.
class ClinicDashboardBloc
    extends Bloc<ClinicDashboardEvent, ClinicDashboardState> {
  final WatchQueueUseCase _watchQueueUseCase;
  final CallNextTokenUseCase _callNextTokenUseCase;
  final IssueWalkInTokenUseCase _issueWalkInTokenUseCase;
  final TogglePauseQueueUseCase _togglePauseQueueUseCase;

  StreamSubscription? _queueSubscription;

  ClinicDashboardBloc({
    required WatchQueueUseCase watchQueueUseCase,
    required CallNextTokenUseCase callNextTokenUseCase,
    required IssueWalkInTokenUseCase issueWalkInTokenUseCase,
    required TogglePauseQueueUseCase togglePauseQueueUseCase,
  })  : _watchQueueUseCase = watchQueueUseCase,
        _callNextTokenUseCase = callNextTokenUseCase,
        _issueWalkInTokenUseCase = issueWalkInTokenUseCase,
        _togglePauseQueueUseCase = togglePauseQueueUseCase,
        super(const ClinicDashboardState()) {
    on<DashboardSubscriptionRequested>(_onSubscriptionRequested);
    on<DashboardQueueUpdated>(_onQueueUpdated);
    on<DashboardCallNextPressed>(_onCallNextPressed);
    on<DashboardIssueWalkInPressed>(_onIssueWalkInPressed);
    on<DashboardTogglePausePressed>(_onTogglePausePressed);
    on<DashboardNavTabChanged>(_onNavTabChanged);
    on<DashboardSearchQueryChanged>(_onSearchQueryChanged);
    on<DashboardClearFeedback>(_onClearFeedback);
  }

  Future<void> _onSubscriptionRequested(
    DashboardSubscriptionRequested event,
    Emitter<ClinicDashboardState> emit,
  ) async {
    emit(state.copyWith(status: ClinicDashboardStatus.loading));
    await _queueSubscription?.cancel();
    _queueSubscription = _watchQueueUseCase().listen(
      (queue) => add(DashboardQueueUpdated(queue)),
    );
  }

  void _onQueueUpdated(
    DashboardQueueUpdated event,
    Emitter<ClinicDashboardState> emit,
  ) {
    emit(state.copyWith(
      status: ClinicDashboardStatus.success,
      queue: event.queue,
    ));
  }

  Future<void> _onCallNextPressed(
    DashboardCallNextPressed event,
    Emitter<ClinicDashboardState> emit,
  ) async {
    try {
      await _callNextTokenUseCase(state.queue.totalIssued);
      emit(state.copyWith(
        toastMessage: 'Next patient called successfully.',
        isErrorToast: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Error calling next: $e',
        isErrorToast: true,
      ));
    }
  }

  Future<void> _onIssueWalkInPressed(
    DashboardIssueWalkInPressed event,
    Emitter<ClinicDashboardState> emit,
  ) async {
    try {
      await _issueWalkInTokenUseCase(
        state.queue.totalIssued,
        state.queue.waitingCount,
      );
      emit(state.copyWith(
        toastMessage: 'Walk-in patient token issued.',
        isErrorToast: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Error issuing walk-in: $e',
        isErrorToast: true,
      ));
    }
  }

  Future<void> _onTogglePausePressed(
    DashboardTogglePausePressed event,
    Emitter<ClinicDashboardState> emit,
  ) async {
    final nextPaused = !state.queue.isPaused;
    try {
      await _togglePauseQueueUseCase(state.queue.isPaused);
      emit(state.copyWith(
        toastMessage:
            nextPaused ? 'Live queue is paused.' : 'Live queue resumed.',
        isErrorToast: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Error toggling queue: $e',
        isErrorToast: true,
      ));
    }
  }

  void _onNavTabChanged(
    DashboardNavTabChanged event,
    Emitter<ClinicDashboardState> emit,
  ) {
    emit(state.copyWith(activeNav: event.activeTab));
  }

  void _onSearchQueryChanged(
    DashboardSearchQueryChanged event,
    Emitter<ClinicDashboardState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onClearFeedback(
    DashboardClearFeedback event,
    Emitter<ClinicDashboardState> emit,
  ) {
    emit(state.copyWith(clearToast: true));
  }

  @override
  Future<void> close() {
    _queueSubscription?.cancel();
    return super.close();
  }
}
