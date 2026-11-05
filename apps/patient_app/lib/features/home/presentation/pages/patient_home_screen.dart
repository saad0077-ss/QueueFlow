import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../booking/presentation/widgets/my_bookings_tab_view.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/widgets/profile_tab_view.dart';
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
    final profileRepo = ProfileRepositoryImpl();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeBloc(
            getFeaturedClinicsUseCase: GetFeaturedClinicsUseCase(repo),
            getActiveTicketUseCase: GetActiveTicketUseCase(repo),
            joinQueueUseCase: JoinQueueUseCase(repo),
            cancelTicketUseCase: CancelTicketUseCase(repo),
          )..add(const HomeInitialDataRequested()),
        ),
        // Provided here so the greeting header and the Profile tab share the
        // same profile (and therefore the same photo).
        BlocProvider(
          create: (_) => ProfileBloc(
            getProfileUseCase: GetProfileUseCase(profileRepo),
            updateProfileUseCase: UpdateProfileUseCase(profileRepo),
            toggleDarkModeUseCase: ToggleDarkModeUseCase(profileRepo),
            getFavoriteClinicsUseCase: GetFavoriteClinicsUseCase(profileRepo),
            getUserReviewsUseCase: GetUserReviewsUseCase(profileRepo),
            addReviewUseCase: AddReviewUseCase(profileRepo),
            deleteReviewUseCase: DeleteReviewUseCase(profileRepo),
            getSupportTicketsUseCase: GetSupportTicketsUseCase(profileRepo),
            createSupportTicketUseCase: CreateSupportTicketUseCase(profileRepo),
            sendTicketReplyUseCase: SendTicketReplyUseCase(profileRepo),
            logoutUseCase: LogoutUseCase(profileRepo),
            deleteAccountUseCase: DeleteAccountUseCase(profileRepo),
          )..add(const ProfileLoadRequested()),
        ),
      ],
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: state.currentTabIndex == 0
              ? HomeGreetHeader(
                  userName: state.userName,
                  userInitials: state.userInitials,
                  photoBase64: context.watch<ProfileBloc>().state.profile?.photoBase64,
                  unreadNotifications: state.unreadNotificationsCount,
                  onAvatarTap: () => bloc.add(const HomeNavTabChanged(3)),
                )
              : null,
          body: SafeArea(
            top: state.currentTabIndex != 0,
            child: IndexedStack(
              index: state.currentTabIndex,
              children: [
                const HomeTabView(),
                const EmptyTabView(
                  title: 'Live Queue Tracker',
                  subtitle: 'Real-time queue tracking & token status will appear here.',
                ),
                MyBookingsTabView(
                  onExploreClinics: () => bloc.add(const HomeNavTabChanged(0)),
                ),
                ProfileTabView(
                  onVisitsTap: () => bloc.add(const HomeNavTabChanged(2)),
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
