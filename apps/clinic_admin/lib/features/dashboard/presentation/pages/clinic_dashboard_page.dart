import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/layout/clinic_breakpoints.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../services/presentation/pages/clinic_services_view.dart';
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
import '../widgets/clinic_account_removal_guard.dart';

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
      child: const ClinicAccountRemovalGuard(
        child: _ClinicDashboardView(),
      ),
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

    final isMobile = ClinicBreakpoints.isMobile(context);
    final isDesktop = ClinicBreakpoints.isDesktop(context);
    final hPad = isMobile ? 16.0 : 28.0;

    return BlocConsumer<ClinicDashboardBloc, ClinicDashboardState>(
      listener: (context, state) {
        if (state.toastMessage != null) {
          if (state.isErrorToast) {
            AppSnackBar.showError(context, message: state.toastMessage!);
          } else {
            AppSnackBar.showSuccess(context, message: state.toastMessage!);
          }
          context.read<ClinicDashboardBloc>().add(
            const DashboardClearFeedback(),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<ClinicDashboardBloc>();

        return Scaffold(
          backgroundColor: const Color(0xFF080D1A),
          // Phones get the full sidebar as a drawer instead of a fixed rail.
          drawer: isMobile
              ? Drawer(
                  width: 260,
                  backgroundColor: const Color(0xFF090E1A),
                  shape: const RoundedRectangleBorder(),
                  child: SafeArea(
                    child: Builder(
                      builder: (drawerContext) => ClinicSidebar(
                        activeItem: state.activeNav,
                        onItemTap: (nav) {
                          Navigator.of(drawerContext).pop();
                          bloc.add(DashboardNavTabChanged(nav));
                        },
                      ),
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  ClinicSidebar(
                    activeItem: state.activeNav,
                    compact: !isDesktop,
                    onItemTap: (nav) => bloc.add(DashboardNavTabChanged(nav)),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: hPad,
                          vertical: isMobile ? 10 : 14,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF090E1A),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF131D31),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Builder(
                          builder: (scaffoldContext) => ClinicTopBar(
                            compact: isMobile,
                            onMenuTap: isMobile
                                ? () =>
                                      Scaffold.of(scaffoldContext).openDrawer()
                                : null,
                            onSearchChanged: (query) =>
                                bloc.add(DashboardSearchQueryChanged(query)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            hPad,
                            isMobile ? 16 : 22,
                            hPad,
                            32,
                          ),
                          child: state.activeNav == 'Services'
                              ? ClinicServicesView(
                                  onNavigateToBilling: () => bloc.add(
                                    const DashboardNavTabChanged(
                                      'Plan & Billing',
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DashboardGreetingHeader(
                                      doctorName: doctorName,
                                    ),
                                    const SizedBox(height: 22),
                                    DashboardStatsRow(
                                      waitingCount: state.queue.waitingCount,
                                    ),
                                    const SizedBox(height: 22),
                                    DashboardMainColumns(
                                      currentToken: state.queue.currentToken,
                                      waitingCount: state.queue.waitingCount,
                                      onCallNext: () => bloc.add(
                                        const DashboardCallNextPressed(),
                                      ),
                                      onViewQueue: () {
                                        AppSnackBar.showInfo(
                                          context,
                                          message: 'Opening live queue view...',
                                        );
                                      },
                                      onAddWalkIn: () => bloc.add(
                                        const DashboardIssueWalkInPressed(),
                                      ),
                                      onCreateAppointment: () =>
                                          CreateAppointmentDialog.show(context),
                                      onTogglePauseQueue: () => bloc.add(
                                        const DashboardTogglePausePressed(),
                                      ),
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
            ),
          ),
        );
      },
    );
  }
}
