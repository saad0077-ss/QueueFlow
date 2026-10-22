import 'dart:ui';

import 'package:flutter/material.dart';

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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1527),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
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
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Delete Department',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Permanently remove "${department.name}" (${department.code}) from the global catalog?',
                style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
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
