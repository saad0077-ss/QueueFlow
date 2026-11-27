import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/user_location_service.dart';
import '../../../booking/presentation/widgets/my_bookings_tab_view.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc_factory.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/widgets/profile_tab_view.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_bloc_factory.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_tab_view.dart';
import '../widgets/live_queue_tab_view.dart';
import '../widgets/patient_responsive_home_shell.dart';

/// Patient Home Portal driven cleanly by BLoC state management (< 150 lines).
class PatientHomeScreen extends StatelessWidget {
  final HomeRepository? homeRepository;
  final int initialTab;

  const PatientHomeScreen({
    super.key,
    this.homeRepository,
    this.initialTab = 0,
  });

  ProfileBloc _getOrCreateProfileBloc(BuildContext context) {
    try {
      return context.read<ProfileBloc>();
    } catch (_) {
      return ProfileBlocFactory.create();
    }
  }

  HomeBloc _getOrCreateHomeBloc(BuildContext context, HomeRepository repo) {
    UserLocationService.refresh();
    try {
      final existing = context.read<HomeBloc>();
      if (initialTab != 0) {
        existing.add(HomeNavTabChanged(initialTab));
      }
      return existing;
    } catch (_) {
      final b = HomeBlocFactory.create(repository: repo);
      if (initialTab != 0) {
        b.add(HomeNavTabChanged(initialTab));
      }
      return b;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = homeRepository ?? HomeRepositoryImpl();
    final profileBloc = _getOrCreateProfileBloc(context);
    final homeBloc = _getOrCreateHomeBloc(context, repo);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: homeBloc),
        BlocProvider.value(value: profileBloc),
      ],
      child: const _PatientHomeView(),
    );
  }
}

class _PatientHomeView extends StatefulWidget {
  const _PatientHomeView();

  @override
  State<_PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<_PatientHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const ProfileLoadRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (prev, curr) =>
          prev.currentTabIndex != curr.currentTabIndex &&
          curr.currentTabIndex == 3,
      listener: (context, _) {
        context.read<ProfileBloc>().add(const ProfileLoadRequested());
      },
      builder: (context, state) {
        final bloc = context.read<HomeBloc>();
        void goToBookings() => bloc.add(const HomeNavTabChanged(2));
        void goToLiveQueue() {
          bloc.add(const HomeRefreshRequested());
          bloc.add(const HomeNavTabChanged(1));
        }

        return PatientResponsiveHomeShell(
          state: state,
          bloc: bloc,
          tabs: [
            const HomeTabView(),
            const LiveQueueTabView(),
            MyBookingsTabView(
              onExploreClinics: () => bloc.add(const HomeNavTabChanged(0)),
              onTrackLiveQueue: goToLiveQueue,
            ),
            ProfileTabView(
              onVisitsTap: goToBookings,
              onTrackLiveQueue: goToLiveQueue,
            ),
          ],
        );
      },
    );
  }
}
