import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_ui_kit.dart';

class EditDoctorProfileDialog extends StatefulWidget {
  final ClinicDoctorProfileEntity doctor;
  final List<String> departments;
  final ValueChanged<ClinicDoctorProfileEntity> onSave;

  const EditDoctorProfileDialog({
    super.key,
    required this.doctor,
    required this.departments,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required ClinicDoctorProfileEntity doctor,
    required List<String> departments,
    required ValueChanged<ClinicDoctorProfileEntity> onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: EditDoctorProfileDialog(
          doctor: doctor,
          departments: departments,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  State<EditDoctorProfileDialog> createState() => _EditDoctorProfileDialogState();
}

class _EditDoctorProfileDialogState extends State<EditDoctorProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  late final TextEditingController _nameController;
  late final TextEditingController _expController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _roomController;

  late String _selectedDept;
  late String _selectedEmployment;
  late List<String> _selectedQuals;
  late String _photoUrl;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    final d = widget.doctor;
    _nameController = TextEditingController(text: d.name);
    _selectedQuals = d.qualifications
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    _photoUrl = d.photoUrl;
    _photoBytes = _decodeDataUri(d.photoUrl);
    _expController = TextEditingController(text: d.experienceYears > 0 ? d.experienceYears.toString() : '');
    _emailController = TextEditingController(text: d.email);
    _phoneController = TextEditingController(text: d.phone);
    _roomController = TextEditingController(text: d.room);

    _selectedDept = widget.departments.contains(d.department)
        ? d.department
        : (widget.departments.isNotEmpty ? widget.departments.first : 'General Medicine');

    _selectedEmployment = d.employmentType.isNotEmpty ? d.employmentType : 'Full-time';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _expController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updated = widget.doctor.copyWith(
      name: _nameController.text.trim(),
      department: _selectedDept,
      qualifications: _selectedQuals.join(', '),
      experienceYears: int.tryParse(_expController.text.trim()) ?? 0,
      employmentType: _selectedEmployment,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      photoUrl: _photoUrl,
      room: _roomController.text.trim(),
      bio: '',
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  String? _required(String? v) => v == null || v.trim().isEmpty ? 'Required' : null;

  String? _validateEmail(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t) ? null : 'Enter a valid email';
  }

  String? _validatePhone(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    final digits = t.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15 ? null : 'Enter a valid phone number';
  }

  String? _validateExperience(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n != null && n > 70) return 'Max 70 years';
    return null;
  }

  Widget _textField(
    BuildContext context,
    TextEditingController controller, {
    String? hint,
    IconData? icon,
    String? suffix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    TextInputAction action = TextInputAction.next,
    VoidCallback? onSubmitted,
  }) {
    final colors = context.colors;
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
      cursorColor: colors.info,
      decoration: doctorInputDecoration(context: context, hint: hint, prefixIcon: icon, suffixText: suffix),
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      textInputAction: action,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
    );
  }

  Widget _dropdown(
    BuildContext context, {
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    final colors = context.colors;
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 17, color: colors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                value: items.contains(value) ? value : items.first,
                isExpanded: true,
                borderRadius: BorderRadius.circular(10),
                dropdownColor: colors.surfaceElevated,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
                style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                items: items
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final depts = widget.departments.isNotEmpty
        ? widget.departments
        : ['General Medicine', 'Dental & Oral Surgery', 'Pediatrics & Child Care', 'Cardiology'];

    const employmentTypes = [
      'Full-time',
      'Part-time',
      'Visiting Consultant',
      'Contract',
    ];

    final digitsOnly = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.08),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                Divider(color: colors.border, height: 1),
                Flexible(
                  child: Scrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileStrip(context),
                          const SizedBox(height: 20),
                          _buildSection(
                            context,
                            icon: Icons.medical_services_outlined,
                            title: 'PROFESSIONAL',
                            children: [
                              _buildTwoCol(
                                DoctorLabeledField(
                                  label: 'Full Name',
                                  child: _textField(
                                    context,
                                    _nameController,
                                    icon: Icons.person_outline_rounded,
                                    hint: 'e.g. Dr. Anita Rao',
                                    validator: _required,
                                  ),
                                ),
                                DoctorLabeledField(
                                  label: 'Department',
                                  child: _dropdown(
                                    context,
                                    value: _selectedDept,
                                    items: depts,
                                    icon: Icons.apartment_rounded,
                                    onChanged: (v) => setState(() => _selectedDept = v),
                                  ),
                                ),
                              ),
                              DoctorLabeledField(
                                label: 'Qualifications',
                                child: _buildQualificationField(context),
                              ),
                              _buildTwoCol(
                                DoctorLabeledField(
                                  label: 'Experience',
                                  child: _textField(
                                    context,
                                    _expController,
                                    icon: Icons.timeline_rounded,
                                    hint: 'e.g. 5',
                                    suffix: 'years',
                                    keyboardType: TextInputType.number,
                                    formatters: digitsOnly,
                                    validator: _validateExperience,
                                  ),
                                ),
                                DoctorLabeledField(
                                  label: 'Employment Type',
                                  child: _dropdown(
                                    context,
                                    value: _selectedEmployment,
                                    items: employmentTypes,
                                    icon: Icons.work_outline_rounded,
                                    onChanged: (v) => setState(() => _selectedEmployment = v),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSection(
                            context,
                            icon: Icons.contact_phone_outlined,
                            title: 'CONTACT & CONSULTATION',
                            children: [
                              _buildTwoCol(
                                DoctorLabeledField(
                                  label: 'Email',
                                  child: _textField(
                                    context,
                                    _emailController,
                                    icon: Icons.mail_outline_rounded,
                                    hint: 'doctor@clinic.com',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: _validateEmail,
                                  ),
                                ),
                                DoctorLabeledField(
                                  label: 'Phone',
                                  child: _textField(
                                    context,
                                    _phoneController,
                                    icon: Icons.phone_outlined,
                                    hint: '+91 98450 00000',
                                    keyboardType: TextInputType.phone,
                                    formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))],
                                    validator: _validatePhone,
                                  ),
                                ),
                              ),
                              DoctorLabeledField(
                                label: 'Consultation Room',
                                child: _textField(
                                  context,
                                  _roomController,
                                  icon: Icons.meeting_room_outlined,
                                  hint: 'e.g. Room 1',
                                  action: TextInputAction.done,
                                  onSubmitted: _handleSubmit,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(color: colors.border, height: 1),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 18),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: DoctorColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: DoctorColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Doctor Profile',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Update professional, contact and consultation details',
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            icon: Icon(Icons.close_rounded, size: 20, color: colors.textMuted),
            style: IconButton.styleFrom(
              backgroundColor: colors.surfaceSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static const _qualificationOptions = [
    'MBBS',
    'MD',
    'MS',
    'BDS',
    'MDS',
    'BAMS',
    'BHMS',
    'DNB',
    'DM',
    'MCh',
    'DGO',
    'DCH',
    'DMRD',
    'FRCS',
    'MRCP',
    'PhD',
  ];

  Future<void> _pickQualifications(BuildContext context) async {
    final options = {..._qualificationOptions, ..._selectedQuals}.toList();
    final picked = _selectedQuals.toSet();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final dialogColors = ctx.colors;
          return Dialog(
            backgroundColor: dialogColors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: dialogColors.border),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select qualifications',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: dialogColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final q in options)
                              FilterChip(
                                label: Text(q),
                                selected: picked.contains(q),
                                showCheckmark: true,
                                checkmarkColor: dialogColors.info,
                                selectedColor: dialogColors.infoTint,
                                backgroundColor: dialogColors.surfaceSecondary,
                                side: BorderSide(
                                  color: picked.contains(q) ? dialogColors.info : dialogColors.border,
                                ),
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: picked.contains(q) ? dialogColors.info : dialogColors.textPrimary,
                                ),
                                onSelected: (on) => setLocal(() {
                                  on ? picked.add(q) : picked.remove(q);
                                }),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Cancel', style: GoogleFonts.inter(color: dialogColors.textMuted)),
                        ),
                        const SizedBox(width: 8),
                        DoctorGradientButton(
                          label: 'Done',
                          height: 38,
                          onPressed: () => Navigator.of(ctx).pop(
                            options.where(picked.contains).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (result != null) setState(() => _selectedQuals = result);
  }

  Widget _buildQualificationField(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _pickQualifications(context),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.school_outlined, size: 17, color: colors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: _selectedQuals.isEmpty
                  ? Text(
                      'Select qualifications',
                      style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final q in _selectedQuals)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.infoTint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              q,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.info,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  static Uint8List? _decodeDataUri(String uri) {
    if (!uri.startsWith('data:image')) return null;
    final comma = uri.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(uri.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 60,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 200 * 1024) {
        _showPhotoError('Photo is too large (${(bytes.length / 1024).round()} KB). Choose one under 200 KB.');
        return;
      }
      final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';
      final type = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoUrl = 'data:$type;base64,${base64Encode(bytes)}';
      });
    } catch (_) {
      _showPhotoError('Could not load that image. Please try another file.');
    }
  }

  void _showPhotoError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildProfileStrip(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.info.withValues(alpha: 0.35)),
            ),
            child: _photoBytes != null
                ? Image.memory(_photoBytes!, width: 52, height: 52, fit: BoxFit.cover, gaplessPlayback: true)
                : Text(
                    widget.doctor.initials,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colors.info,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'JPG or PNG, max 200 KB',
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textSubtle),
                ),
              ],
            ),
          ),
          if (_photoBytes != null) ...[
            IconButton(
              tooltip: 'Remove photo',
              icon: Icon(Icons.delete_outline_rounded, size: 18, color: colors.textMuted),
              onPressed: () => setState(() {
                _photoBytes = null;
                _photoUrl = '';
              }),
            ),
            const SizedBox(width: 4),
          ],
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.upload_rounded, size: 15),
            label: Text(
              _photoBytes == null ? 'Upload photo' : 'Change photo',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.border),
              backgroundColor: colors.surfaceElevated,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.infoTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: colors.info),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colors.info,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Full name is required',
              style: GoogleFonts.inter(fontSize: 11, color: colors.textSubtle),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.border),
              backgroundColor: colors.surfaceSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          DoctorGradientButton(
            label: 'Save Changes',
            icon: Icons.check_rounded,
            onPressed: _handleSubmit,
            height: 42,
          ),
        ],
      ),
    );
  }

  Widget _buildTwoCol(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            children: [
              left,
              const SizedBox(height: 14),
              right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 14),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
