import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/navigation/platform_navigation_helper.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
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
    PlatformNavigationHelper.navigateTo(context, i, 6);
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
                activeIndex: 6,
                onIndexChanged: _onSidebarNav,
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            ConsoleSidebar(activeIndex: 6, onIndexChanged: _onSidebarNav),
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
