import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textMuted,
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
