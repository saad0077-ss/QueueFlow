import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/department_entity.dart';
import 'dept_row_actions.dart';

class DeptTableRowItem extends StatelessWidget {
  final DepartmentEntity department;
  final ValueChanged<DepartmentEntity> onDetails;
  final ValueChanged<DepartmentEntity> onEdit;
  final ValueChanged<DepartmentEntity> onToggleStatus;
  final ValueChanged<DepartmentEntity> onDelete;

  const DeptTableRowItem({
    super.key,
    required this.department,
    required this.onDetails,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onDetails(department),
      hoverColor: const Color(0xFF1E293B).withValues(alpha: 0.35),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: _colDept()),
            Expanded(flex: 3, child: _colSpecialty(department.standardServices.length)),
            Expanded(
              flex: 2,
              child: Text(
                '⏱️ ${department.avgConsultationTime}',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            Expanded(flex: 2, child: _colClinics()),
            Expanded(flex: 2, child: _colVisits()),
            Expanded(flex: 2, child: _colStatus()),
            Expanded(
              flex: 4,
              child: DeptRowActions(
                department: department,
                onDetails: () => onDetails(department),
                onEdit: () => onEdit(department),
                onToggleStatus: () => onToggleStatus(department),
                onDelete: () => onDelete(department),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colDept() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(department.icon, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                department.name,
                style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.18), borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      department.code,
                      style: GoogleFonts.jetBrainsMono(fontSize: 10.5, fontWeight: FontWeight.w800, color: const Color(0xFF38BDF8)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${department.doctorCount} Doctor${department.doctorCount == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _colSpecialty(int count) {
    return _countBadge('$count Standard Service${count == 1 ? '' : 's'}', const Color(0xFF10B981));
  }

  Widget _colClinics() {
    final count = department.assignedClinics.length;
    return _countBadge('$count Clinic${count == 1 ? '' : 's'}', const Color(0xFF38BDF8));
  }

  Widget _countBadge(String label, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
        ),
      ),
    );
  }

  Widget _colVisits() {
    final formatted = department.totalVisits.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatted,
          style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text('visits / mo', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _colStatus() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: (department.isActive ? const Color(0xFF10B981) : const Color(0xFF64748B)).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          department.isActive ? 'ACTIVE' : 'INACTIVE',
          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: department.isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}
