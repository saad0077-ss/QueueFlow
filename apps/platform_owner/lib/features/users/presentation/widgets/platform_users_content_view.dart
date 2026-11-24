import 'package:flutter/material.dart';

import '../../domain/entities/platform_user_entity.dart';
import 'platform_users_data_table.dart';
import 'platform_users_filter_modal.dart';
import 'platform_users_filter_toolbar.dart';
import 'platform_users_header_bar.dart';
import 'platform_users_metric_cards.dart';

class PlatformUsersContentView extends StatelessWidget {
  final List<PlatformUserEntity> allUsers;
  final List<PlatformUserEntity> filteredUsers;
  final TextEditingController searchController;
  final PlatformUsersFilterOptions filterOptions;
  final VoidCallback onRefresh;
  final VoidCallback onExport;
  final VoidCallback onBroadcast;
  final VoidCallback onRegisterUser;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilter;
  final VoidCallback onReset;
  final ValueChanged<PlatformUserEntity> onViewUser;
  final ValueChanged<PlatformUserEntity> onSendNotification;
  final ValueChanged<PlatformUserEntity> onToggleStatus;
  final ValueChanged<PlatformUserEntity> onDeleteUser;

  const PlatformUsersContentView({
    super.key,
    required this.allUsers,
    required this.filteredUsers,
    required this.searchController,
    required this.filterOptions,
    required this.onRefresh,
    required this.onExport,
    required this.onBroadcast,
    required this.onRegisterUser,
    required this.onSearchChanged,
    required this.onOpenFilter,
    required this.onReset,
    required this.onViewUser,
    required this.onSendNotification,
    required this.onToggleStatus,
    required this.onDeleteUser,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlatformUsersHeaderBar(
            totalCount: allUsers.length,
            onRefresh: onRefresh,
            onExport: onExport,
            onBroadcast: onBroadcast,
            onRegisterUser: onRegisterUser,
          ),
          const SizedBox(height: 20),
          PlatformUsersMetricCards(users: allUsers),
          const SizedBox(height: 20),
          PlatformUsersFilterToolbar(
            searchController: searchController,
            activeFiltersCount: filterOptions.activeFiltersCount,
            onSearchChanged: onSearchChanged,
            onOpenFilter: onOpenFilter,
            onReset: onReset,
          ),
          const SizedBox(height: 16),
          PlatformUsersDataTable(
            users: filteredUsers,
            onViewUser: onViewUser,
            onSendNotification: onSendNotification,
            onToggleStatus: onToggleStatus,
            onDeleteUser: onDeleteUser,
          ),
        ],
      ),
    );
  }
}
