import '../../../services/domain/entities/service_department_entity.dart';
import '../bloc/clinic_queue_state.dart';

class ClinicLiveQueueFilterHelper {
  static String? computeActiveFilterLabel(ClinicQueueState state) {
    if (state.activeFiltersCount == 0) return null;
    final labels = <String>[];
    if (state.departmentFilter != 'all') {
      final d = state.departments.where((dept) => dept.id == state.departmentFilter).firstOrNull;
      if (d != null) labels.add(d.name);
    }
    if (state.statusFilter != 'all') {
      labels.add(
        state.statusFilter == 'waiting'
            ? 'Has Waiting'
            : (state.statusFilter == 'active' ? 'Active Now' : 'All Clear'),
      );
    }
    if (state.sortBy != 'default') {
      labels.add(
        state.sortBy == 'waiting'
            ? 'Most Waiting'
            : (state.sortBy == 'name' ? 'A–Z' : 'Most Services'),
      );
    }
    return labels.join(' • ');
  }

  static List<ServiceDepartmentEntity> filterAndSort({
    required ClinicQueueState state,
  }) {
    final query = state.searchQuery.trim().toLowerCase();
    final seenDeptNames = <String>{};

    var depts = state.departments.where((dept) {
      final deptKey = dept.name.trim().toLowerCase();
      if (seenDeptNames.contains(deptKey)) return false;
      seenDeptNames.add(deptKey);

      if (state.departmentFilter != 'all' && dept.id != state.departmentFilter) {
        return false;
      }
      final svcs = state.servicesForDepartment(dept.id, dept.name);
      final dQueue = state.items.where((q) {
        return svcs.any(
          (s) => s.name.trim().toLowerCase() == q.serviceName.trim().toLowerCase(),
        );
      }).toList();
      final dWaiting = dQueue.where((q) => q.isWaiting).toList();
      final dServing = dQueue.where((q) => q.isCalled).toList();

      if (state.statusFilter == 'waiting') {
        if (dWaiting.isEmpty) return false;
      } else if (state.statusFilter == 'active') {
        if (dWaiting.isEmpty && dServing.isEmpty) return false;
      } else if (state.statusFilter == 'idle') {
        if (dWaiting.isNotEmpty || dServing.isNotEmpty) return false;
      }

      if (query.isNotEmpty) {
        final nameMatch = dept.name.toLowerCase().contains(query);
        final codeMatch = dept.code.toLowerCase().contains(query);
        final svcMatch = svcs.any((s) => s.name.toLowerCase().contains(query));
        final tokenMatch = dQueue.any(
          (q) =>
              q.token.toLowerCase().contains(query) ||
              q.patientName.toLowerCase().contains(query),
        );
        if (!nameMatch && !codeMatch && !svcMatch && !tokenMatch) {
          return false;
        }
      }
      return true;
    }).toList();

    if (state.sortBy == 'waiting') {
      depts.sort((a, b) {
        final aWait = state.items
            .where(
              (q) =>
                  q.isWaiting &&
                  state
                      .servicesForDepartment(a.id, a.name)
                      .any(
                        (s) =>
                            s.name.trim().toLowerCase() ==
                            q.serviceName.trim().toLowerCase(),
                      ),
            )
            .length;
        final bWait = state.items
            .where(
              (q) =>
                  q.isWaiting &&
                  state
                      .servicesForDepartment(b.id, b.name)
                      .any(
                        (s) =>
                            s.name.trim().toLowerCase() ==
                            q.serviceName.trim().toLowerCase(),
                      ),
            )
            .length;
        return bWait.compareTo(aWait);
      });
    } else if (state.sortBy == 'name') {
      depts.sort((a, b) => a.name.compareTo(b.name));
    } else if (state.sortBy == 'services') {
      depts.sort((a, b) {
        final aCount = state.servicesForDepartment(a.id, a.name).length;
        final bCount = state.servicesForDepartment(b.id, b.name).length;
        return bCount.compareTo(aCount);
      });
    }

    return depts;
  }
}
