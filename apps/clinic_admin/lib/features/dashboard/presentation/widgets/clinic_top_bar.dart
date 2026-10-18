import 'package:flutter/material.dart';
import 'clinic_notification_button.dart';
import 'clinic_profile_chip.dart';
import 'clinic_search_bar.dart';

/// Top bar in the Clinic Admin dashboard containing search, notifications, and profile.
class ClinicTopBar extends StatelessWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  const ClinicTopBar({
    super.key,
    this.searchController,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Input
        Expanded(
          child: ClinicSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
        ),

        const SizedBox(width: 16),

        // Notifications Button
        const ClinicNotificationButton(),

        const SizedBox(width: 16),

        // Admin Profile Chip with Sign Out Menu
        const ClinicProfileChip(),
      ],
    );
  }
}
