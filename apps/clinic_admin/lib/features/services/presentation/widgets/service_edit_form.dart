import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_doctor_entity.dart';
import '../../domain/entities/clinic_service_entity.dart';
import '../../domain/entities/service_department_entity.dart';
import 'custom_service_request_fields.dart';
import 'service_dept_dropdown.dart';
import 'service_dialog_action_buttons.dart';
import 'service_doctor_checkbox_group.dart';
import 'service_duration_price_row.dart';
import 'service_form_text_field.dart';
import 'service_standard_dropdown.dart';
import 'service_ui_kit.dart';

class ServiceEditForm extends StatefulWidget {
  final ClinicServiceEntity? initialService;
  final List<ServiceDepartmentEntity> departments;
  final List<ClinicDoctorEntity> doctors;
  final ValueChanged<ClinicServiceEntity> onSave;
  final VoidCallback onCancel;

  const ServiceEditForm({
    super.key,
    this.initialService,
    required this.departments,
    required this.doctors,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ServiceEditForm> createState() => _ServiceEditFormState();
}

class _ServiceEditFormState extends State<ServiceEditForm> {
  static const _customValue = ServiceStandardDropdown.customValue;

  late String _deptId;
  late String _selectedStandard;
  final _customNameCtrl = TextEditingController();
  final _justificationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  late List<String> _assignedStaff;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final s = widget.initialService;
    final hasDept = widget.departments.any((d) => d.id == s?.departmentId);
    _deptId = hasDept
        ? s!.departmentId
        : (widget.departments.firstOrNull?.id ?? '');
    _assignedStaff = [if (widget.doctors.isNotEmpty) widget.doctors.first.name];

    if (s == null) {
      _durationCtrl.text = '20';
      _priceCtrl.text = '500';
      _selectStandard(_templates.firstOrNull?.name ?? _customValue);
      return;
    }

    // Services that are not in the department catalog (custom requests,
    // rejected ones) must use the custom option, otherwise the dropdown
    // asserts because its value is missing from the items.
    final isStandard = _templates.any((t) => t.name == s.name);
    _selectedStandard = isStandard ? s.name : _customValue;
    _customNameCtrl.text = isStandard ? '' : s.name;
    _justificationCtrl.text = s.justification;
    _descCtrl.text = s.description;
    _durationCtrl.text = s.duration.toString();
    _priceCtrl.text = s.price.toString();
    if (s.assignedStaff.isNotEmpty) {
      _assignedStaff = List.from(s.assignedStaff);
    }
  }

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _justificationCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  ServiceDepartmentEntity? get _currentDept {
    for (final d in widget.departments) {
      if (d.id == _deptId) return d;
    }
    return widget.departments.firstOrNull;
  }

  List<StandardServiceTemplate> get _templates =>
      _currentDept?.standardServices ?? const [];

  bool get _isCustom => _selectedStandard == _customValue;

  /// Doctors on the clinic plus any previously assigned names that are no
  /// longer listed, so editing never silently drops an assignment.
  List<ClinicDoctorEntity> get _doctorOptions => [
    ...widget.doctors,
    for (final name in _assignedStaff)
      if (!widget.doctors.any((d) => d.name == name))
        ClinicDoctorEntity(name: name),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.departments.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNoDepartmentsNotice(),
          const SizedBox(height: 20),
          ServiceDialogActionButtons(onCancel: widget.onCancel, onSave: null),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ServiceDeptDropdown(
          selectedDeptId: _currentDept?.id,
          departments: widget.departments,
          onChanged: _onDeptSelected,
        ),
        const SizedBox(height: 18),
        ServiceStandardDropdown(
          // Rebuild the field when the department changes so it picks up
          // the new initial value instead of keeping a stale selection.
          key: ValueKey(_deptId),
          selectedStandard: _selectedStandard,
          templates: _templates,
          onChanged: (val) {
            if (val != null) setState(() => _selectStandard(val));
          },
        ),
        const SizedBox(height: 18),
        if (_isCustom) ...[
          CustomServiceRequestFields(
            nameController: _customNameCtrl,
            justificationController: _justificationCtrl,
            nameError: _nameError,
          ),
          const SizedBox(height: 18),
        ],
        ServiceFormTextField(
          label: 'Service Description',
          controller: _descCtrl,
          maxLines: 2,
        ),
        const SizedBox(height: 18),
        ServiceDurationPriceRow(
          durationController: _durationCtrl,
          priceController: _priceCtrl,
        ),
        const SizedBox(height: 22),
        ServiceDoctorCheckboxGroup(
          availableDoctors: _doctorOptions,
          selectedDoctors: _assignedStaff,
          onToggleDoctor: (doc) => setState(
            () => _assignedStaff.contains(doc)
                ? _assignedStaff.remove(doc)
                : _assignedStaff.add(doc),
          ),
        ),
        const SizedBox(height: 24),
        ServiceDialogActionButtons(
          onCancel: widget.onCancel,
          onSave: _onSubmit,
        ),
      ],
    );
  }

  Widget _buildNoDepartmentsNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ServiceColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ServiceColors.amber.withValues(alpha: 0.4)),
      ),
      child: Text(
        'No departments are assigned to your clinic yet. Ask the Super Admin to license a department for your clinic, then its catalog services will appear here.',
        style: GoogleFonts.inter(
          fontSize: 12.5,
          height: 1.5,
          color: ServiceColors.amber,
        ),
      ),
    );
  }

  void _onDeptSelected(String? val) {
    if (val == null || val == _deptId) return;
    setState(() {
      _deptId = val;
      _selectStandard(_templates.firstOrNull?.name ?? _customValue);
    });
  }

  /// Selects a catalog entry and pre-fills the form from its template.
  void _selectStandard(String name) {
    _selectedStandard = name;
    _nameError = null;
    final tmpl = _templates.where((t) => t.name == name).firstOrNull;
    if (tmpl != null) {
      _descCtrl.text = tmpl.description;
      _durationCtrl.text = tmpl.duration.toString();
      _priceCtrl.text = tmpl.suggestedPrice.toString();
    }
  }

  void _onSubmit() {
    final name = _isCustom ? _customNameCtrl.text.trim() : _selectedStandard;
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter a service name');
      return;
    }
    final previousStatus = widget.initialService?.status;
    final fallbackDoctor = widget.doctors.isNotEmpty
        ? widget.doctors.first.name
        : 'Dr. Priya';
    widget.onSave(
      ClinicServiceEntity(
        id: widget.initialService?.id ?? '',
        name: name,
        departmentId: _deptId,
        departmentName: _currentDept?.name ?? 'General Medicine',
        description: _descCtrl.text.trim(),
        duration: int.tryParse(_durationCtrl.text.trim()) ?? 20,
        price: int.tryParse(_priceCtrl.text.trim()) ?? 500,
        assignedStaff: _assignedStaff.isEmpty
            ? [fallbackDoctor]
            : _assignedStaff,
        // Catalog services never need review; keep a deliberate deactivation.
        status: _isCustom
            ? 'pending_approval'
            : (previousStatus == 'inactive' ? 'inactive' : 'active'),
        justification: _isCustom ? _justificationCtrl.text.trim() : '',
      ),
    );
  }
}
