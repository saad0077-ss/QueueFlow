import 'package:flutter/material.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../billing/presentation/pages/clinic_billing_view.dart';
import '../../../services/presentation/pages/clinic_services_view.dart';
import '../../../settings/presentation/pages/clinic_settings_view.dart';
import '../bloc/clinic_dashboard_bloc.dart';
import '../bloc/clinic_dashboard_event.dart';
import '../bloc/clinic_dashboard_state.dart';
import 'create_appointment_dialog.dart';
import 'dashboard_greeting_header.dart';
import 'dashboard_main_columns.dart';
import 'dashboard_stats_row.dart';

class ClinicDashboardContentSwitcher extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (state.activeNav == 'Services') {
      return const ClinicServicesView();
    }

    if (state.activeNav == 'Plan & Billing') {
      return const ClinicBillingView();
    }

    if (state.activeNav == 'Clinic Settings') {
      return const ClinicSettingsView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardGreetingHeader(doctorName: doctorName),
        const SizedBox(height: 22),
        DashboardStatsRow(waitingCount: state.queue.waitingCount),
        const SizedBox(height: 22),
        DashboardMainColumns(
          currentToken: state.queue.currentToken,
          waitingCount: state.queue.waitingCount,
          onCallNext: () => bloc.add(const DashboardCallNextPressed()),
          onViewQueue: () => AppSnackBar.showInfo(context, message: 'Opening live queue view...'),
          onAddWalkIn: () => bloc.add(const DashboardIssueWalkInPressed()),
          onCreateAppointment: () => CreateAppointmentDialog.show(context),
          onTogglePauseQueue: () => bloc.add(const DashboardTogglePausePressed()),
          isQueuePaused: state.queue.isPaused,
        ),
      ],
    );
  }
}
