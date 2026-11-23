import 'package:flutter_bloc/flutter_bloc.dart';
import 'clinic_queue_event.dart';
import 'clinic_queue_state.dart';

class ClinicQueueFilterHandler {
  static void onDrillDownService(
    QueueDrillDownService event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) {
    if (event.service == null) {
      emit(state.copyWith(clearDrillDown: true));
    } else {
      emit(
        state.copyWith(
          drillDownService: event.service,
          drillDownDepartment: event.department,
          serviceTab: 'active',
        ),
      );
    }
  }

  static void onResetFilters(
    QueueResetFilters event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) {
    emit(
      state.copyWith(
        departmentFilter: 'all',
        statusFilter: 'all',
        sortBy: 'default',
        searchQuery: '',
      ),
    );
  }

  static void onToggleDeptCollapsed(
    QueueToggleDeptCollapsed event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) {
    final next = Set<String>.from(state.collapsedDepts);
    if (next.contains(event.departmentId)) {
      next.remove(event.departmentId);
    } else {
      next.add(event.departmentId);
    }
    emit(state.copyWith(collapsedDepts: next));
  }

  static void onToggleAllDeptsCollapsed(
    QueueToggleAllDeptsCollapsed event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) {
    if (state.collapsedDepts.length == state.departments.length) {
      emit(state.copyWith(collapsedDepts: {}));
    } else {
      final allIds = state.departments.map((d) => d.id).toSet();
      emit(state.copyWith(collapsedDepts: allIds));
    }
  }

  static void onSelectPatient(
    QueueSelectPatient event,
    ClinicQueueState state,
    Emitter<ClinicQueueState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPatient: event.patient,
        clearSelectedPatient: event.patient == null,
      ),
    );
  }
}
