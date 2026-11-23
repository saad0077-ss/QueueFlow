import 'package:flutter/material.dart';

import '../../../../core/utils/pdf_exporter.dart';
import '../../data/repositories/platform_users_repository_impl.dart';
import '../../domain/entities/platform_user_entity.dart';
import 'platform_users_content_view.dart';
import 'platform_users_dialog_actions.dart';
import 'platform_users_filter_modal.dart';

class PlatformUsersViewBody extends StatelessWidget {
  final List<PlatformUserEntity> allUsers;
  final List<PlatformUserEntity> filteredUsers;
  final TextEditingController searchController;
  final PlatformUsersFilterOptions filterOptions;
  final List<Map<String, String>> activeClinics;
  final PlatformUsersRepositoryImpl repo;
  final VoidCallback onRefresh;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PlatformUsersFilterOptions> onApplyFilter;
  final VoidCallback onReset;
  final ValueChanged<PlatformUserEntity> onToggleStatus;

  const PlatformUsersViewBody({
    super.key,
    required this.allUsers,
    required this.filteredUsers,
    required this.searchController,
    required this.filterOptions,
    required this.activeClinics,
    required this.repo,
    required this.onRefresh,
    required this.onSearchChanged,
    required this.onApplyFilter,
    required this.onReset,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformUsersContentView(
      allUsers: allUsers,
      filteredUsers: filteredUsers,
      searchController: searchController,
      filterOptions: filterOptions,
      onRefresh: onRefresh,
      onExport: () => PdfExporter.exportUsers(context, filteredUsers),
      onBroadcast: () => PlatformUsersDialogActions.sendNotification(
        context,
        repo: repo,
        totalCount: allUsers.length,
      ),
      onRegisterUser: () => PlatformUsersDialogActions.registerUser(
        context,
        repo: repo,
        availableClinics: activeClinics,
        onSuccess: onRefresh,
      ),
      onSearchChanged: onSearchChanged,
      onOpenFilter: () => PlatformUsersDialogActions.openFilter(
        context,
        currentOptions: filterOptions,
        onApply: onApplyFilter,
      ),
      onReset: onReset,
      onViewUser: (u) => PlatformUsersDialogActions.openUserDetails(
        context,
        user: u,
        onSendNotification: () => PlatformUsersDialogActions.sendNotification(
          context,
          repo: repo,
          targetUser: u,
          totalCount: 1,
        ),
        onToggleStatus: () => onToggleStatus(u),
        onDelete: () =>
            PlatformUsersDialogActions.deleteUser(context, repo: repo, user: u),
      ),
      onSendNotification: (u) => PlatformUsersDialogActions.sendNotification(
        context,
        repo: repo,
        targetUser: u,
        totalCount: 1,
      ),
      onToggleStatus: onToggleStatus,
      onDeleteUser: (u) =>
          PlatformUsersDialogActions.deleteUser(context, repo: repo, user: u),
    );
  }
}
