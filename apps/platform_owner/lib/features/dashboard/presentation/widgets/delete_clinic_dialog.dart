import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

class DeleteClinicDialog extends StatelessWidget {
  final TenantClinicEntity clinic;
  final TenantRepositoryImpl repo;
  final VoidCallback onDeleted;

  const DeleteClinicDialog({
    super.key,
    required this.clinic,
    required this.repo,
    required this.onDeleted,
  });

  static Future<void> show(BuildContext context, TenantClinicEntity c, TenantRepositoryImpl repo, {required VoidCallback onDeleted}) {
    return showDialog(
      context: context,
      builder: (ctx) => DeleteClinicDialog(clinic: c, repo: repo, onDeleted: onDeleted),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1527),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.65), blurRadius: 40, offset: const Offset(0, 16))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF7F1D1D).withValues(alpha: 0.35), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Delete Clinic Account', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Are you sure you want to permanently delete "${clinic.name}"?', style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('This will permanently delete the clinic record, revoke access for admin "${clinic.adminEmail}", and delete all pending invites.', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.45)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8)))),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await repo.deleteClinic(clinic.id, adminEmail: clinic.adminEmail);
                        onDeleted();
                        if (context.mounted) AppSnackBar.showSuccess(context, message: 'Deleted "${clinic.name}" and removed admin account.');
                      } catch (e) {
                        if (context.mounted) AppSnackBar.showError(context, message: 'Failed to delete clinic: $e');
                      }
                    },
                    child: const Text('Delete Permanently'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
