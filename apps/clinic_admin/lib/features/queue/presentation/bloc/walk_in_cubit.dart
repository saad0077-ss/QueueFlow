import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';

class WalkInState extends Equatable {
  final List<ServiceDepartmentEntity> departments;
  final List<ClinicServiceEntity> allServices;
  final String deptKey;
  final ClinicServiceEntity? selectedService;

  const WalkInState({
    required this.departments,
    required this.allServices,
    required this.deptKey,
    this.selectedService,
  });

  List<ClinicServiceEntity> get departmentServices => allServices
      .where((s) => s.departmentName.trim().toLowerCase() == deptKey)
      .toList();

  ServiceDepartmentEntity? get currentDepartment => departments
      .where((d) => d.name.trim().toLowerCase() == deptKey)
      .firstOrNull;

  WalkInState copyWith({
    List<ServiceDepartmentEntity>? departments,
    List<ClinicServiceEntity>? allServices,
    String? deptKey,
    ClinicServiceEntity? Function()? selectedService,
  }) {
    return WalkInState(
      departments: departments ?? this.departments,
      allServices: allServices ?? this.allServices,
      deptKey: deptKey ?? this.deptKey,
      selectedService: selectedService != null
          ? selectedService()
          : this.selectedService,
    );
  }

  @override
  List<Object?> get props => [
    departments,
    allServices,
    deptKey,
    selectedService,
  ];
}

class WalkInCubit extends Cubit<WalkInState> {
  WalkInCubit({
    required List<ServiceDepartmentEntity> rawDepartments,
    required List<ClinicServiceEntity> rawServices,
    String? preselectedService,
  }) : super(_initState(rawDepartments, rawServices, preselectedService));

  static String _k(String s) => s.trim().toLowerCase();

  static WalkInState _initState(
    List<ServiceDepartmentEntity> rawDepts,
    List<ClinicServiceEntity> rawSvcs,
    String? preselectedService,
  ) {
    final byName = <String, ServiceDepartmentEntity>{};
    for (final d in rawDepts) {
      byName.putIfAbsent(_k(d.name), () => d);
    }
    for (final s in rawSvcs) {
      final name = s.departmentName.trim();
      if (name.isEmpty) continue;
      byName.putIfAbsent(
        _k(name),
        () => ServiceDepartmentEntity(
          id: s.departmentId,
          code: '',
          name: name,
          icon: '🩺',
        ),
      );
    }
    final depts = byName.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    String initialDeptKey = '';
    ClinicServiceEntity? initialSvc;

    if (preselectedService != null) {
      final preSvc = rawSvcs
          .where((s) => _k(s.name) == _k(preselectedService))
          .firstOrNull;
      if (preSvc != null) {
        initialDeptKey = _k(preSvc.departmentName);
        initialSvc = preSvc;
      }
    }
    if (initialDeptKey.isEmpty && depts.isNotEmpty) {
      initialDeptKey = _k(depts.first.name);
      final deptSvcs = rawSvcs
          .where((s) => _k(s.departmentName) == initialDeptKey)
          .toList();
      if (deptSvcs.isNotEmpty) initialSvc = deptSvcs.first;
    }

    return WalkInState(
      departments: depts,
      allServices: rawSvcs,
      deptKey: initialDeptKey,
      selectedService: initialSvc,
    );
  }

  void selectDepartment(String key) {
    final deptSvcs = state.allServices
        .where((s) => _k(s.departmentName) == key)
        .toList();
    emit(
      state.copyWith(
        deptKey: key,
        selectedService: () => deptSvcs.isNotEmpty ? deptSvcs.first : null,
      ),
    );
  }

  void selectService(ClinicServiceEntity svc) {
    emit(state.copyWith(selectedService: () => svc));
  }
}
