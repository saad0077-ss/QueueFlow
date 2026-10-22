import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/department_entity.dart';

class DeptRowActions extends StatelessWidget {
  final DepartmentEntity department;
  final VoidCallback onDetails;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const DeptRowActions({
    super.key,
    required this.department,
    required this.onDetails,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final active = department.isActive;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: 'Manage services catalog',
          child: Material(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            shape: StadiumBorder(side: BorderSide(color: const Color(0xFF2563EB).withValues(alpha: 0.45))),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onDetails,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.medical_services_outlined, size: 13, color: Color(0xFF60A5FA)),
                    const SizedBox(width: 5),
                    Text(
                      'Services',
                      style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF60A5FA)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _iconButton(icon: Icons.edit_outlined, color: const Color(0xFF38BDF8), tooltip: 'Edit department', onTap: onEdit),
        const SizedBox(width: 6),
        _iconButton(
          icon: active ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: active ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
          tooltip: active ? 'Deactivate specialty' : 'Activate specialty',
          onTap: onToggleStatus,
        ),
        const SizedBox(width: 6),
        _iconButton(icon: Icons.delete_outline_rounded, color: const Color(0xFFEF4444), tooltip: 'Delete department', onTap: onDelete),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required Color color, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(width: 28, height: 28, child: Icon(icon, size: 16, color: color)),
        ),
      ),
    );
  }
}
