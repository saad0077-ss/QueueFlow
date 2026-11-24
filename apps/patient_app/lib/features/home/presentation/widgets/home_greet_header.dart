import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../profile/presentation/widgets/profile_avatar.dart';
import 'home_notification_bell.dart';

/// Top Header showing patient avatar with dynamic greeting salute,
/// username, and rounded notification bell with unread indicator.
class HomeGreetHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userInitials;
  final String? photoBase64;
  final int unreadNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const HomeGreetHeader({
    super.key,
    required this.userName,
    required this.userInitials,
    this.photoBase64,
    this.unreadNotifications = 0,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.headerBg,
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
              constraints: BoxConstraints(
                maxWidth: isWide ? 840 : double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: Row(
                        children: [
                          ProfileAvatar(
                            name: userName,
                            fallbackText: userInitials,
                            photoBase64: photoBase64,
                            size: 44,
                            fontSize: 15,
                            border: Border.all(color: colors.surface, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _greeting,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    HomeNotificationBell(
                      unreadCount: unreadNotifications,
                      onTap: onNotificationTap,
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
