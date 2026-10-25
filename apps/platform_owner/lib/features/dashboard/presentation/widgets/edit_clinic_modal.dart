import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../departments/data/repositories/department_repository_impl.dart';
import '../../../departments/domain/entities/department_entity.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import 'onboard_modal_fields.dart';

class EditClinicModal {
  static void show(BuildContext context, TenantClinicEntity clinic) {
    showDialog(
      context: context,
      builder: (ctx) => _EditClinicDialog(clinic: clinic, parentContext: context),
    );  
  }
}

class _EditClinicDialog extends StatefulWidget {
  final TenantClinicEntity clinic;
  final BuildContext parentContext;
  const _EditClinicDialog({required this.clinic, required this.parentContext});

  @override
  State<_EditClinicDialog> createState() => _EditClinicDialogState();
}

class _EditClinicDialogState extends State<_EditClinicDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _adminNameCtrl;
  late final TextEditingController _adminEmailCtrl;
  late String _selectedPlan;
  List<String> _selectedDepartmentIds = [];
  bool _departmentsInitialized = false;
  bool _isSaving = false;

  final _deptRepo = DepartmentRepositoryImpl();
  final _tenantRepo = TenantRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.clinic.name);
    _addressCtrl = TextEditingController(text: widget.clinic.address);
    _cityCtrl = TextEditingController(text: widget.clinic.city);
    _phoneCtrl = TextEditingController(text: widget.clinic.phone);
    _adminNameCtrl = TextEditingController(text: widget.clinic.adminName);
    _adminEmailCtrl = TextEditingController(text: widget.clinic.adminEmail);
    _selectedPlan = widget.clinic.planId;
    _selectedDepartmentIds = List<String>.from(widget.clinic.departmentIds);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _adminNameCtrl.dispose();
    _adminEmailCtrl.dispose();
    super.dispose();
  }     

  void _initDepartmentsIfLegacy(List<DepartmentEntity> allDepartments) {
    if (_departmentsInitialized) return;
    _departmentsInitialized = true;

    if (_selectedDepartmentIds.isEmpty && allDepartments.isNotEmpty) {
      final slug = widget.clinic.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      final matched = allDepartments.where((d) {
        final assigned = d.assignedClinics;
        final matchesAssigned = assigned.any((k) => k == widget.clinic.id || (k.isNotEmpty && slug.startsWith(k)));
        final matchesCategory = widget.clinic.category.toLowerCase().contains(d.name.toLowerCase());
        return matchesAssigned || matchesCategory;
      }).map((d) => d.id).toList();

      if (matched.isNotEmpty) {
        setState(() {
          _selectedDepartmentIds = matched;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1527),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C4A6E).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          size: 18,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Clinic Details',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 17.5,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A253C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OnboardTextField(
                        label: 'Practice / Clinic Name',
                        controller: _nameCtrl,
                        hint: 'e.g. Sunrise Health Clinic',
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            flex: 60,
                            child: OnboardTextField(
                              label: 'Address',
                              controller: _addressCtrl,
                              hint: 'Street, Building, Suite',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 40,
                            child: OnboardTextField(
                              label: 'City & Jurisdiction',
                              controller: _cityCtrl,
                              hint: 'Kochi, Kerala',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: OnboardTextField(
                              label: 'Admin Full Name',
                              controller: _adminNameCtrl,
                              hint: 'Dr. Priya Sharma',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OnboardTextField(
                              label: 'Clinic Contact Line',
                              controller: _phoneCtrl,
                              hint: '+91 484 987 6543',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      OnboardTextField(
                        label: 'Admin Email (System Account ID)',
                        controller: _adminEmailCtrl,
                        hint: 'admin@clinic.com',
                        readOnly: true,
                        helperText: 'Primary login email is locked to preserve clinic admin credentials.',
                      ),
                      const SizedBox(height: 13),
                      StreamBuilder<List<DepartmentEntity>>(
                        stream: _deptRepo.watchDepartments(),
                        builder: (context, snapshot) {
                          final departments = snapshot.data ?? const [];
                          if (departments.isNotEmpty && !_departmentsInitialized) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _initDepartmentsIfLegacy(departments);
                            });
                          }
                          return OnboardDepartmentDropdown(
                            departments: departments,
                            selectedDepartmentIds: _selectedDepartmentIds,
                            isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
                            onChanged: (updated) {
                              setState(() {
                                _selectedDepartmentIds = updated;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 13),
                      OnboardPlanDropdown(
                        value: _selectedPlan,
                        onChanged: (v) => setState(() => _selectedPlan = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A253C),
                          foregroundColor: const Color(0xFFE2E8F0),
                          side: const BorderSide(color: Color(0xFF2A3B59)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final cleanName = _nameCtrl.text.trim();
    if (cleanName.isEmpty) {
      AppSnackBar.showWarning(context, message: 'Practice / clinic name cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final allDepts = await _deptRepo.watchDepartments().first;
      final selectedDeptEntities = allDepts
          .where((d) => _selectedDepartmentIds.contains(d.id))
          .toList();
      final deptNames = selectedDeptEntities.map((d) => d.name).toList();

      await _tenantRepo.updateClinic(
        clinicId: widget.clinic.id,
        name: cleanName,
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        adminName: _adminNameCtrl.text.trim(),
        planId: _selectedPlan,
        departmentIds: _selectedDepartmentIds,
        departmentNames: deptNames,
      );

      if (mounted) {
        Navigator.pop(context);
        if (widget.parentContext.mounted) {
          AppSnackBar.showSuccess(
            widget.parentContext,
            message: 'Updated details for "$cleanName" successfully.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.showError(
          context,
          message: 'Failed to update clinic: $e',
        );
      }
    }
  }
}
