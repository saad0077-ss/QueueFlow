import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'clinic_notification_button.dart';
import 'clinic_profile_chip.dart';
import 'clinic_search_bar.dart';

/// Top bar in the Clinic Admin dashboard containing search, theme toggle, notifications, and profile.
class ClinicTopBar extends StatelessWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  /// Opens the navigation drawer; the menu button only shows when set.
  final VoidCallback? onMenuTap;

  /// Tightens spacing and collapses the profile chip for phone widths.
  final bool compact;

  const ClinicTopBar({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onMenuTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gap = compact ? 8.0 : 14.0;

    return Row(
      children: [
        if (onMenuTap != null) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colors.border,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Menu',
              icon: Icon(
                Icons.menu_rounded,
                color: colors.textPrimary,
                size: 20,
              ),
              onPressed: onMenuTap,
            ),
          ),
          SizedBox(width: gap),
        ],

        // Search Input (Compact)
        SizedBox(
          width: compact ? 180 : 260,
          child: ClinicSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
        ),

        const Spacer(),

        // Notifications Button
        const ClinicNotificationButton(),

        SizedBox(width: compact ? 4 : 8),

        // Admin Profile Chip with Sign Out Menu
        ClinicProfileChip(compact: compact),

        SizedBox(width: compact ? 4 : 8),

        // Theme Toggle Button (at the end of the bar)
        const ThemeModeToggleButton(),
      ],
    );
  }
}
