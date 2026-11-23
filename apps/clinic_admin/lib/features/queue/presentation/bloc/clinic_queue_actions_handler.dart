import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/clinic_queue_repository.dart';
import 'clinic_queue_event.dart';
import 'clinic_queue_state.dart';

class ClinicQueueActionsHandler {
  final ClinicQueueRepository repository;

  const ClinicQueueActionsHandler(this.repository);

  Future<void> onCallNext(
    QueueCallNextPressed event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) async {
    try {
      await repository.callNextToken(event.serviceName);
      final label = event.serviceName != null
          ? 'Next patient called for ${event.serviceName}.'
          : 'Next patient called to counter.';
      emit(
        state.copyWith(
          toastMessage: label,
          isErrorToast: false,
          clearSelectedPatient: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Could not call next patient: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  Future<void> onCallSpecific(
    QueueCallSpecificPressed event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) async {
    try {
      await repository.callSpecificToken(event.token);
      emit(
        state.copyWith(
          toastMessage: 'Called ${event.token} to counter.',
          isErrorToast: false,
          clearSelectedPatient: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Could not call ${event.token}: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  Future<void> onComplete(
    QueueCompletePressed event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) async {
    try {
      await repository.completeToken(event.token);
      emit(
        state.copyWith(
          toastMessage: 'Marked ${event.token} as completed.',
          isErrorToast: false,
          clearSelectedPatient: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Could not complete ${event.token}: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  Future<void> onSkip(
    QueueSkipPressed event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) async {
    try {
      await repository.skipToken(event.token);
      emit(
        state.copyWith(
          toastMessage: 'Moved ${event.token} to back of queue.',
          isErrorToast: false,
          clearSelectedPatient: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Could not skip ${event.token}: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  Future<void> onRemove(
    QueueRemovePressed event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) async {
    try {
      await repository.removeToken(event.token);
      emit(
        state.copyWith(
          toastMessage: 'Removed ${event.token} from live queue.',
          isErrorToast: false,
          clearSelectedPatient: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Could not remove ${event.token}: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  Future<void> onToggleServiceClosed(
    QueueToggleServiceClosedPressed event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) async {
    final close = !state.summary.isServiceClosedToday(event.service);
    try {
      await repository.setServiceClosedToday(event.service, close);
      emit(
        state.copyWith(
          toastMessage: close
              ? '${event.service} queue closed for today.'
              : '${event.service} queue reopened.',
          isErrorToast: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Could not update queue: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  Future<void> onTogglePause(
    QueueTogglePausePressed event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) async {
    final nextPaused = !state.summary.isPaused;
    try {
      await repository.togglePauseQueue(nextPaused);
      emit(
        state.copyWith(
          toastMessage: nextPaused
              ? 'Live queue paused.'
              : 'Live queue opened for walk-ins.',
          isErrorToast: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Could not toggle queue: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  Future<void> onAddWalkIn(
    QueueAddWalkInSubmitted event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) async {
    try {
      final item = await repository.addWalkInPatient(
        name: event.name,
        phone: event.phone,
        service: event.service,
        doctor: event.doctor,
        note: event.note,
        email: event.email,
        department: event.department,
      );
      emit(
        state.copyWith(
          toastMessage:
              'Walk-in added: Token ${item.token} issued for ${item.patientName}!',
          isErrorToast: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Could not add walk-in: $e',
          isErrorToast: true,
        ),
      );
    }
  }
}
