import 'dart:convert';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/patient_profile_entity.dart';
import '../widgets/profile_avatar.dart';
 
typedef EditProfileSave = void Function({
  required String name,
  required String email,
  required String phone,
  required String initials,
  int? age,
  String? gender,
  String? bloodGroup,
  String? photoBase64,
}); 

/// Full-screen "Edit Profile" page.
class EditProfileScreen extends StatefulWidget {
  final PatientProfileEntity profile;
  final EditProfileSave onSave;

  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.onSave,
  });

  static Future<void> open(
    BuildContext context, {
    required PatientProfileEntity profile,
    required EditProfileSave onSave,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditProfileScreen(profile: profile, onSave: onSave),
      ),
    );
  }

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const List<String> _bloodGroupOptions = [
    'A+ Positive',
    'A- Negative',
    'B+ Positive',
    'B- Negative',
    'AB+ Positive',
    'AB- Negative',
    'O+ Positive',
    'O- Negative',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  String? _gender;
  String? _bloodGroup;
  String? _photoBase64;
  bool _pickingPhoto = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.name)..addListener(() => setState(() {}));
    _ageController = TextEditingController(text: p.age?.toString() ?? '');
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
    _gender = _genderOptions.contains(p.gender) ? p.gender : null;
    _bloodGroup = _bloodGroupOptions.contains(p.bloodGroup) ? p.bloodGroup : null;
    _photoBase64 = p.photoBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ───────────────────────── Photo picking ─────────────────────────

  bool get _isMobile =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// Downscales to keep the stored image small (it is saved with the profile).
  Future<String> _encode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final src = frame.image;

    // Center-crop to a square so the avatar circle is always completely filled.
    final side = src.width < src.height ? src.width : src.height;
    final srcRect = Rect.fromLTWH((src.width - side) / 2, (src.height - side) / 2, side.toDouble(), side.toDouble());
    const out = 320.0;
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawImageRect(
      src,
      srcRect,
      const Rect.fromLTWH(0, 0, out, out),
      Paint()..filterQuality = FilterQuality.medium,
    );
    final squared = await recorder.endRecording().toImage(out.toInt(), out.toInt());
    final data = await squared.toByteData(format: ui.ImageByteFormat.png);
    src.dispose();
    squared.dispose();
    return base64Encode(data!.buffer.asUint8List());
  }

  Future<void> _pick(Future<Uint8List?> Function() reader) async {
    if (_pickingPhoto) return;
    setState(() => _pickingPhoto = true);
    try {
      final bytes = await reader();
      if (bytes == null) return;
      String encoded;
      try {
        encoded = await _encode(bytes);
      } catch (e) {
        debugPrint('Photo resize failed, using original bytes: $e');
        if (bytes.length > 700 * 1024) rethrow;
        encoded = base64Encode(bytes);
      }
      if (mounted) setState(() => _photoBase64 = encoded);
    } catch (e, st) {
      debugPrint('Photo pick failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load that image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  Future<Uint8List?> _fromImagePicker(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source);
    return file?.readAsBytes();
  }

  Future<Uint8List?> _fromComputer() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Select a profile photo',
      type: FileType.image,
    );
    return file?.readAsBytes();
  }

  void _showPhotoOptions() {
    // Windows / web / other desktops: no menu, go straight to the file picker.
    if (!_isMobile) {
      _pick(_fromComputer);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        Widget option(IconData icon, String label, VoidCallback onTap) => ListTile(
              leading: Icon(icon, color: AppColors.darkInk),
              title: Text(label, style: const TextStyle(color: AppColors.darkInk, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onTap();
              },
            );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              option(Icons.photo_library_outlined, 'Choose from gallery',
                  () => _pick(() => _fromImagePicker(ImageSource.gallery))),
              if (_isMobile)
                option(Icons.photo_camera_outlined, 'Take a photo',
                    () => _pick(() => _fromImagePicker(ImageSource.camera))),
              option(Icons.folder_open_rounded, 'Choose from files', () => _pick(_fromComputer)),
              if (_photoBase64 != null)
                option(Icons.delete_outline_rounded, 'Remove photo', () => setState(() => _photoBase64 = null)),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── Save ─────────────────────────

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return widget.profile.initials;
    if (parts.length > 1) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    widget.onSave(
      name: name,
      email: email.isEmpty ? widget.profile.email : email,
      phone: phone.isEmpty ? widget.profile.phone : phone,
      initials: _initialsFor(name),
      age: int.tryParse(_ageController.text.trim()),
      gender: _gender,
      bloodGroup: _bloodGroup ?? widget.profile.bloodGroup,
      photoBase64: _photoBase64,
    );
    Navigator.of(context).pop();
  }

  // ───────────────────────── UI ─────────────────────────

  InputDecoration _decoration(String label, IconData icon, {String? hint}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      prefixIconColor: AppColors.darkInkMuted,
      labelStyle: const TextStyle(color: AppColors.darkInkMuted),
      hintStyle: const TextStyle(color: AppColors.darkInkFaint),
      filled: true,
      fillColor: AppColors.darkSurface,
      border: border(AppColors.darkBorder),
      enabledBorder: border(AppColors.darkBorder),
      focusedBorder: border(AppColors.primary, 1.5),
    );
  }

  Widget _card({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF38BDF8)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: AppColors.darkInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> options,
    required String? value,
    required IconData Function(String option) optionIcon,
    required Color optionColor,
    required ValueChanged<String?> onChanged,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    return DropdownMenu<String>(
      // Full width, and the list opens *below* the field.
      expandedInsets: EdgeInsets.zero,
      initialSelection: value,
      label: Text(label),
      hintText: hint,
      leadingIcon: Icon(icon, size: 20),
      trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded),
      selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up_rounded),
      requestFocusOnTap: false,
      enableFilter: false,
      menuHeight: 280,
      textStyle: const TextStyle(fontSize: 14, color: AppColors.darkInk, fontWeight: FontWeight.w600),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgApp,
        labelStyle: const TextStyle(color: AppColors.darkInkMuted),
        hintStyle: const TextStyle(color: AppColors.darkInkFaint),
        prefixIconColor: AppColors.darkInkMuted,
        suffixIconColor: AppColors.darkInkMuted,
        border: border(AppColors.darkBorder),
        enabledBorder: border(AppColors.darkBorder),
        focusedBorder: border(AppColors.primary, 1.5),
      ),
      menuStyle: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.darkSurface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.darkBorder),
          ),
        ),
      ),
      dropdownMenuEntries: [
        for (final o in options)
          DropdownMenuEntry<String>(
            value: o,
            label: o,
            leadingIcon: Icon(optionIcon(o), size: 18, color: optionColor),
            trailingIcon: o == value ? const Icon(Icons.check_rounded, size: 18, color: Color(0xFF38BDF8)) : null,
            style: ButtonStyle(
              foregroundColor: const WidgetStatePropertyAll(AppColors.darkInk),
              textStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: 14, fontWeight: o == value ? FontWeight.w800 : FontWeight.w500),
              ),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
          ),
      ],
      onSelected: onChanged,
    );
  }

  IconData _genderIcon(String g) {
    switch (g) {
      case 'Male':
        return Icons.male_rounded;
      case 'Female':
        return Icons.female_rounded;
      case 'Other':
        return Icons.transgender_rounded;
      default:
        return Icons.visibility_off_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 14, color: AppColors.darkInk, fontWeight: FontWeight.w500);
    final name = _nameController.text.trim();

    return Scaffold(
      backgroundColor: AppColors.darkBgApp,
      appBar: AppBar(
        backgroundColor: AppColors.darkBgApp,
        foregroundColor: AppColors.darkInk,
        elevation: 0,
        centerTitle: true,
        title: const Text('Edit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header banner with avatar
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _showPhotoOptions,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ProfileAvatar(
                                        name: _nameController.text,
                                        photoBase64: _photoBase64,
                                        size: 104,
                                        fontSize: 42,
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.25),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      if (_pickingPhoto)
                                        const Positioned.fill(
                                          child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                                        ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.25),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.camera_alt_rounded, size: 17, color: AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  name.isEmpty ? 'Your name' : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap the photo to change it',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                                ),
                                if (_photoBase64 != null && !_isMobile)
                                  TextButton(
                                    onPressed: () => setState(() => _photoBase64 = null),
                                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                                    child: const Text('Remove photo'),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          _card(
                            title: 'PERSONAL DETAILS',
                            icon: Icons.person_rounded,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                style: textStyle,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: _decoration('Full name', Icons.person_outline_rounded, hint: 'Your full name'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _ageController,
                                style: textStyle,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: _decoration('Age', Icons.cake_outlined, hint: 'Your age'),
                                validator: (v) {
                                  final t = v?.trim() ?? '';
                                  if (t.isEmpty) return null;
                                  final n = int.tryParse(t);
                                  if (n == null || n < 0 || n > 120) return 'Enter an age between 0 and 120';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _dropdown(
                                label: 'Gender',
                                hint: 'Select gender',
                                icon: Icons.wc_rounded,
                                options: _genderOptions,
                                value: _gender,
                                optionIcon: _genderIcon,
                                optionColor: const Color(0xFF38BDF8),
                                onChanged: (v) => setState(() => _gender = v),
                              ),
                              const SizedBox(height: 16),
                              _dropdown(
                                label: 'Blood group',
                                hint: 'Select blood group',
                                icon: Icons.bloodtype_outlined,
                                options: _bloodGroupOptions,
                                value: _bloodGroup,
                                optionIcon: (_) => Icons.water_drop_rounded,
                                optionColor: const Color(0xFFEF4444),
                                onChanged: (v) => setState(() => _bloodGroup = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _card(
                            title: 'CONTACT',
                            icon: Icons.contact_phone_rounded,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                style: textStyle,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _decoration('Email address', Icons.mail_outline_rounded, hint: 'name@email.com'),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                style: textStyle,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                decoration: _decoration('Phone number', Icons.phone_outlined, hint: '+91 00000 00000'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: AppColors.darkBgApp,
                border: Border(top: BorderSide(color: AppColors.darkBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkInkMuted)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('Save changes',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
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
}
