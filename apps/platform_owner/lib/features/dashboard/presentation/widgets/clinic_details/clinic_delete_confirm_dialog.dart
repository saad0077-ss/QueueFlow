import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../../core/widgets/app_snack_bar.dart';
import '../../../domain/entities/tenant_clinic_entity.dart';
import '../../../domain/repositories/tenant_repository.dart';

class ClinicDeleteConfirmDialog {
  static void show({
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                _buildHeader(ctx, colors),
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
                  'This action permanently deletes the facility, invites, and admin account.',
                  style: TextStyle(color: colors.textMuted, fontSize: 12.5),
                ),
                const SizedBox(height: 24),
                _buildActions(ctx, context, repo, clinic, onDeleted, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildHeader(BuildContext ctx, dynamic colors) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: colors.errorTint, shape: BoxShape.circle),
          child: Icon(Icons.delete_outline_rounded, color: colors.error, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Delete Clinic Account',
            style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
          onPressed: () => Navigator.pop(ctx),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  static Widget _buildActions(
    BuildContext ctx,
    BuildContext context,
    TenantRepository repo,
    TenantClinicEntity clinic,
    VoidCallback onDeleted,
    dynamic colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            Navigator.pop(ctx);
            try {
              await repo.deleteClinic(clinic.id, adminEmail: clinic.adminEmail);
              if (context.mounted) {
                onDeleted();
                AppSnackBar.showSuccess(context, message: 'Deleted "${clinic.name}".');
              }
            } catch (e) {
              if (context.mounted) {
                AppSnackBar.showError(context, message: 'Failed to delete clinic: $e');
              }
            }
          },
          child: const Text('Delete Clinic'),
        ),
      ],
    );
  }
}
