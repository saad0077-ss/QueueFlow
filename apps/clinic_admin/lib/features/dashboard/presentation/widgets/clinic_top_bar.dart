import 'package:flutter/material.dart';
import 'clinic_notification_button.dart';
import 'clinic_profile_chip.dart';
import 'clinic_search_bar.dart';

/// Top bar in the Clinic Admin dashboard containing search, notifications, and profile.
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
    final gap = compact ? 8.0 : 16.0;

    return Row(
      children: [
        if (onMenuTap != null) ...[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF10192D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF1E293B).withValues(alpha: 0.8),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Menu',
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              onPressed: onMenuTap,
            ),
          ),
          SizedBox(width: gap),
        ],

        // Search Input
        Expanded(
          child: ClinicSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
        ),

        SizedBox(width: gap),

        // Notifications Button
        const ClinicNotificationButton(),

        SizedBox(width: compact ? 4 : 8),

        // Admin Profile Chip with Sign Out Menu
        ClinicProfileChip(compact: compact),
      ],
    );
  }
}
