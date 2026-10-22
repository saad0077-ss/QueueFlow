import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/department_entity.dart';
import '../../domain/entities/standard_service_entity.dart';
import 'add_department_form_fields.dart';
import 'catalog_validation.dart';
import 'specialty_form_inputs.dart';

/// Add/edit dialog for a department. Passing [initial] switches it to edit mode.
class AddDepartmentModal extends StatefulWidget {
  final Future<void> Function(DepartmentEntity) onSave;
  final List<DepartmentEntity> existingDepartments;
  final DepartmentEntity? initial;

  const AddDepartmentModal({super.key, required this.onSave, this.existingDepartments = const [], this.initial});

  static Future<void> show(
    BuildContext context,
    Future<void> Function(DepartmentEntity) onSave, {
    List<DepartmentEntity> existingDepartments = const [],
    DepartmentEntity? initial,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AddDepartmentModal(onSave: onSave, existingDepartments: existingDepartments, initial: initial),
    );
  }

  @override
  State<AddDepartmentModal> createState() => _AddDepartmentModalState();
}

class _AddDepartmentModalState extends State<AddDepartmentModal> {
  late final _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
  late final _codeCtrl = TextEditingController(text: widget.initial?.code ?? '');
  late final _durationCtrl = TextEditingController(text: widget.initial?.avgConsultationTime ?? '20 mins');
  late final _descCtrl = TextEditingController(text: widget.initial?.description ?? '');
  final _servicesCtrl = TextEditingController();
  late String _icon = widget.initial?.icon ?? '🩺';
  late String _color = widget.initial?.color ?? '#2563EB';
  bool _isSaving = false;
  String? _error;

  bool get _isEdit => widget.initial != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    _servicesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 560,
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
          decoration: BoxDecoration(
            color: const Color(0xFF111A2E),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF334155)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 16))],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                AddDepartmentFormFields(
                  nameController: _nameCtrl,
                  codeController: _codeCtrl,
                  durationController: _durationCtrl,
                  descController: _descCtrl,
                  // Services are edited individually from the department's catalog tab.
                  servicesController: _isEdit ? null : _servicesCtrl,
                  selectedIcon: _icon,
                  selectedColor: _color,
                  onIconChanged: (v) => setState(() => _icon = v),
                  onColorChanged: (v) => setState(() => _color = v),
                ),
                if (_error != null) ...[const SizedBox(height: 16), FormErrorText(_error!)],
                const SizedBox(height: 22),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _isEdit ? 'Edit Medical Department' : 'Add Medical Department',
          style: GoogleFonts.inter(fontSize: 17.5, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinePillButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GradientPillButton(
            label: _isEdit ? 'Save Changes' : 'Save Department',
            loading: _isSaving,
            glow: true,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            onPressed: _submit,
          ),
        ),
      ],
    );
  }

  /// Returns an error message when the form would create a duplicate, else null.
  String? _validate(String name, String code, List<String> serviceNames) {
    if (name.isEmpty || code.isEmpty) return 'Department name and code are required.';
    for (final d in widget.existingDepartments) {
      if (d.id == widget.initial?.id) continue;
      if (catalogKey(d.name) == catalogKey(name)) return 'A department named "${d.name}" already exists.';
      if (catalogKey(d.code) == catalogKey(code)) return 'Code "${d.code}" is already used by ${d.name}.';
    }
    final dupService = firstDuplicateName(serviceNames);
    if (dupService != null) return 'Service "$dupService" is listed more than once.';
    return null;
  }

  void _submit() async {
    final name = _nameCtrl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final code = _codeCtrl.text.trim().toUpperCase();
    final serviceNames = _servicesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final error = _validate(name, code, serviceNames);
    setState(() => _error = error);
    if (error != null) return;
    setState(() => _isSaving = true);
    final initial = widget.initial;
    if (initial != null) {
      await widget.onSave(
        initial.copyWith(
          name: name,
          code: code,
          icon: _icon,
          color: _color,
          avgConsultationTime: _durationCtrl.text.trim(),
          description: _descCtrl.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
      return;
    }
    final services = serviceNames.map((s) {
      return StandardServiceEntity(
        id: s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-'),
        name: s,
        duration: 20,
        suggestedPrice: 500,
        description: '$s standard clinical procedure.',
      );
    }).toList();
    final dept = DepartmentEntity(
      id: '',
      name: name,
      code: code,
      icon: _icon,
      color: _color,
      avgConsultationTime: _durationCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      standardServices: services,
    );
    await widget.onSave(dept);
    if (mounted) Navigator.pop(context);
  }
}
