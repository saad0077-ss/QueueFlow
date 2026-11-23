import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../../core/widgets/app_snack_bar.dart';
import '../../../domain/entities/tenant_clinic_entity.dart';
import '../../../domain/repositories/tenant_repository.dart';
import '../suspend_clinic_dialog.dart';

class ClinicDetailsDialogHelper {
  static void copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.showSuccess(context, message: '$label copied to clipboard.');
  }

  static Future<void> resendInvite({
    required BuildContext context,
    required TenantRepository repo,
    required TenantClinicEntity clinic,
  }) async {
    try {
      final res = await repo.resendInvite(
        clinicId: clinic.id,
        clinicName: clinic.name,
        adminName: clinic.adminName,
        adminEmail: clinic.adminEmail,
      );
      await Clipboard.setData(ClipboardData(text: res.inviteUrl));
      if (!context.mounted) return;
      if (res.emailDelivered) {
        AppSnackBar.showSuccess(
          context,
          message:
              'Invite resent to ${clinic.adminEmail}! Activation link copied to clipboard.',
        );
      } else if (res.emailFeedback != null) {
        AppSnackBar.showWarning(
          context,
          message:
              'Link copied to clipboard. Sandbox notice: ${res.emailFeedback}',
        );
      } else {
        AppSnackBar.showSuccess(
          context,
          message:
              'Activation link copied to clipboard for ${clinic.adminEmail}.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, message: 'Failed to resend invite: $e');
      }
    }
  }

  static Future<void> toggleClinicStatus({
    required BuildContext context,
    required TenantRepository repo,
    required TenantClinicEntity clinic,
  }) async {
    try {
      String? reason;
      if (clinic.isActive) {
        reason = await SuspendClinicDialog.show(context, clinic);
        if (reason == null) return;
      }
      await repo.toggleStatus(clinic.id, clinic.isActive, reason: reason);
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          message: clinic.isActive ? 'Clinic paused.' : 'Clinic activated.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showWarning(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  static void confirmDeleteClinic({
    required BuildContext context,
    required TenantRepository repo,
    required TenantClinicEntity clinic,
    required VoidCallback onDeleted,
  }) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.errorTint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: colors.error,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Delete Clinic Account',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to delete "${clinic.name}"?',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This action will permanently delete:\n• The clinic facility document\n• Associated pending invites\n• Clinic admin user account\n\nThis cannot be undone.',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: colors.textMuted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await repo.deleteClinic(
                            clinic.id,
                            adminEmail: clinic.adminEmail,
                          );
                          if (context.mounted) {
                            onDeleted();
                            AppSnackBar.showSuccess(
                              context,
                              message:
                                  'Deleted "${clinic.name}" and removed admin account.',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackBar.showError(
                              context,
                              message: 'Failed to delete clinic: $e',
                            );
                          }
                        }
                      },
                      child: const Text('Delete Clinic'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
