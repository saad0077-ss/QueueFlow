import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/layout/patient_breakpoints.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'home_greet_header.dart';
import 'laptop/patient_laptop_header.dart';
import 'laptop/patient_laptop_sidebar.dart';
import 'patient_bottom_nav_bar.dart';
import 'tablet/patient_tablet_nav_rail.dart';

/// Responsive shell that renders dedicated Laptop, Tablet, and Mobile layouts.
class PatientResponsiveHomeShell extends StatelessWidget {
  final HomeState state;
  final HomeBloc bloc;
  final List<Widget> tabs;

  const PatientResponsiveHomeShell({
    super.key,
    required this.state,
    required this.bloc,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLaptop = PatientBreakpoints.isLaptop(context);
    final bool isTablet = PatientBreakpoints.isTablet(context);
    final hasActiveTicket = state.activeTicket?.isActive ?? false;

    // 1. LAPTOP LAYOUT: Full-width responsive desktop portal with permanent sidebar
    if (isLaptop) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            PatientLaptopSidebar(
              currentIndex: state.currentTabIndex,
              onTabSelected: (idx) => bloc.add(HomeNavTabChanged(idx)),
              hasActiveQueueTicket: hasActiveTicket,
              userName: state.userName,
              userInitials: state.userInitials,
            ),
            Expanded(
              child: Column(
                children: [
                  PatientLaptopHeader(
                    currentTabIndex: state.currentTabIndex,
                    userName: state.userName,
                    unreadNotifications: state.unreadNotificationsCount,
                    activeToken: hasActiveTicket ? state.activeTicket!.token : null,
                    onLiveQueueTap: () => bloc.add(const HomeNavTabChanged(1)),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: state.currentTabIndex,
                      children: tabs,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. TABLET (TAB VIEW) LAYOUT: Compact Left Rail + Tablet-optimized viewport
    if (isTablet) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            PatientTabletNavRail(
              currentIndex: state.currentTabIndex,
              onTabSelected: (idx) => bloc.add(HomeNavTabChanged(idx)),
              hasActiveQueueTicket: hasActiveTicket,
              userName: state.userName,
              userInitials: state.userInitials,
            ),
            Expanded(
              child: Column(
                children: [
                  if (state.currentTabIndex == 0)
                    HomeGreetHeader(
                      userName: state.userName,
                      userInitials: state.userInitials,
                      photoBase64: context
                          .watch<ProfileBloc>()
                          .state
                          .profile
                          ?.photoBase64,
                      unreadNotifications: state.unreadNotificationsCount,
                      onAvatarTap: () => bloc.add(const HomeNavTabChanged(3)),
                    )
                  else
                    PatientLaptopHeader(
                      currentTabIndex: state.currentTabIndex,
                      userName: state.userName,
                      unreadNotifications: state.unreadNotificationsCount,
                      activeToken:
                          hasActiveTicket ? state.activeTicket!.token : null,
                      onLiveQueueTap: () =>
                          bloc.add(const HomeNavTabChanged(1)),
                    ),
                  Expanded(
                    child: IndexedStack(
                      index: state.currentTabIndex,
                      children: tabs,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 3. MOBILE LAYOUT: Full-screen view with Bottom Navigation Bar
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: state.currentTabIndex == 0
          ? HomeGreetHeader(
              userName: state.userName,
              userInitials: state.userInitials,
              photoBase64:
                  context.watch<ProfileBloc>().state.profile?.photoBase64,
              unreadNotifications: state.unreadNotificationsCount,
              onAvatarTap: () => bloc.add(const HomeNavTabChanged(3)),
            )
          : null,
      body: SafeArea(
        top: state.currentTabIndex > 1,
        child: IndexedStack(
          index: state.currentTabIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: PatientBottomNavBar(
        currentIndex: state.currentTabIndex,
        hasActiveQueueTicket: hasActiveTicket,
        onTap: (idx) => bloc.add(HomeNavTabChanged(idx)),
      ),
    );
  }
}
