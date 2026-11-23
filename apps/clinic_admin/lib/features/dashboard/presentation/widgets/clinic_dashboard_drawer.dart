import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../bloc/clinic_dashboard_bloc.dart';
import '../bloc/clinic_dashboard_event.dart';
import 'clinic_profile_chip.dart';
import 'clinic_sidebar.dart';

class ClinicDashboardDrawer extends StatelessWidget {
  final String activeNav;
  final ClinicDashboardBloc bloc;

  const ClinicDashboardDrawer({
    super.key,
    required this.activeNav,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Drawer(
      width: 260,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Builder(
          builder: (drawerContext) => ClinicSidebar(
            activeItem: activeNav,
            onItemTap: (nav) {
              Navigator.of(drawerContext).pop();
              bloc.add(DashboardNavTabChanged(nav));
            },
            onSignOut: () {
              Navigator.of(drawerContext).pop();
              clinicSignOut(context);
            },
          ),
        ),
      ),
    );
  }
}
