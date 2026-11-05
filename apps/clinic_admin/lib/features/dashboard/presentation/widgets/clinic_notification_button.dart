import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';

/// Notification icon button in the clinic top bar.
class ClinicNotificationButton extends StatelessWidget {
  const ClinicNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IconButton(
      tooltip: 'Notifications',
      icon: Icon(
        Icons.notifications_none_rounded,
        color: colors.textMuted,
        size: 22,
      ),
      onPressed: () {
        AppSnackBar.showInfo(context, message: 'No new notifications');
      },
    );
  }
}
