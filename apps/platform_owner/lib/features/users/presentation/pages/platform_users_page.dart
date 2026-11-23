import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../../billing/presentation/pages/platform_billing_page.dart';
import '../../../dashboard/presentation/pages/platform_clinics_page.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../../../departments/presentation/pages/platform_departments_page.dart';
import '../../../tickets/presentation/pages/platform_support_tickets_page.dart';
import '../../data/repositories/platform_users_repository_impl.dart';
import '../../domain/entities/platform_user_entity.dart';
import '../widgets/platform_users_content_view.dart';
import '../widgets/platform_users_dialog_actions.dart';
import '../widgets/platform_users_filter_modal.dart';
import '../widgets/platform_users_filter_resolver.dart';

class PlatformUsersPage extends StatefulWidget {
  const PlatformUsersPage({super.key});

  @override
  State<PlatformUsersPage> createState() => _PlatformUsersPageState();
}

class _PlatformUsersPageState extends State<PlatformUsersPage> {
  final _repo = PlatformUsersRepositoryImpl();
  final _searchController = TextEditingController();

  late Stream<List<PlatformUserEntity>> _usersStream;
  String _searchQuery = '';
  PlatformUsersFilterOptions _filterOptions =
      const PlatformUsersFilterOptions();
  List<Map<String, String>> _activeClinics = [];

  @override
  void initState() {
    super.initState();
    _usersStream = _repo.watchPlatformUsers();
    _loadActiveClinics();
  }

  void _refresh() {
    setState(() => _usersStream = _repo.watchPlatformUsers());
    _loadActiveClinics();
  }

  Future<void> _loadActiveClinics() async {
    final clinics = await _repo.getActiveClinics();
    if (mounted) setState(() => _activeClinics = clinics);
  }

  void _onSidebarNav(int i) {
    final page = switch (i) {
      0 => const PlatformClinicsPage(),
      1 => const PlatformDepartmentsPage(),
      3 => const PlatformSupportTicketsPage(),
      4 => const PlatformBillingPage(),
      _ => null,
    };
    if (page != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => page,
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  void _toggleUserStatus(PlatformUserEntity user) async {
    final nextStatus = user.status.toLowerCase() == 'suspended'
        ? 'active'
        : 'suspended';
    try {
      await _repo.setUserStatus(user.id, nextStatus);
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          message: 'User status set to: ${nextStatus.toUpperCase()}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          message: 'Failed to update user status: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      drawer: isDesktop
          ? null
          : Drawer(
              child: ConsoleSidebar(
                activeIndex: 2,
                onIndexChanged: _onSidebarNav,
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            ConsoleSidebar(activeIndex: 2, onIndexChanged: _onSidebarNav),
          Expanded(
            child: Builder(
              builder: (ctx) => Column(
                children: [
                  ConsoleTopBar(
                    onMenuPressed: isDesktop
                        ? null
                        : () => Scaffold.of(ctx).openDrawer(),
                    onSearch: (q) => setState(() {
                      _searchQuery = q.trim().toLowerCase();
                      _searchController.text = q;
                    }),
                  ),
                  Expanded(
                    child: StreamBuilder<List<PlatformUserEntity>>(
                      stream: _usersStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        final allUsers = snapshot.data ?? const [];
                        final filteredUsers =
                            PlatformUsersFilterResolver.resolve(
                              allUsers: allUsers,
                              searchQuery: _searchQuery,
                              filterOptions: _filterOptions,
                            );
                        return PlatformUsersContentView(
                          allUsers: allUsers,
                          filteredUsers: filteredUsers,
                          searchController: _searchController,
                          filterOptions: _filterOptions,
                          onRefresh: _refresh,
                          onExport: () => AppSnackBar.showSuccess(
                            context,
                            message:
                                'Exported ${filteredUsers.length} records to CSV.',
                          ),
                          onBroadcast: () =>
                              PlatformUsersDialogActions.sendNotification(
                                context,
                                repo: _repo,
                                totalCount: allUsers.length,
                              ),
                          onRegisterUser: () =>
                              PlatformUsersDialogActions.registerUser(
                                context,
                                repo: _repo,
                                availableClinics: _activeClinics,
                                onSuccess: _refresh,
                              ),
                          onSearchChanged: (val) => setState(
                            () => _searchQuery = val.trim().toLowerCase(),
                          ),
                          onOpenFilter: () =>
                              PlatformUsersDialogActions.openFilter(
                                context,
                                currentOptions: _filterOptions,
                                onApply: (opts) =>
                                    setState(() => _filterOptions = opts),
                              ),
                          onReset: () => setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                            _filterOptions = const PlatformUsersFilterOptions();
                          }),
                          onViewUser: (u) =>
                              PlatformUsersDialogActions.openUserDetails(
                                context,
                                user: u,
                                onSendNotification: () =>
                                    PlatformUsersDialogActions.sendNotification(
                                      context,
                                      repo: _repo,
                                      targetUser: u,
                                      totalCount: 1,
                                    ),
                                onToggleStatus: () => _toggleUserStatus(u),
                                onDelete: () =>
                                    PlatformUsersDialogActions.deleteUser(
                                      context,
                                      repo: _repo,
                                      user: u,
                                    ),
                              ),
                          onSendNotification: (u) =>
                              PlatformUsersDialogActions.sendNotification(
                                context,
                                repo: _repo,
                                targetUser: u,
                                totalCount: 1,
                              ),
                          onToggleStatus: _toggleUserStatus,
                          onDeleteUser: (u) =>
                              PlatformUsersDialogActions.deleteUser(
                                context,
                                repo: _repo,
                                user: u,
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
