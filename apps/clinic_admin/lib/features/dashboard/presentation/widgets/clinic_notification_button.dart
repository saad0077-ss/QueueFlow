import 'package:flutter/material.dart';

/// Notification icon button in the clinic top bar.
class ClinicNotificationButton extends StatelessWidget {
  const ClinicNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        icon: const Icon(
          Icons.notifications_none_rounded,
          color: Color(0xFF94A3B8),
          size: 20,
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No new notifications'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
