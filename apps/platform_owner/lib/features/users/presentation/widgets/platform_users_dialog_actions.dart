import 'package:flutter/material.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/platform_user_entity.dart';
import '../../domain/repositories/platform_users_repository.dart';
import 'delete_patient_dialog.dart';
import 'platform_add_user_dialog.dart';
import 'platform_send_notification_dialog.dart';
import 'platform_user_details_dialog.dart';
import 'platform_users_filter_modal.dart';

class PlatformUsersDialogActions {
  static void openFilter(
    BuildContext context, {
    required PlatformUsersFilterOptions currentOptions,
    required ValueChanged<PlatformUsersFilterOptions> onApply,
  }) {
    showDialog(
      context: context,
      builder: (_) => PlatformUsersFilterModal(
        currentOptions: currentOptions,
        onApply: onApply,
      ),
    );
  }

  static void openUserDetails(
    BuildContext context, {
    required PlatformUserEntity user,
    required VoidCallback onSendNotification,
    required VoidCallback onToggleStatus,
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      builder: (_) => PlatformUserDetailsDialog(
        user: user,
        onSendNotification: onSendNotification,
        onToggleStatus: onToggleStatus,
        onDelete: onDelete,
      ),
    );
  }

  static void sendNotification(
    BuildContext context, {
    required PlatformUsersRepository repo,
    PlatformUserEntity? targetUser,
    required int totalCount,
  }) {
    showDialog(
      context: context,
      builder: (_) => PlatformSendNotificationDialog(
        targetUser: targetUser,
        totalUsersCount: totalCount,
        onSend:
            ({
              required targetUserId,
              required title,
              required message,
              targetEmail,
              type,
            }) async {
              await repo.sendNotification(
                targetUserId: targetUserId,
                targetEmail: targetEmail,
                title: title,
                message: message,
                type: type,
              );
              if (context.mounted) {
                AppSnackBar.showSuccess(
                  context,
                  message: targetUser == null
                      ? '📢 Broadcast alert dispatched.'
                      : '📢 Notification delivered to ${targetUser.name}.',
                );
              }
            },
      ),
    );
  }

  static void registerUser(
    BuildContext context, {
    required PlatformUsersRepository repo,
    required List<Map<String, String>> availableClinics,
    required VoidCallback onSuccess,
  }) {
    showDialog(
      context: context,
      builder: (_) => PlatformAddUserDialog(
        availableClinics: availableClinics,
        onSave:
            ({
              required name,
              required phone,
              required email,
              age,
              gender,
              bloodGroup,
              clinicId,
              clinicName,
              emergencyContact,
              notes,
            }) async {
              await repo.registerPatient(
                name: name,
                phone: phone,
                email: email,
                age: age,
                gender: gender,
                bloodGroup: bloodGroup,
                clinicId: clinicId,
                clinicName: clinicName,
                emergencyContact: emergencyContact,
                notes: notes,
              );
              if (context.mounted) {
                onSuccess();
                AppSnackBar.showSuccess(
                  context,
                  message: 'Patient account $name successfully registered.',
                );
              }
            },
      ),
    );
  }

  static Future<void> deleteUser(
    BuildContext context, {
    required PlatformUsersRepository repo,
    required PlatformUserEntity user,
  }) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => DeletePatientDialog(
        user: user,
        onConfirm: () => repo.deletePatientAccount(user.id, email: user.email),
      ),
    );
    if (deleted == true && context.mounted) {
      AppSnackBar.showSuccess(
        context,
        message: 'Patient ${user.name} and records purged.',
      );
    }
  }
}
