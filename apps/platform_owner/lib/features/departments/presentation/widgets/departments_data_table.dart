import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/department_entity.dart';
import 'dept_table_row_item.dart';

class DepartmentsDataTable extends StatelessWidget {
  final List<DepartmentEntity> departments;
  final ValueChanged<DepartmentEntity> onDetails;
  final ValueChanged<DepartmentEntity> onEdit;
  final ValueChanged<DepartmentEntity> onToggleStatus;
  final ValueChanged<DepartmentEntity> onDelete;

  const DepartmentsDataTable({
    super.key,
    required this.departments,
    required this.onDetails,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (departments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(36),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1526),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          children: [
            const Text('🩺', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            Text(
              'No medical departments match your criteria',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text('Try clearing search filters or add a new department above.', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < 1060 ? 1060.0 : constraints.maxWidth;

        return Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1526),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _buildHeader(),
                  ...departments.map(
                    (d) => DeptTableRowItem(department: d, onDetails: onDetails, onEdit: onEdit, onToggleStatus: onToggleStatus, onDelete: onDelete),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF070B14),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _HeaderText('DEPARTMENT & CODE')),
          Expanded(flex: 3, child: _HeaderText('CLINICAL SPECIALTY')),
          Expanded(flex: 2, child: _HeaderText('AVERAGE CONSULTATION')),
          Expanded(flex: 2, child: _HeaderText('LINKED CLINICS')),
          Expanded(flex: 2, child: _HeaderText('MONTHLY TRIAGE')),
          Expanded(flex: 2, child: _HeaderText('STATUS')),
          Expanded(flex: 4, child: _HeaderText('ACTIONS', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  const _HeaderText(this.text, {this.textAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.5),
    );
  }
}
