import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SignInHeader extends StatelessWidget {
  final double titleSize;
  final double subtitleSize;

  const SignInHeader({
    super.key,
    required this.titleSize,
    required this.subtitleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your bookings and\nkeep an eye on live queue status.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: subtitleSize,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
