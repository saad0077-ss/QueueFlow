import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/widgets/app_snack_bar.dart';
import '../../../domain/entities/tenant_clinic_entity.dart';
import '../../../domain/repositories/tenant_repository.dart';
import '../clinic_invite_share_helper.dart';
import '../suspend_clinic_dialog.dart';
import 'clinic_delete_confirm_dialog.dart';

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
      } else {
        ClinicInviteShareHelper.showInviteShareModal(
          context,
          toEmail: clinic.adminEmail,
          clinicName: clinic.name,
          adminName: clinic.adminName,
          inviteUrl: res.inviteUrl,
          emailDelivered: false,
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
    ClinicDeleteConfirmDialog.show(
      context: context,
      repo: repo,
      clinic: clinic,
      onDeleted: onDeleted,
    );
  }
}
