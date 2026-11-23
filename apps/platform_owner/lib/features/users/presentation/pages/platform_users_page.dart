import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/navigation/platform_navigation_helper.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../../data/repositories/platform_users_repository_impl.dart';
import '../../domain/entities/platform_user_entity.dart';
import '../widgets/platform_users_filter_modal.dart';
import '../widgets/platform_users_filter_resolver.dart';
import '../widgets/platform_users_view_body.dart';

class PlatformUsersPage extends StatefulWidget {
  const PlatformUsersPage({super.key});

  @override
  State<PlatformUsersPage> createState() => _PlatformUsersPageState();
}

class _PlatformUsersPageState extends State<PlatformUsersPage> {
  final _repo = PlatformUsersRepositoryImpl();
  final _searchController = TextEditingController();
  late Stream<List<PlatformUserEntity>> _usersStream;
  List<Map<String, String>> _activeClinics = const [];
  String _searchQuery = '';
  PlatformUsersFilterOptions _filterOptions =
      const PlatformUsersFilterOptions();

  @override
  void initState() {
    super.initState();
    _usersStream = _repo.watchPlatformUsers();
    _loadClinics();
  }

  void _loadClinics() async {
    final clinics = await _repo.getActiveClinics();
    if (mounted) setState(() => _activeClinics = clinics);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _usersStream = _repo.watchPlatformUsers());

  void _onSidebarNav(int i) =>
      PlatformNavigationHelper.navigateTo(context, i, 2);

  void _toggleUserStatus(PlatformUserEntity user) async {
    final s = user.status.toLowerCase() == 'active' ? 'suspended' : 'active';
    try {
      await _repo.setUserStatus(user.id, s);
      if (mounted) {
        AppSnackBar.showSuccess(context, message: 'Status updated to $s.');
      }
      _refresh();
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, message: 'Failed to update: $e');
      }
    }
  }

  void _resetSearch() => setState(() {
    _searchQuery = '';
    _searchController.clear();
    _filterOptions = const PlatformUsersFilterOptions();
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

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
                  Expanded(child: _buildStream()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStream() {
    return StreamBuilder<List<PlatformUserEntity>>(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final allUsers = snapshot.data ?? const [];
        final filteredUsers = PlatformUsersFilterResolver.resolve(
          allUsers: allUsers,
          searchQuery: _searchQuery,
          filterOptions: _filterOptions,
        );
        return PlatformUsersViewBody(
          allUsers: allUsers,
          filteredUsers: filteredUsers,
          searchController: _searchController,
          filterOptions: _filterOptions,
          activeClinics: _activeClinics,
          repo: _repo,
          onRefresh: _refresh,
          onSearchChanged: (val) =>
              setState(() => _searchQuery = val.trim().toLowerCase()),
          onApplyFilter: (opts) => setState(() => _filterOptions = opts),
          onReset: _resetSearch,
          onToggleStatus: _toggleUserStatus,
        );
      },
    );
  }
}
