import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../departments/data/repositories/department_repository_impl.dart';
import '../../../departments/domain/entities/department_entity.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import 'onboard_modal_fields.dart';

class OnboardClinicModal {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _OnboardClinicDialog(parentContext: context),
    );
  } 
}

class _OnboardClinicDialog extends StatefulWidget {
  final BuildContext parentContext;
  const _OnboardClinicDialog({required this.parentContext});

  @override
  State<_OnboardClinicDialog> createState() => _OnboardClinicDialogState();
}

class _OnboardClinicDialogState extends State<_OnboardClinicDialog> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _adminNameCtrl = TextEditingController();
  final _adminEmailCtrl = TextEditingController();
  String _selectedPlan = 'solo';
  List<String> _selectedDepartmentIds = [];
  bool _isSubmitting = false;

  final _deptRepo = DepartmentRepositoryImpl();
  final _tenantRepo = TenantRepositoryImpl();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _adminNameCtrl.dispose();
    _adminEmailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: 480,
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
                  Text(
                    'Onboard New Clinic',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 17.5,
                    ),
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
                        hint: 'e.g. Green Valley Clinic',
                      ),
                      const SizedBox(height: 13),
                      OnboardTextField(
                        label: 'Address & City',
                        controller: _addressCtrl,
                        hint: 'Street, City, State',
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: OnboardTextField(
                              label: 'Admin Full Name',
                              controller: _adminNameCtrl,
                              hint: 'Dr. Ayesha Khan',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OnboardTextField(
                              label: 'Admin Email',
                              controller: _adminEmailCtrl,
                              hint: 'admin@clinic.com',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      StreamBuilder<List<DepartmentEntity>>(
                        stream: _deptRepo.watchDepartments(),
                        builder: (context, snapshot) {
                          final departments = snapshot.data ?? const [];
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
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
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
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Onboard & Send Invite',
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

  Future<void> _submit() async {
    final cleanName = _nameCtrl.text.trim();
    final cleanEmail = _adminEmailCtrl.text.trim();
    if (cleanName.isEmpty) {
      AppSnackBar.showWarning(context, message: 'Please enter a practice / clinic name.');
      return;
    }
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      AppSnackBar.showWarning(context, message: 'Please enter a valid administrator email.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Resolve selected department names from repository
      final allDepts = await _deptRepo.watchDepartments().first;
      final selectedDeptEntities = allDepts
          .where((d) => _selectedDepartmentIds.contains(d.id))
          .toList();
      final deptNames = selectedDeptEntities.map((d) => d.name).toList();

      final result = await _tenantRepo.onboardClinic(
        name: cleanName,
        address: _addressCtrl.text.trim(),
        adminName: _adminNameCtrl.text.trim(),
        adminEmail: cleanEmail,
        planId: _selectedPlan,
        departmentIds: _selectedDepartmentIds,
        departmentNames: deptNames,
      );

      if (mounted) {
        Navigator.pop(context);
        await Clipboard.setData(ClipboardData(text: result.inviteUrl));

        if (widget.parentContext.mounted) {
          if (result.emailDelivered) {
            AppSnackBar.showSuccess(
              widget.parentContext,
              message: 'Clinic onboarded! Invite email sent to $cleanEmail.',
            );
          } else {
            AppSnackBar.showWarning(
              widget.parentContext,
              message:
                  '${result.emailFeedback}\nActivation link copied to clipboard!',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackBar.showError(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}
