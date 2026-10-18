import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Top App Bar showing patient greeting, avatar, and notification bell (PreferredSizeWidget).
class HomeGreetHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userInitials;
  final int unreadNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const HomeGreetHeader({
    super.key,
    required this.userName,
    required this.userInitials,
    this.unreadNotifications = 1,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.confirmation_number, color: Color(0xFF38BDF8), size: 24),
              title: Text(
                'Queue Position Update',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Colors.white),
              ),
              subtitle: Text(
                'You are currently 3rd in line at Smile Dental Clinic.',
                style: TextStyle(fontSize: 11.5, color: AppColors.darkInkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBgApp,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 66,
      titleSpacing: 20,
      title: GestureDetector(
        onTap: onAvatarTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkInkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textWhite,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: onNotificationTap ?? () => _showNotificationsSheet(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.darkInk,
                    size: 20,
                  ),
                  if (unreadNotifications > 0)
                    Positioned(
                      top: 10,
                      right: 11,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.darkSurface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
