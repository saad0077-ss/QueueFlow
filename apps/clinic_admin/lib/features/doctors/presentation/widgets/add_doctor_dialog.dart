import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_daily_schedule.dart';
import 'doctor_ui_kit.dart';

class AddDoctorDialog extends StatefulWidget {
  final List<String> departments;
  final ValueChanged<ClinicDoctorProfileEntity> onSave;

  const AddDoctorDialog({
    super.key,
    required this.departments,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> departments,
    required ValueChanged<ClinicDoctorProfileEntity> onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AddDoctorDialog(
          departments: departments,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  State<AddDoctorDialog> createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<AddDoctorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _roomController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _roomController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    if (widget.departments.isNotEmpty) {
      _selectedSpecialty = widget.departments.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.departments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot add doctor: No departments are assigned to this clinic. Please request a department assignment from the platform admin.',
          ),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final specialty = (_selectedSpecialty != null && _selectedSpecialty!.isNotEmpty)
        ? _selectedSpecialty!.trim()
        : widget.departments.first;
    final room = _roomController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    final doc = ClinicDoctorProfileEntity(
      id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      title: '',
      specialty: specialty,
      department: specialty,
      room: room,
      email: email,
      phone: phone,
      schedule: 'Mon–Sat, 9:00 AM – 5:00 PM',
      weeklySchedule: DoctorDailySchedule.defaultWeekly(),
      status: 'available',
      accountStatus: 'active',
      services: [specialty],
    );

    widget.onSave(doc);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top glowing accent line
            Container(
              height: 3,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF06B6D4), Color(0xFF38BDF8)],
                ),
              ),
            ),

            // Inner content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF0284C7).withValues(alpha: 0.2),
                                        const Color(0xFF06B6D4).withValues(alpha: 0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.person_add_alt_1_rounded,
                                    size: 20,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add Clinic Doctor',
                                        style: GoogleFonts.inter(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: colors.textPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Register a practicing doctor for queue triage',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          color: colors.textMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.border),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Divider(color: colors.border, height: 1),
                      const SizedBox(height: 18),

                      // Doctor Full Name
                      DoctorLabeledField(
                        label: 'Doctor Full Name',
                        child: TextFormField(
                          controller: _nameController,
                          style: GoogleFonts.inter(fontSize: 13.5, color: colors.textPrimary),
                          decoration: _inputDecoration(
                            hint: 'e.g. Dr. Rajesh Pillai',
                            prefixIcon: Icons.badge_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Doctor name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Department & Consultation Room Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmall = constraints.maxWidth < 420;
                          if (isSmall) {
                            return Column(
                              children: [
                                _buildDepartmentDropdown(),
                                const SizedBox(height: 16),
                                _buildRoomField(),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildDepartmentDropdown()),
                              const SizedBox(width: 14),
                              Expanded(flex: 2, child: _buildRoomField()),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Work Email & Phone Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmall = constraints.maxWidth < 420;
                          if (isSmall) {
                            return Column(
                              children: [
                                _buildEmailField(),
                                const SizedBox(height: 16),
                                _buildPhoneField(),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildEmailField()),
                              const SizedBox(width: 14),
                              Expanded(child: _buildPhoneField()),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 26),

                      // Bottom action buttons: Cancel & Save Doctor
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.textPrimary,
                                side: BorderSide(color: colors.border),
                                backgroundColor: colors.surfaceSecondary,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0284C7), Color(0xFF00B4D8)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: _handleSubmit,
                                  child: Container(
                                    height: 44,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      'Save Doctor',
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    final colors = context.colors;
    final items = widget.departments;
    final hasItems = items.isNotEmpty;
    final currentVal = hasItems
        ? (items.contains(_selectedSpecialty) ? _selectedSpecialty : items.first)
        : null;

    return DoctorLabeledField(
      label: 'Department',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colors.border,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                value: currentVal,
                isExpanded: true,
                dropdownColor: colors.surfaceElevated,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.textMuted,
                  size: 20,
                ),
                hint: Text(
                  hasItems ? 'Select Department' : 'No assigned departments',
                  style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
                ),
                style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
                onChanged: hasItems
                    ? (val) {
                        if (val != null) setState(() => _selectedSpecialty = val);
                      }
                    : null,
                items: items.map((dept) {
                  return DropdownMenuItem<String>(
                    value: dept,
                    child: Text(
                      '🩺 $dept',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (!hasItems) ...[
            const SizedBox(height: 4),
            Text(
              'No departments assigned by Platform Admin yet',
              style: GoogleFonts.inter(fontSize: 11, color: colors.warning),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomField() {
    final colors = context.colors;
    return DoctorLabeledField(
      label: 'Consultation Room',
      child: TextFormField(
        controller: _roomController,
        style: GoogleFonts.inter(fontSize: 13.5, color: colors.textPrimary),
        decoration: _inputDecoration(
          hint: 'e.g. Room 2',
          prefixIcon: Icons.meeting_room_outlined,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    final colors = context.colors;
    return DoctorLabeledField(
      label: 'Work Email',
      child: TextFormField(
        controller: _emailController,
        style: GoogleFonts.inter(fontSize: 13.5, color: colors.textPrimary),
        decoration: _inputDecoration(
          hint: 'doctor@clinic.com',
          prefixIcon: Icons.mail_outline_rounded,
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _buildPhoneField() {
    final colors = context.colors;
    return DoctorLabeledField(
      label: 'Phone',
      child: TextFormField(
        controller: _phoneController,
        style: GoogleFonts.inter(fontSize: 13.5, color: colors.textPrimary),
        decoration: _inputDecoration(
          hint: '+91 98450 00000',
          prefixIcon: Icons.phone_outlined,
        ),
        keyboardType: TextInputType.phone,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? prefixIcon}) {
    final colors = context.colors;
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: colors.textMuted)
          : null,
      filled: true,
      fillColor: colors.surfaceSecondary,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: border(colors.border),
      focusedBorder: border(colors.primary, 1.5),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error, 1.5),
      border: border(colors.border),
    );
  }
}
