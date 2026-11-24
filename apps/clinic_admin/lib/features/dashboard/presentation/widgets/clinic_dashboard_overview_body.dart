import 'package:flutter/material.dart';
import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../bloc/clinic_dashboard_bloc.dart';
import '../bloc/clinic_dashboard_event.dart';
import '../bloc/clinic_dashboard_state.dart';
import 'dashboard_greeting_header.dart';
import 'dashboard_main_columns.dart';
import 'dashboard_stats_row.dart';

class ClinicDashboardOverviewBody extends StatelessWidget {
  final DashboardOverview overview;
  final ClinicDashboardState state;
  final ClinicDashboardBloc bloc;
  final String doctorName;
  final VoidCallback onCreateAppointment;
  final ValueChanged<ClinicAppointmentEntity> onSelectAppointment;

  const ClinicDashboardOverviewBody({
    super.key,
    required this.overview,
    required this.state,
    required this.bloc,
    required this.doctorName,
    required this.onCreateAppointment,
    required this.onSelectAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardGreetingHeader(
          doctorName: doctorName,
          clinicName: overview.clinicName,
          departments: overview.departments,
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
          onCreateAppointment: onCreateAppointment,
          onTogglePauseQueue: () =>
              bloc.add(const DashboardTogglePausePressed()),
          isQueuePaused: state.queue.isPaused,
          onViewAllAppointments: () =>
              bloc.add(const DashboardNavTabChanged('Appointments')),
          onSelectAppointment: onSelectAppointment,
          onNavigateToServices: () =>
              bloc.add(const DashboardNavTabChanged('Services')),
        ),
      ],
    );
  }
}
