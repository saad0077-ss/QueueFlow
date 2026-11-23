import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformAddUserDialog extends StatefulWidget {
  final List<Map<String, String>> availableClinics;
  final Future<void> Function({
    required String name,
    required String phone,
    required String email,
    String? age,
    String? gender,
    String? bloodGroup,
    String? clinicId,
    String? clinicName,
    String? emergencyContact,
    String? notes,
  })
  onSave;

  const PlatformAddUserDialog({
    super.key,
    required this.availableClinics,
    required this.onSave,
  });

  @override
  State<PlatformAddUserDialog> createState() => _PlatformAddUserDialogState();
}

class _PlatformAddUserDialogState extends State<PlatformAddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _notesController = TextEditingController();

  String _gender = 'Male';
  String _bloodGroup = 'O+';
  String? _selectedClinicId;
  String? _selectedClinicName;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to general platform patient (null clinic)
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _emergencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onSave(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        age: _ageController.text.trim().isNotEmpty
            ? _ageController.text.trim()
            : null,
        gender: _gender,
        bloodGroup: _bloodGroup,
        clinicId: _selectedClinicId,
        clinicName: _selectedClinicName,
        emergencyContact: _emergencyController.text.trim().isNotEmpty
            ? _emergencyController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Failed to register user: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 820),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0072FF).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Color(0xFF0072FF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Register New User',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withAlpha(60),
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Name & Phone row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              colors: colors,
                              controller: _nameController,
                              label: 'Full Name *',
                              hint: 'e.g. Rahul Varma',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Name is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              colors: colors,
                              controller: _phoneController,
                              label: 'Mobile Number *',
                              hint: '+91 98765 00000',
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Phone is required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Email
                      _buildTextField(
                        colors: colors,
                        controller: _emailController,
                        label: 'Email Address *',
                        hint: 'patient@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@')) return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Demographics row: Age, Gender, Blood Group
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              colors: colors,
                              controller: _ageController,
                              label: 'Age',
                              hint: '32',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gender',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceSecondary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _gender,
                                      isExpanded: true,
                                      dropdownColor: colors.surface,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: colors.textPrimary,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Female',
                                          child: Text('Female'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Male',
                                          child: Text('Male'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Other',
                                          child: Text('Other'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _gender = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Blood Group',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceSecondary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _bloodGroup,
                                      isExpanded: true,
                                      dropdownColor: colors.surface,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: colors.textPrimary,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'O+',
                                          child: Text('O+'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'A+',
                                          child: Text('A+'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'B+',
                                          child: Text('B+'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'AB+',
                                          child: Text('AB+'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'O-',
                                          child: Text('O-'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'A-',
                                          child: Text('A-'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'B-',
                                          child: Text('B-'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'AB-',
                                          child: Text('AB-'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _bloodGroup = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Primary Clinic Dropdown (Optional)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preferred Clinic (Optional)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: colors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedClinicId,
                                isExpanded: true,
                                dropdownColor: colors.surface,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: colors.textPrimary,
                                ),
                                hint: Text(
                                  'None (General Platform Patient)',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: colors.textMuted,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'None (General Platform Patient)',
                                    ),
                                  ),
                                  ...widget.availableClinics.map((c) {
                                    return DropdownMenuItem<String>(
                                      value: c['id'],
                                      child: Text(c['name']!),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedClinicId = val;
                                    _selectedClinicName = val != null
                                        ? widget.availableClinics.firstWhere(
                                            (c) => c['id'] == val,
                                            orElse: () => {
                                              'id': '',
                                              'name': '',
                                            },
                                          )['name']
                                        : null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Emergency Contact
                      _buildTextField(
                        colors: colors,
                        controller: _emergencyController,
                        label: 'Emergency Contact (Optional)',
                        hint: 'Name & Phone (e.g. Priya Varma +91 98450 11223)',
                      ),
                      const SizedBox(height: 14),

                      // Clinical / Admin Notes
                      _buildTextField(
                        colors: colors,
                        controller: _notesController,
                        label: 'Clinical / Administrative Notes (Optional)',
                        hint: 'Patient background or relevant notes...',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Divider(height: 1, color: colors.border),
            // Footer Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textMuted,
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0072FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Register User Account',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required AppColorsExtension colors,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 12.5,
              color: colors.textMuted,
            ),
            filled: true,
            fillColor: colors.surfaceSecondary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0072FF)),
            ),
          ),
        ),
      ],
    );
  }
}
