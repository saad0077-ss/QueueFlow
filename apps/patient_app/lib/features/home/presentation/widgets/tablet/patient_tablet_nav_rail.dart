import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../../core/widgets/app_icon_badge.dart';
import '../../../../profile/presentation/bloc/profile_bloc.dart';
import '../queue/radar/live_pulsing_dot.dart';

/// Compact navigation rail for Tablet / Tab view.
class PatientTabletNavRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool hasActiveQueueTicket;
  final String userName;
  final String userInitials;

  const PatientTabletNavRail({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.hasActiveQueueTicket = false,
    required this.userName,
    required this.userInitials,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      width: 82,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(
            color: colors.border.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // App Logo
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const AppIconBadge(size: 26),
          ),
          const SizedBox(height: 20),

          // Navigation items
          _buildRailItem(
            context: context,
            index: 0,
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore_rounded,
            label: 'Home',
          ),
          const SizedBox(height: 12),
          _buildRailItem(
            context: context,
            index: 1,
            icon: Icons.groups_outlined,
            selectedIcon: Icons.groups_rounded,
            label: 'Queue',
            showBadge: hasActiveQueueTicket,
          ),
          const SizedBox(height: 12),
          _buildRailItem(
            context: context,
            index: 2,
            icon: Icons.event_available_outlined,
            selectedIcon: Icons.event_available_rounded,
            label: 'Bookings',
          ),
          const SizedBox(height: 12),
          _buildRailItem(
            context: context,
            index: 3,
            icon: Icons.account_circle_outlined,
            selectedIcon: Icons.account_circle_rounded,
            label: 'Profile',
          ),

          const Spacer(),

          // Theme Mode Toggle
          IconButton(
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: colors.textSubtle,
              size: 20,
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(const ThemeToggleRequested());
            },
          ),
          const SizedBox(height: 8),

          // User Avatar
          _buildUserAvatar(context, colors),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRailItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool showBadge = false,
  }) {
    final colors = context.colors;
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 66,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 24,
                  color: isSelected ? colors.primary : colors.textSubtle,
                ),
                if (showBadge)
                  const Positioned(
                    top: -2,
                    right: -4,
                    child: LivePulsingDot(),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? colors.primary : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, AppColorsExtension colors) {
    final profile = context.watch<ProfileBloc>().state.profile;
    final photoBase64 = profile?.photoBase64;
    final initials = profile?.initials.isNotEmpty == true
        ? profile!.initials
        : (userInitials.isNotEmpty ? userInitials : 'P');

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: photoBase64 != null && photoBase64.isNotEmpty
          ? Image.memory(
              base64Decode(photoBase64),
              fit: BoxFit.cover,
              width: 36,
              height: 36,
              errorBuilder: (_, __, ___) => Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
