import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/clinic_dashboard_repository_impl.dart';
import '../../domain/usecases/call_next_token_usecase.dart';
import '../../domain/usecases/issue_walk_in_token_usecase.dart';
import '../../domain/usecases/toggle_pause_queue_usecase.dart';
import '../../domain/usecases/watch_queue_usecase.dart';
import '../bloc/clinic_dashboard_bloc.dart';
import '../bloc/clinic_dashboard_event.dart';
import '../bloc/clinic_dashboard_state.dart';
import '../widgets/clinic_sidebar.dart';
import '../widgets/clinic_top_bar.dart';
import '../widgets/create_appointment_dialog.dart';
import '../widgets/dashboard_greeting_header.dart';
import '../widgets/dashboard_main_columns.dart';
import '../widgets/dashboard_stats_row.dart';

/// Main Dashboard Page for Clinic Admin, driven entirely by pure BLoC state management.
class ClinicDashboardPage extends StatelessWidget {
  const ClinicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ClinicDashboardRepositoryImpl();

    return BlocProvider(
      create: (_) => ClinicDashboardBloc(
        watchQueueUseCase: WatchQueueUseCase(repository),
        callNextTokenUseCase: CallNextTokenUseCase(repository),
        issueWalkInTokenUseCase: IssueWalkInTokenUseCase(repository),
        togglePauseQueueUseCase: TogglePauseQueueUseCase(repository),
      )..add(const DashboardSubscriptionRequested()),
      child: const _ClinicDashboardView(),
    );
  }
}

class _ClinicDashboardView extends StatelessWidget {
  const _ClinicDashboardView();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final doctorName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'Dr. Priya';

    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: BlocConsumer<ClinicDashboardBloc, ClinicDashboardState>(
        listener: (context, state) {
          if (state.toastMessage != null) {
            final color = state.isErrorToast ? Colors.red : const Color(0xFF1E58F5);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.toastMessage!), backgroundColor: color, duration: const Duration(seconds: 2)),
            );
            context.read<ClinicDashboardBloc>().add(const DashboardClearFeedback());
          }
        },
        builder: (context, state) {
          final bloc = context.read<ClinicDashboardBloc>();

          return Row(
            children: [
              // Sidebar Navigation
              ClinicSidebar(
                activeItem: state.activeNav,
                onItemTap: (nav) => bloc.add(DashboardNavTabChanged(nav)),
              ),

              // Main Scrollable Dashboard Area
              Expanded(
                child: Column(
                  children: [
                    // Top App Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
                      child: ClinicTopBar(
                        onSearchChanged: (query) => bloc.add(DashboardSearchQueryChanged(query)),
                      ),
                    ),

                    // Scrollable Page Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                        child: Column(
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
                              onViewQueue: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Opening live queue view...'), duration: Duration(seconds: 2)),
                                );
                              },
                              onAddWalkIn: () => bloc.add(const DashboardIssueWalkInPressed()),
                              onCreateAppointment: () => CreateAppointmentDialog.show(context),
                              onTogglePauseQueue: () => bloc.add(const DashboardTogglePausePressed()),
                              isQueuePaused: state.queue.isPaused,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
