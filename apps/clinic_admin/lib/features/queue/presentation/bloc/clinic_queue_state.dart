import 'package:equatable/equatable.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import '../../domain/entities/clinic_queue_summary_entity.dart';

enum ClinicQueueStatus { initial, loading, success, failure }

class ClinicQueueState extends Equatable {
  final ClinicQueueStatus status;
  final ClinicQueueSummaryEntity summary;
  final List<ClinicQueueItemEntity> items;
  final List<ServiceDepartmentEntity> departments;
  final List<ClinicServiceEntity> services;

  // Active drill-down service (if null, displays Sub-View 1: Department Overview)
  final ClinicServiceEntity? drillDownService;
  final ServiceDepartmentEntity? drillDownDepartment;

  // Filters & Search
  final String searchQuery;
  final String departmentFilter; // 'all' or id
  final String statusFilter; // 'all', 'waiting', 'active', 'idle'
  final String sortBy; // 'default', 'waiting', 'name', 'services'
  final String serviceTab; // 'active', 'waiting', 'called', 'completed', 'all'
  final Set<String> collapsedDepts;

  final ClinicQueueItemEntity? selectedPatient;
  final String? toastMessage;
  final bool isErrorToast;

  const ClinicQueueState({
    this.status = ClinicQueueStatus.initial,
    this.summary = const ClinicQueueSummaryEntity(),
    this.items = const [],
    this.departments = const [],
    this.services = const [],
    this.drillDownService,
    this.drillDownDepartment,
    this.searchQuery = '',
    this.departmentFilter = 'all',
    this.statusFilter = 'all',
    this.sortBy = 'default',
    this.serviceTab = 'active',
    this.collapsedDepts = const {},
    this.selectedPatient,
    this.toastMessage,
    this.isErrorToast = false,
  });

  bool get isLoading => status == ClinicQueueStatus.loading;
  bool get isDrillDown => drillDownService != null;

  int get waitingCount => items.where((i) => i.isWaiting).length;

  int get activeFiltersCount {
    int c = 0;
    if (departmentFilter != 'all') c++;
    if (statusFilter != 'all') c++;
    if (sortBy != 'default') c++;
    return c;
  }

  ClinicQueueItemEntity? get currentlyServing => items
      .cast<ClinicQueueItemEntity?>()
      .firstWhere((i) => i?.isCalled == true, orElse: () => null);

  List<ClinicServiceEntity> servicesForDepartment(
    String deptId,
    String deptName,
  ) {
    return services.where((s) {
      if (s.departmentId.isNotEmpty && s.departmentId == deptId) return true;
      if (s.departmentName.isNotEmpty &&
          s.departmentName.toLowerCase() == deptName.toLowerCase()) {
        return true;
      }
      return false;
    }).toList();
  }

  List<ClinicQueueItemEntity> queueForService(String serviceName) {
    return items
        .where(
          (q) =>
              q.serviceName.trim().toLowerCase() ==
              serviceName.trim().toLowerCase(),
        )
        .toList();
  }

  ClinicQueueState copyWith({
    ClinicQueueStatus? status,
    ClinicQueueSummaryEntity? summary,
    List<ClinicQueueItemEntity>? items,
    List<ServiceDepartmentEntity>? departments,
    List<ClinicServiceEntity>? services,
    ClinicServiceEntity? drillDownService,
    bool clearDrillDown = false,
    ServiceDepartmentEntity? drillDownDepartment,
    String? searchQuery,
    String? departmentFilter,
    String? statusFilter,
    String? sortBy,
    String? serviceTab,
    Set<String>? collapsedDepts,
    ClinicQueueItemEntity? selectedPatient,
    bool clearSelectedPatient = false,
    String? toastMessage,
    bool clearToast = false,
    bool? isErrorToast,
  }) {
    return ClinicQueueState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      items: items ?? this.items,
      departments: departments ?? this.departments,
      services: services ?? this.services,
      drillDownService: clearDrillDown
          ? null
          : (drillDownService ?? this.drillDownService),
      drillDownDepartment: clearDrillDown
          ? null
          : (drillDownDepartment ?? this.drillDownDepartment),
      searchQuery: searchQuery ?? this.searchQuery,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      sortBy: sortBy ?? this.sortBy,
      serviceTab: serviceTab ?? this.serviceTab,
      collapsedDepts: collapsedDepts ?? this.collapsedDepts,
      selectedPatient: clearSelectedPatient
          ? null
          : (selectedPatient ?? this.selectedPatient),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isErrorToast: isErrorToast ?? this.isErrorToast,
    );
  }

  @override
  List<Object?> get props => [
    status,
    summary,
    items,
    departments,
    services,
    drillDownService,
    drillDownDepartment,
    searchQuery,
    departmentFilter,
    statusFilter,
    sortBy,
    serviceTab,
    collapsedDepts,
    selectedPatient,
    toastMessage,
    isErrorToast,
  ];
}
