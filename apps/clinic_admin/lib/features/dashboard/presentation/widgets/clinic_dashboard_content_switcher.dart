import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../appointments/presentation/pages/appointment_detail_page.dart';
import '../../../appointments/presentation/pages/clinic_appointments_view.dart';
import '../../../appointments/presentation/widgets/create_appointment_modal.dart';
import '../../../appointments/presentation/widgets/reschedule_appointment_dialog.dart';
import '../../../billing/presentation/pages/clinic_billing_view.dart';
import '../../../doctors/presentation/pages/clinic_doctors_view.dart';
import '../../../services/data/repositories/clinic_services_repository_impl.dart';
import '../../../services/domain/entities/clinic_doctor_entity.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../../services/presentation/pages/clinic_services_view.dart';
import '../../../settings/presentation/pages/clinic_settings_view.dart';
import '../../data/dashboard_appointments_source.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../bloc/clinic_dashboard_bloc.dart';
import '../bloc/clinic_dashboard_event.dart';
import '../bloc/clinic_dashboard_state.dart';
import 'dashboard_greeting_header.dart';
import 'dashboard_main_columns.dart';
import 'dashboard_stats_row.dart';

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

  String _clinicName = '';
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
    super.dispose();
  }

  Future<void> _openCreateAppointmentModal() async {
    final repo = _servicesRepo;
    ClinicBookingCatalog catalog;
    try {
      final results = await Future.wait([
        repo.getDepartments(),
        repo.watchServices().first,
        repo.getDoctors(),
      ]);
      catalog = ClinicBookingCatalog(
        departments: results[0] as List<ServiceDepartmentEntity>,
        services: results[1] as List<ClinicServiceEntity>,
        doctors: results[2] as List<ClinicDoctorEntity>,
      );
    } catch (_) {
      catalog = const ClinicBookingCatalog();
    }

    if (!mounted) return;

    CreateAppointmentModal.show(
      context,
      catalog: catalog,
      onCreate: (newAppt) {
        AppSnackBar.showSuccess(
          context,
          message: 'Appointment #${newAppt.bookingId} booked successfully!',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final bloc = widget.bloc;

    if (state.activeNav == 'Appointments') {
      return const ClinicAppointmentsView();
    }

    if (state.activeNav == 'Services') {
      return const ClinicServicesView();
    }

    if (state.activeNav == 'Doctors') {
      return ClinicDoctorsView(
        onNavigateToBilling: () =>
            bloc.add(const DashboardNavTabChanged('Plan & Billing')),
        onNavigateToQueue: () =>
            bloc.add(const DashboardNavTabChanged('Live Queue')),
      );
    }

    if (state.activeNav == 'Plan & Billing') {
      return const ClinicBillingView();
    }

    if (state.activeNav == 'Clinic Settings') {
      return const ClinicSettingsView();
    }

    if (_selectedAppointment != null) {
      return AppointmentDetailPage(
        appointment: _selectedAppointment!,
        onBack: () => setState(() => _selectedAppointment = null),
        onCheckIn: () {
          setState(() {
            _selectedAppointment = _selectedAppointment!.copyWith(
              status: 'checkedin',
            );
          });
          AppSnackBar.showSuccess(
            context,
            message: 'Patient #${_selectedAppointment!.bookingId} checked in.',
          );
        },
        onComplete: () {
          setState(() {
            _selectedAppointment = _selectedAppointment!.copyWith(
              status: 'completed',
            );
          });
          AppSnackBar.showSuccess(
            context,
            message:
                'Appointment #${_selectedAppointment!.bookingId} completed.',
          );
        },
        onReschedule: () {
          RescheduleAppointmentDialog.show(
            context,
            appointment: _selectedAppointment!,
            onReschedule: (newDate, newTime) {
              setState(() {
                _selectedAppointment = _selectedAppointment!.copyWith(
                  dateRaw: newDate,
                  timeRaw: newTime,
                  dateTime: '$newDate · $newTime',
                  status: 'confirmed',
                );
              });
              AppSnackBar.showSuccess(
                context,
                message: 'Appointment rescheduled to $newDate · $newTime',
              );
            },
          );
        },
        onCancel: () {
          setState(() {
            _selectedAppointment = _selectedAppointment!.copyWith(
              status: 'cancelled',
              payment: _selectedAppointment!.payment.copyWith(
                status: 'refunded',
                refundAmount: _selectedAppointment!.payment.amount,
                refundedAt: 'Processed to source account',
              ),
            );
          });
          AppSnackBar.showSuccess(
            context,
            message:
                'Appointment #${_selectedAppointment!.bookingId} cancelled and refund processed.',
          );
        },
      );
    }

    final overview = DashboardOverview.build(
      clinicName: _clinicName,
      departments: _departments,
      services: _services,
      doctors: _doctors,
      appointments: _appointments,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardGreetingHeader(
          doctorName: widget.doctorName,
          clinicName: overview.clinicName,
          departments: overview.departments,
          onPeriodChanged: (period) {
            AppSnackBar.showInfo(
              context,
              message: 'Filtered dashboard for period: $period',
            );
          },
        ),
        const SizedBox(height: 22),
        DashboardStatsRow(
          waitingCount: state.queue.waitingCount,
          todayAppointmentsCount: overview.todayAppointments,
          servedCount: overview.servedToday,
          checkedInCount: overview.checkedInNow,
        ),
        const SizedBox(height: 22),
        DashboardMainColumns(
          overview: overview,
          currentToken: state.queue.currentToken,
          waitingCount: state.queue.waitingCount,
          onCallNext: () => bloc.add(const DashboardCallNextPressed()),
          onViewQueue: () =>
              bloc.add(const DashboardNavTabChanged('Live Queue')),
          onAddWalkIn: () => bloc.add(const DashboardIssueWalkInPressed()),
          onCreateAppointment: _openCreateAppointmentModal,
          onTogglePauseQueue: () =>
              bloc.add(const DashboardTogglePausePressed()),
          isQueuePaused: state.queue.isPaused,
          onViewAllAppointments: () =>
              bloc.add(const DashboardNavTabChanged('Appointments')),
          onSelectAppointment: (appt) {
            setState(() => _selectedAppointment = appt);
          },
          onNavigateToServices: () =>
              bloc.add(const DashboardNavTabChanged('Services')),
        ),
      ],
    );
  }
}
