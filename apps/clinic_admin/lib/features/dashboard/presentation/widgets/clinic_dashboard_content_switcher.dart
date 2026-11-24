import 'dart:async';
import 'package:flutter/material.dart';
import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../services/data/repositories/clinic_services_repository_impl.dart';
import '../../../services/domain/entities/clinic_doctor_entity.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../data/dashboard_appointments_source.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../bloc/clinic_dashboard_bloc.dart';
import '../bloc/clinic_dashboard_state.dart';
import 'clinic_create_appointment_launcher.dart';
import 'clinic_dashboard_nav_router.dart';

class ClinicDashboardContentSwitcher extends StatefulWidget {
  final ClinicDashboardState state;
  final ClinicDashboardBloc bloc;
  final String doctorName;

  const ClinicDashboardContentSwitcher({
    super.key,
    required this.state,
    required this.bloc,
    required this.doctorName,
  });

  @override
  State<ClinicDashboardContentSwitcher> createState() =>
      _ClinicDashboardContentSwitcherState();
}

class _ClinicDashboardContentSwitcherState
    extends State<ClinicDashboardContentSwitcher> {
  ClinicAppointmentEntity? _selectedAppointment;

  final _servicesRepo = ClinicServicesRepositoryImpl();
  final _appointmentsSource = DashboardAppointmentsSource();
  StreamSubscription<List<ClinicAppointmentEntity>>? _apptSub;
  StreamSubscription<List<ClinicServiceEntity>>? _servicesSub;
  StreamSubscription<List<ServiceDepartmentEntity>>? _deptsSub;

  String _clinicName = '';
  String _clinicId = '';
  List<ServiceDepartmentEntity> _departments = const [];
  List<ClinicDoctorEntity> _doctors = const [];
  List<ClinicServiceEntity> _services = const [];
  List<ClinicAppointmentEntity> _appointments = const [];

  @override
  void initState() {
    super.initState();
    _servicesSub = _servicesRepo.watchServices().listen((list) {
      if (mounted) setState(() => _services = list);
    }, onError: (_) {});
    _deptsSub = _servicesRepo.watchDepartments().listen((list) {
      if (mounted) setState(() => _departments = list);
    }, onError: (_) {});
    _loadClinicData();
    _watchAppointments();
  }

  String _departmentOf(String serviceId, String serviceName, String specialty) {
    for (final s in _services) {
      if (s.id == serviceId ||
          s.name.trim().toLowerCase() == serviceName.toLowerCase()) {
        if (s.departmentName.isNotEmpty) return s.departmentName;
      }
    }
    return specialty;
  }

  Future<void> _watchAppointments() async {
    try {
      final clinicId = await _servicesRepo.currentClinicId();
      if (!mounted) return;
      setState(() => _clinicId = clinicId);
      _apptSub = _appointmentsSource
          .watch(clinicId: clinicId, departmentOfService: _departmentOf)
          .listen((list) {
            if (mounted) setState(() => _appointments = list);
          }, onError: (_) {});
    } catch (_) {}
  }

  Future<void> _loadClinicData() async {
    try {
      final plan = await _servicesRepo.getServicePlan();
      if (mounted) setState(() => _clinicName = plan.clinicName);
    } catch (_) {}
    try {
      final depts = await _servicesRepo.getDepartments();
      if (mounted) setState(() => _departments = depts);
    } catch (_) {}
    try {
      final docs = await _servicesRepo.getDoctors();
      if (mounted) setState(() => _doctors = docs);
    } catch (_) {}
  }

  @override
  void dispose() {
    _apptSub?.cancel();
    _servicesSub?.cancel();
    _deptsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overview = DashboardOverview.build(
      clinicName: _clinicName,
      departments: _departments,
      services: _services,
      doctors: _doctors,
      appointments: _appointments,
    );

    return ClinicDashboardNavRouter(
      state: widget.state,
      bloc: widget.bloc,
      clinicId: _clinicId,
      clinicName: _clinicName,
      doctorName: widget.doctorName,
      overview: overview,
      selectedAppointment: _selectedAppointment,
      onCreateAppointment: () => ClinicCreateAppointmentLauncher.open(
        context,
        servicesRepo: _servicesRepo,
      ),
      onClearSelectedAppointment: () =>
          setState(() => _selectedAppointment = null),
      onSelectAppointment: (appt) =>
          setState(() => _selectedAppointment = appt),
      onUpdateAppointment: (updated) =>
          setState(() => _selectedAppointment = updated),
    );
  }
}
