import 'package:flutter/material.dart';
import '../../domain/repositories/clinic_queue_repository.dart';
import '../bloc/clinic_queue_bloc.dart';
import '../bloc/clinic_queue_event.dart';
import '../bloc/clinic_queue_state.dart';
import 'add_walk_in_patient_modal.dart';
import 'queue_filter_modal.dart';

class ClinicLiveQueueModalHelper {
  static void openAddWalkIn(
    BuildContext context,
    ClinicQueueRepository repository,
    ClinicQueueBloc bloc, [
    String? svc,
  ]) async {
    final services = await repository.watchServices().first;
    final departments = await repository.getDepartments();
    if (!context.mounted) return;
    AddWalkInPatientModal.show(
      context,
      departments: departments,
      services: services,
      preselectedService: svc,
      onAdd: ({required name, required phone, required service, required department, email, note}) {
        bloc.add(QueueAddWalkInSubmitted(
          name: name,
          phone: phone,
          service: service.isNotEmpty ? service : (svc ?? ''),
          department: department,
          email: email,
          note: note,
        ));
      },
    );
  }

  static void openFilters(
    BuildContext context,
    ClinicQueueBloc bloc,
    ClinicQueueState state,
  ) {
    final subs = <String, String>{'all': '${state.departments.length} total'};
    for (final d in state.departments) {
      final svcs = state.servicesForDepartment(d.id, d.name);
      final wait = state.items.where((q) => q.isWaiting && svcs.any((s) => s.name.trim().toLowerCase() == q.serviceName.trim().toLowerCase())).length;
      subs[d.id] = '${svcs.length} svcs · $wait waiting';
    }
    QueueFilterModal.show(
      context,
      deptSubtitles: subs,
      departments: state.departments,
      currentDepartment: state.departmentFilter,
      currentStatus: state.statusFilter,
      currentSort: state.sortBy,
      onApply: ({required department, required status, required sort}) {
        bloc.add(QueueDeptFilterChanged(department));
        bloc.add(QueueStatusFilterChanged(status));
        bloc.add(QueueSortByChanged(sort));
      },
      onReset: () => bloc.add(const QueueResetFilters()),
    );
  }
}
