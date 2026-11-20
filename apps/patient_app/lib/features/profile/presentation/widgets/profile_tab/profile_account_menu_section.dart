import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../profile_menu_section.dart';
import 'profile_dialogs.dart';

class ProfileAccountMenuSection extends StatelessWidget {
  const ProfileAccountMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileMenuSection(
      bottomMargin: 28,
      items: [
        ProfileMenuItem(
          icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
          iconBgColor: AppColors.error.withValues(alpha: 0.12),
          title: 'Log out',
          titleColor: AppColors.error,
          onTap: () => ProfileDialogs.showLogout(context),
        ),
        ProfileMenuItem(
          icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error.withValues(alpha: 0.85)),
          iconBgColor: AppColors.error.withValues(alpha: 0.06),
          title: 'Delete account',
          titleColor: AppColors.error.withValues(alpha: 0.85),
          onTap: () => ProfileDialogs.showDeleteAccount(context),
        ),
      ],
    );
  }
}
