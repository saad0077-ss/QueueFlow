import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/department_entity.dart';

class DeptDeleteDialog extends StatelessWidget {
  final DepartmentEntity department;
  final VoidCallback onConfirm;

  const DeptDeleteDialog({super.key, required this.department, required this.onConfirm});

  static Future<void> show(BuildContext context, DepartmentEntity d, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (_) => DeptDeleteDialog(department: d, onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 16)),
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
                    decoration: BoxDecoration(color: colors.errorTint, shape: BoxShape.circle),
                    child: Icon(Icons.delete_outline_rounded, color: colors.error, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Delete Department',
                    style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Permanently remove "${department.name}" (${department.code}) from the global catalog?',
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: colors.error, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    child: const Text('Delete'),
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
