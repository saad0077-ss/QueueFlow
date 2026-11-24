import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../../core/widgets/app_icon_badge.dart';
import '../../../../profile/presentation/bloc/profile_bloc.dart';
import '../queue/radar/live_pulsing_dot.dart';

/// Permanent responsive sidebar for Patient Portal on Laptop/Desktop screens.
class PatientLaptopSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool hasActiveQueueTicket;
  final String userName;
  final String userInitials;

  const PatientLaptopSidebar({
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
      width: 260,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. BRAND HEADER
          _buildBrandHeader(context, colors),

          const SizedBox(height: 12),

          // 2. NAVIGATION ITEMS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore_rounded,
                  title: 'Home & Clinics',
                  subtitle: 'Browse & search clinics',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.groups_outlined,
                  selectedIcon: Icons.groups_rounded,
                  title: 'Live Queue',
                  subtitle: 'Real-time queue tracker',
                  badgeWidget: hasActiveQueueTicket
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LivePulsingDot(),
                              SizedBox(width: 4),
                              Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF10B981),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.event_available_outlined,
                  selectedIcon: Icons.event_available_rounded,
                  title: 'My Bookings',
                  subtitle: 'Appointments & passes',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.account_circle_outlined,
                  selectedIcon: Icons.account_circle_rounded,
                  title: 'Profile & Health',
                  subtitle: 'Medical data & preferences',
                ),
              ],
            ),
          ),

          // 3. USER MINI PROFILE & FOOTER CONTROLS
          _buildUserFooter(context, colors, isDark),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.border.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const AppIconBadge(size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'QueueFlow',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PATIENT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Book smarter. Wait less.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required String subtitle,
    Widget? badgeWidget,
  }) {
    final colors = context.colors;
    final isSelected = currentIndex == index;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(14),
        hoverColor: colors.primary.withValues(alpha: 0.06),
        splashColor: colors.primary.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 22,
                color: isSelected ? colors.primary : colors.textSubtle,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color:
                            isSelected ? colors.primary : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeWidget != null) badgeWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserFooter(
    BuildContext context,
    AppColorsExtension colors,
    bool isDark,
  ) {
    final profileState = context.watch<ProfileBloc>().state;
    final profile = profileState.profile;
    final photoBase64 = profile?.photoBase64;
    final displayName = profile?.name.isNotEmpty == true
        ? profile!.name
        : (userName.isNotEmpty ? userName : 'Patient');
    final initials = profile?.initials.isNotEmpty == true
        ? profile!.initials
        : (userInitials.isNotEmpty ? userInitials : 'P');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary.withValues(alpha: 0.4),
        border: Border(
          top: BorderSide(
            color: colors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
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
                        width: 38,
                        height: 38,
                        errorBuilder: (_, __, ___) => Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Theme Toggle Icon
              Tooltip(
                message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                child: IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 18,
                    color: colors.textSubtle,
                  ),
                  onPressed: () {
                    context.read<ThemeBloc>().add(const ThemeToggleRequested());
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
