import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/cancel_ticket_usecase.dart';
import '../../domain/usecases/get_active_ticket_usecase.dart';
import '../../domain/usecases/get_featured_clinics_usecase.dart';
import '../../domain/usecases/join_queue_usecase.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/empty_tab_view.dart';
import '../widgets/home_greet_header.dart';
import '../widgets/home_tab_view.dart';
import '../widgets/patient_bottom_nav_bar.dart';

/// Patient Home Portal driven cleanly by BLoC state management (< 150 lines).
class PatientHomeScreen extends StatelessWidget {
  final HomeRepository? homeRepository;

  const PatientHomeScreen({super.key, this.homeRepository});

  @override
  Widget build(BuildContext context) {
    final repo = homeRepository ?? HomeRepositoryImpl();
    return BlocProvider(
      create: (_) => HomeBloc(
        getFeaturedClinicsUseCase: GetFeaturedClinicsUseCase(repo),
        getActiveTicketUseCase: GetActiveTicketUseCase(repo),
        joinQueueUseCase: JoinQueueUseCase(repo),
        cancelTicketUseCase: CancelTicketUseCase(repo),
      )..add(const HomeInitialDataRequested()),
      child: const _PatientHomeView(),
    );
  }
}

class _PatientHomeView extends StatelessWidget {
  const _PatientHomeView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          AppSnackBar.showSuccess(context, message: state.successMessage!);
        }
        if (state.errorMessage != null) {
          AppSnackBar.showError(context, message: state.errorMessage!);
        }
      },
      builder: (context, state) {
        final bloc = context.read<HomeBloc>();

        return Scaffold(
          backgroundColor: AppColors.darkBgApp,
          appBar: state.currentTabIndex == 0
              ? HomeGreetHeader(
                  userName: state.userName,
                  userInitials: state.userInitials,
                  unreadNotifications: state.unreadNotificationsCount,
                  onAvatarTap: () => bloc.add(const HomeNavTabChanged(3)),
                )
              : null,
          body: SafeArea(
            top: state.currentTabIndex != 0,
            child: IndexedStack(
              index: state.currentTabIndex,
              children: const [
                HomeTabView(),
                EmptyTabView(
                  title: 'Live Queue Tracker',
                  subtitle: 'Real-time queue tracking & token status will appear here.',
                ),
                EmptyTabView(
                  title: 'My Bookings',
                  subtitle: 'Upcoming and concluded clinic appointments.',
                ),
                EmptyTabView(
                  title: 'Patient Profile',
                  subtitle: 'Health ID, patient vitals, allergies & preferences.',
                ),
              ],
            ),
          ),
          bottomNavigationBar: PatientBottomNavBar(
            currentIndex: state.currentTabIndex,
            hasActiveQueueTicket: state.activeTicket?.isActive ?? false,
            onTap: (idx) => bloc.add(HomeNavTabChanged(idx)),
          ),
        );
      },
    );
  }
}
