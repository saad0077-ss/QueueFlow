import 'package:flutter/material.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';
import 'package:patient_app/features/onboarding/presentation/pages/welcome_screen.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ProfileTabListener {
  static void handle(BuildContext context, ProfileState state) {
    if (state.isLoggedOut) {
      final isDelete =
          state.successMessage?.toLowerCase().contains('deleted') ?? false;
      AppSnackBar.showSuccess(
        context,
        title: isDelete ? 'Account Deleted' : 'Logged Out',
        message: state.successMessage ??
            (isDelete
                ? 'Your account and personal data were permanently deleted.'
                : 'You have been safely logged out.'),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } else if (state.successMessage != null) {
      AppSnackBar.showSuccess(context, message: state.successMessage!);
    } else if (state.error != null) {
      AppSnackBar.showError(context, message: state.error!);
    }
  }

  static Widget buildErrorState(
    BuildContext context,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Failed to load profile',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
