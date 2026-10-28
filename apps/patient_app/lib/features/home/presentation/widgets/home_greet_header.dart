import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Top Header showing patient avatar with gradient, dynamic greeting salute,
/// username, and rounded notification bell with unread dot.
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
  Size get preferredSize => const Size.fromHeight(68);

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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkInk,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '1 new',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkBgApp,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Queue Status Update',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: AppColors.darkInk,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your token is progressing smoothly.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkInkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
      toolbarHeight: 68,
      titleSpacing: 0,
      centerTitle: true,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 640;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 840 : double.infinity),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greet User (Avatar + Text)
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: Row(
                        children: [
                          // Avatar Circle with Gradient & White Initials
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.darkSurface,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x332563EB),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              userInitials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
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
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkInk,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Notification Bell (40x40 with rounded corners matching prototype .bell-btn)
                    GestureDetector(
                      onTap: onNotificationTap ?? () => _showNotificationsSheet(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.darkBorder,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140F172A),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
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
                                top: 8,
                                right: 8,
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
