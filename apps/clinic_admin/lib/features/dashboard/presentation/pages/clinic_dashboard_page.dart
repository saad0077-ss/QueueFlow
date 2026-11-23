import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/layout/clinic_breakpoints.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/clinic_dashboard_repository_impl.dart';
import '../../domain/usecases/call_next_token_usecase.dart';
import '../../domain/usecases/issue_walk_in_token_usecase.dart';
import '../../domain/usecases/toggle_pause_queue_usecase.dart';
import '../../domain/usecases/watch_queue_usecase.dart';
import '../bloc/clinic_dashboard_bloc.dart';
import '../bloc/clinic_dashboard_event.dart';
import '../bloc/clinic_dashboard_state.dart';
import '../widgets/clinic_account_removal_guard.dart';
import '../widgets/clinic_dashboard_content_switcher.dart';
import '../widgets/clinic_dashboard_drawer.dart';
import '../widgets/clinic_dashboard_top_bar_wrapper.dart';
import '../widgets/clinic_sidebar.dart';

class ClinicDashboardPage extends StatefulWidget {
  const ClinicDashboardPage({super.key});

  @override
  State<ClinicDashboardPage> createState() => _ClinicDashboardPageState();
}

class _ClinicDashboardPageState extends State<ClinicDashboardPage> {
  late final ClinicDashboardRepositoryImpl _repository;
  late final ClinicDashboardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _repository = ClinicDashboardRepositoryImpl();
    _bloc = ClinicDashboardBloc(
      watchQueueUseCase: WatchQueueUseCase(_repository),
      callNextTokenUseCase: CallNextTokenUseCase(_repository),
      issueWalkInTokenUseCase: IssueWalkInTokenUseCase(_repository),
      togglePauseQueueUseCase: TogglePauseQueueUseCase(_repository),
    )..add(const DashboardSubscriptionRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: const ClinicAccountRemovalGuard(child: _ClinicDashboardView()),
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
        : '';
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
        final colors = context.colors;

        return Scaffold(
          backgroundColor: colors.background,
          drawer: isMobile
              ? ClinicDashboardDrawer(activeNav: state.activeNav, bloc: bloc)
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
                      ClinicDashboardTopBarWrapper(
                        activeNav: state.activeNav,
                        isMobile: isMobile,
                        horizontalPadding: hPad,
                        bloc: bloc,
                      ),
                      Expanded(
                        child: state.activeNav == 'Patient Tickets'
                            ? ClinicDashboardContentSwitcher(
                                state: state,
                                bloc: bloc,
                                doctorName: doctorName,
                              )
                            : SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(
                                  hPad,
                                  isMobile ? 16 : 22,
                                  hPad,
                                  32,
                                ),
                                child: ClinicDashboardContentSwitcher(
                                  state: state,
                                  bloc: bloc,
                                  doctorName: doctorName,
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
