import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class SignUpHeader extends StatelessWidget {
  final double titleSize;
  final double subtitleSize;

  const SignUpHeader({
    super.key,
    required this.titleSize,
    required this.subtitleSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your account',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Create your account to book\nappointments and track live queues.',
          style: TextStyle(
            color: colors.textMuted,
            fontSize: subtitleSize,
            height: 1.35,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
