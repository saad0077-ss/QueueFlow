import 'package:flutter/material.dart';
import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../appointments/presentation/pages/clinic_appointments_view.dart';
import '../../../billing/presentation/pages/clinic_billing_view.dart';
import '../../../doctors/presentation/pages/clinic_doctors_view.dart';
import '../../../queue/presentation/pages/clinic_live_queue_view.dart';
import '../../../reports/presentation/pages/clinic_reports_view.dart';
import '../../../revenue/presentation/pages/clinic_revenue_view.dart';
import '../../../services/presentation/pages/clinic_services_view.dart';
import '../../../settings/presentation/pages/clinic_settings_view.dart';
import '../../../tickets/presentation/pages/clinic_patient_tickets_view.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../bloc/clinic_dashboard_bloc.dart';
import '../bloc/clinic_dashboard_event.dart';
import '../bloc/clinic_dashboard_state.dart';
import 'clinic_dashboard_appointment_detail.dart';
import 'clinic_dashboard_overview_body.dart';

class ClinicDashboardNavRouter extends StatelessWidget {
  final ClinicDashboardState state;
  final ClinicDashboardBloc bloc;
  final String clinicId;
  final String clinicName;
  final String doctorName;
  final DashboardOverview overview;
  final ClinicAppointmentEntity? selectedAppointment;
  final VoidCallback onCreateAppointment;
  final VoidCallback onClearSelectedAppointment;
  final ValueChanged<ClinicAppointmentEntity> onSelectAppointment;
  final ValueChanged<ClinicAppointmentEntity> onUpdateAppointment;

  const ClinicDashboardNavRouter({
    super.key,
    required this.state,
    required this.bloc,
    required this.clinicId,
    required this.clinicName,
    required this.doctorName,
    required this.overview,
    required this.selectedAppointment,
    required this.onCreateAppointment,
    required this.onClearSelectedAppointment,
    required this.onSelectAppointment,
    required this.onUpdateAppointment,
  });

  @override
  Widget build(BuildContext context) {
    if (state.activeNav == 'Live Queue') return const ClinicLiveQueueView();
    if (state.activeNav == 'Appointments') return const ClinicAppointmentsView();
    if (state.activeNav == 'Services') return const ClinicServicesView();
    if (state.activeNav == 'Reports') return const ClinicReportsView();
    if (state.activeNav == 'Revenue') return const ClinicRevenueView();
    if (state.activeNav == 'Plan & Billing') return const ClinicBillingView();
    if (state.activeNav == 'Clinic Settings') return const ClinicSettingsView();

    if (state.activeNav == 'Doctors') {
      return ClinicDoctorsView(
        onNavigateToBilling: () =>
            bloc.add(const DashboardNavTabChanged('Plan & Billing')),
        onNavigateToQueue: () =>
            bloc.add(const DashboardNavTabChanged('Live Queue')),
      );
    }

    if (state.activeNav == 'Patient Tickets') {
      return ClinicPatientTicketsView(
        clinicId: clinicId,
        clinicName: clinicName,
        staffName: doctorName.isNotEmpty ? doctorName : 'Reception Care Desk',
        liveWaitingCount: state.queue.waitingCount,
        liveNowServing: state.queue.currentToken,
        onNavigateToQueue: () =>
            bloc.add(const DashboardNavTabChanged('Live Queue')),
      );
    }

    if (selectedAppointment != null) {
      return ClinicDashboardAppointmentDetail(
        appointment: selectedAppointment!,
        onBack: onClearSelectedAppointment,
        onUpdated: onUpdateAppointment,
      );
    }

    return ClinicDashboardOverviewBody(
      overview: overview,
      state: state,
      bloc: bloc,
      doctorName: doctorName,
      onCreateAppointment: onCreateAppointment,
      onSelectAppointment: onSelectAppointment,
    );
  }
}
