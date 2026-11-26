import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Compact status/count pill + chevron used in activity menu rows.
class ProfileMenuBadge extends StatelessWidget {
  final Color color;
  final String text;

  const ProfileMenuBadge({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: context.colors.textSubtle,
        ),
      ],
    );
  }
}
