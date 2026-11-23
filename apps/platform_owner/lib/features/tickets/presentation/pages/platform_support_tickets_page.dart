import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../billing/presentation/pages/platform_billing_page.dart';
import '../../../dashboard/presentation/pages/platform_clinics_page.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../../../departments/presentation/pages/platform_departments_page.dart';
import '../../../users/presentation/pages/platform_users_page.dart';
import '../bloc/platform_tickets_bloc_factory.dart';
import '../bloc/platform_tickets_event.dart';
import '../widgets/platform_tickets_workspace.dart';

class PlatformSupportTicketsPage extends StatefulWidget {
  const PlatformSupportTicketsPage({super.key});

  @override
  State<PlatformSupportTicketsPage> createState() =>
      _PlatformSupportTicketsPageState();
}

class _PlatformSupportTicketsPageState
    extends State<PlatformSupportTicketsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _topBarSearch = '';

  void _onSidebarNav(int i) {
    Widget? target;
    if (i == 0) target = const PlatformClinicsPage();
    if (i == 1) target = const PlatformDepartmentsPage();
    if (i == 2) target = const PlatformUsersPage();
    if (i == 4) target = const PlatformBillingPage();

    if (target != null && mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => target!,
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    final colors = context.colors;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      drawer: isDesktop
          ? null
          : Drawer(
              child: ConsoleSidebar(
                activeIndex: 3,
                onIndexChanged: _onSidebarNav,
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            ConsoleSidebar(activeIndex: 3, onIndexChanged: _onSidebarNav),
          Expanded(
            child: Column(
              children: [
                ConsoleTopBar(
                  onMenuPressed: isDesktop
                      ? null
                      : () => _scaffoldKey.currentState?.openDrawer(),
                  onSearch: (q) => setState(() => _topBarSearch = q),
                ),
                Expanded(
                  child: BlocProvider(
                    create: (context) =>
                        PlatformTicketsBlocFactory.create()
                          ..add(const WatchPlatformTicketsStarted()),
                    child: PlatformTicketsWorkspace(
                      topBarSearch: _topBarSearch,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
