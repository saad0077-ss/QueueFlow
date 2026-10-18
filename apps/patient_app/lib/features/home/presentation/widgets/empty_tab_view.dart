import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Clean empty placeholder for secondary tabs (Queue, Bookings, Profile).
class EmptyTabView extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyTabView({
    super.key,
    required this.title,
    this.subtitle = 'This section is currently under development.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkInkMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
