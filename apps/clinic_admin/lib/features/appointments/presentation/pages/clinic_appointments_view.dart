import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/layout/dashboard_chrome.dart';
import '../../data/repositories/clinic_appointments_repository_impl.dart';
import '../bloc/clinic_appointments_bloc.dart';
import '../bloc/clinic_appointments_event.dart';
import '../bloc/clinic_appointments_state.dart';
import '../widgets/appointment_cancel_confirmation_dialog.dart';
import '../widgets/appointments_calendar_view.dart';
import '../widgets/appointments_header_bar.dart';
import '../widgets/appointments_list_table.dart';
import '../widgets/appointments_stats_row.dart';
import '../widgets/clinic_appointments_actions_helper.dart';
import '../widgets/clinic_appointments_filter_wrapper.dart';
import 'appointment_detail_page.dart';

class ClinicAppointmentsView extends StatelessWidget {
  const ClinicAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ClinicAppointmentsRepositoryImpl();

    return BlocProvider(
      create: (_) =>
          ClinicAppointmentsBloc(repository: repo)
            ..add(const StartWatchingAppointments()),
      child: const _ClinicAppointmentsBody(),
    );
  }
}

class _ClinicAppointmentsBody extends StatelessWidget {
  const _ClinicAppointmentsBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicAppointmentsBloc, ClinicAppointmentsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final bloc = context.read<ClinicAppointmentsBloc>();
        DashboardChrome.setDetailOpen(
          'Appointments',
          state.selectedAppointment != null,
        );

        if (state.selectedAppointment != null) {
          final appt = state.selectedAppointment!;
          return AppointmentDetailPage(
            appointment: appt,
            onBack: () => bloc.add(const SelectAppointment(null)),
            onCheckIn: () => ClinicAppointmentsActionsHelper.handleCheckIn(
              context,
              bloc,
              appt,
            ),
            onComplete: () => ClinicAppointmentsActionsHelper.handleComplete(
              context,
              bloc,
              appt,
            ),
            onReschedule: () =>
                ClinicAppointmentsActionsHelper.handleReschedule(
                  context,
                  bloc,
                  appt,
                ),
            onCancel: () => AppointmentCancelConfirmationDialog.show(
              context,
              bloc: bloc,
              appt: appt,
            ),
          );
        }

        final filtered = state.filteredAppointments;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppointmentsHeaderBar(
                viewMode: state.viewMode,
                onViewModeChanged: (mode) =>
                    bloc.add(ToggleAppointmentViewMode(mode)),
                onExportCsv: () =>
                    ClinicAppointmentsActionsHelper.exportCsv(context, bloc),
                onCreateAppointment: () =>
                    ClinicAppointmentsActionsHelper.handleCreateAppointment(
                      context,
                      bloc,
                    ),
              ),
              const SizedBox(height: 18),
              AppointmentsStatsRow(appointments: state.allAppointments),
              const SizedBox(height: 18),
              ClinicAppointmentsFilterWrapper(
                state: state,
                bloc: bloc,
                filtered: filtered,
              ),
              const SizedBox(height: 18),
              if (state.viewMode == 'list')
                AppointmentsListTable(
                  appointments: filtered,
                  onSelectAppointment: (appt) =>
                      bloc.add(SelectAppointment(appt)),
                )
              else
                AppointmentsCalendarView(
                  appointments: filtered,
                  selectedDate: state.selectedCalendarDate,
                  onSelectDate: (date) => bloc.add(SelectCalendarDate(date)),
                  onSelectAppointment: (appt) =>
                      bloc.add(SelectAppointment(appt)),
                ),
            ],
          ),
        );
      },
    );
  }
}
