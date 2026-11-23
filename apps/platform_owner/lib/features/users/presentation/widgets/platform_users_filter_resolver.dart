import '../../domain/entities/platform_user_entity.dart';
import 'platform_users_filter_modal.dart';

class PlatformUsersFilterResolver {
  static List<PlatformUserEntity> resolve({
    required List<PlatformUserEntity> allUsers,
    required String searchQuery,
    required PlatformUsersFilterOptions filterOptions,
  }) {
    return allUsers.where((u) {
      if (searchQuery.isNotEmpty) {
        final matchName = u.name.toLowerCase().contains(searchQuery);
        final matchEmail = u.email.toLowerCase().contains(searchQuery);
        final matchPhone = u.phone.toLowerCase().contains(searchQuery);
        final matchHealth = u.healthId.toLowerCase().contains(searchQuery);
        final matchToken = (u.activeQueueToken ?? '').toLowerCase().contains(
          searchQuery,
        );
        if (!matchName &&
            !matchEmail &&
            !matchPhone &&
            !matchHealth &&
            !matchToken) {
          return false;
        }
      }

      final isSuspended = u.status.toLowerCase() == 'suspended';
      final hasToken =
          u.activeQueueToken != null && u.activeQueueToken!.isNotEmpty;

      if (filterOptions.userType == 'platform_user') {
        if (u.isWalkIn) return false;
      } else if (filterOptions.userType == 'walk-in') {
        if (!u.isWalkIn) return false;
      }

      if (filterOptions.status == 'in-queue') {
        if (!hasToken) return false;
      } else if (filterOptions.status == 'verified') {
        if (!u.isVerified || isSuspended) return false;
      } else if (filterOptions.status == 'active') {
        if (isSuspended) return false;
      } else if (filterOptions.status == 'suspended') {
        if (!isSuspended) return false;
      }

      if (filterOptions.queueActivity == 'has-token') {
        if (!hasToken) return false;
      } else if (filterOptions.queueActivity == 'no-token') {
        if (hasToken) return false;
      }

      if (filterOptions.verification == 'verified') {
        if (!u.isVerified) return false;
      } else if (filterOptions.verification == 'unverified') {
        if (u.isVerified) return false;
      }

      return true;
    }).toList();
  }
}
