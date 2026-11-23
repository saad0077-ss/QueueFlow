import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

class ClinicInviteHelper {
  static Future<void> resendInvite({
    required BuildContext context,
    required TenantRepositoryImpl repo,
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
              'Link copied to clipboard. Sandbox note: ${res.emailFeedback}',
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
}
