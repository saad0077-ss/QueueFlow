import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/department_entity.dart';

class DeptDetailsTopBar extends StatelessWidget {
  final DepartmentEntity department;
  final VoidCallback onBack;
  final VoidCallback onToggleStatus;

  const DeptDetailsTopBar({super.key, required this.department, required this.onBack, required this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    final statusColor = department.isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        final breadcrumb = Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _pillButton(label: '← Back to Departments', onPressed: onBack, horizontal: 16),
            Container(width: 1, height: 22, color: const Color(0xFF334155)),
            Text('Department Hub  /', style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8))),
            _badge(department.code, const Color(0xFF3B82F6), mono: true),
            _badge(department.isActive ? 'ACTIVE' : 'INACTIVE', statusColor),
          ],
        );

        final actions = Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _pillButton(label: department.isActive ? '⏸️ Deactivate Specialty' : '▶️ Activate Specialty', onPressed: onToggleStatus),
            _pillButton(label: '🔄 Refresh', onPressed: () {}),
          ],
        );

        if (isCompact) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [breadcrumb, const SizedBox(height: 12), actions]);
        }

        return Row(
          children: [
            Expanded(child: breadcrumb),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }

  Widget _pillButton({required String label, required VoidCallback onPressed, double horizontal = 20}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF0D1526),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF1E293B)),
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 14),
        shape: const StadiumBorder(),
      ),
      onPressed: onPressed,
      child: Text(label, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold)),
    );
  }

  Widget _badge(String text, Color color, {bool mono = false}) {
    final style = mono
        ? GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: color)
        : GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: style),
    );
  }
}
