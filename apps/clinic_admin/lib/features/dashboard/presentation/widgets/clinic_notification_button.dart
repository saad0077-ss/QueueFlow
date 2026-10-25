import 'package:flutter/material.dart';
import '../../../../core/widgets/app_snack_bar.dart';

/// Notification icon button in the clinic top bar.
class ClinicNotificationButton extends StatelessWidget {
  const ClinicNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      icon: const Icon(
        Icons.notifications_none_rounded,
        color: Color(0xFFCBD5E1),
        size: 22,
      ),
      onPressed: () {
        AppSnackBar.showInfo(context, message: 'No new notifications');
      },
    );
  }
}
