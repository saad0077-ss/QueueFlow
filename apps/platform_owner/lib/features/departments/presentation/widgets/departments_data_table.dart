import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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
    final colors = context.colors;

    if (departments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(36),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            const Text('🩺', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            Text(
              'No medical departments match your criteria',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text('Try clearing search filters or add a new department above.', style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted)),
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
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _buildHeader(colors),
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

  Widget _buildHeader(AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _HeaderText('DEPARTMENT & CODE', colors: colors)),
          Expanded(flex: 3, child: _HeaderText('CLINICAL SPECIALTY', colors: colors)),
          Expanded(flex: 2, child: _HeaderText('AVERAGE CONSULTATION', colors: colors)),
          Expanded(flex: 2, child: _HeaderText('LINKED CLINICS', colors: colors)),
          Expanded(flex: 2, child: _HeaderText('MONTHLY TRIAGE', colors: colors)),
          Expanded(flex: 2, child: _HeaderText('STATUS', colors: colors)),
          Expanded(flex: 4, child: _HeaderText('ACTIONS', textAlign: TextAlign.right, colors: colors)),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final AppColorsExtension colors;
  const _HeaderText(this.text, {this.textAlign = TextAlign.left, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textMuted, letterSpacing: 0.5),
    );
  }
}
