import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/clinic_location_entity.dart';
import '../../domain/entities/clinic_profile_entity.dart';
import 'clinic_profile_form.dart';
import 'clinic_profile_header.dart';

class ClinicProfilePanel extends StatefulWidget {
  final ClinicProfileEntity profile;
  final ClinicLocationEntity location;
  final VoidCallback onJumpToLocationTab;
  final ValueChanged<ClinicProfileEntity> onSave;
  final void Function(Uint8List bytes, String fileName) onImagePicked;
  final bool isUploadingImage;

  const ClinicProfilePanel({
    super.key,
    required this.profile,
    required this.location,
    required this.onJumpToLocationTab,
    required this.onSave,
    required this.onImagePicked,
    this.isUploadingImage = false,
  });

  @override
  State<ClinicProfilePanel> createState() => _ClinicProfilePanelState();
}

class _ClinicProfilePanelState extends State<ClinicProfilePanel> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _adminNameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _descCtrl;
  Uint8List? _pickedBytes;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _adminNameCtrl = TextEditingController(text: widget.profile.adminName);
    _addressCtrl = TextEditingController(text: _resolvedAddress);
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _descCtrl = TextEditingController(text: widget.profile.description);
  }

  String get _resolvedAddress {
    final fromLoc = widget.location.fullAddress;
    return fromLoc.isNotEmpty ? fromLoc : widget.profile.address;
  }

  @override
  void didUpdateWidget(covariant ClinicProfilePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location ||
        oldWidget.profile.address != widget.profile.address) {
      final addr = _resolvedAddress;
      if (_addressCtrl.text != addr) _addressCtrl.text = addr;
    }
    if (oldWidget.profile.adminName != widget.profile.adminName) {
      if (_adminNameCtrl.text != widget.profile.adminName) {
        _adminNameCtrl.text = widget.profile.adminName;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _adminNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 70,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _pickedBytes = bytes);
    widget.onImagePicked(bytes, file.name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClinicProfileHeader(
          clinicName: widget.profile.name,
          imageUrl: widget.profile.imageUrl,
          imageBytes: widget.profile.imageBytes,
          pickedBytes: _pickedBytes,
          isUploadingImage: widget.isUploadingImage,
          onPickImage: _pickImage,
        ),
        const SizedBox(height: 20),
        ClinicProfileForm(
          nameCtrl: _nameCtrl,
          adminNameCtrl: _adminNameCtrl,
          addressCtrl: _addressCtrl,
          phoneCtrl: _phoneCtrl,
          emailCtrl: _emailCtrl,
          descCtrl: _descCtrl,
          location: widget.location,
          onConfigureLocation: widget.onJumpToLocationTab,
          onSave: () => widget.onSave(
            widget.profile.copyWith(
              name: _nameCtrl.text.trim(),
              adminName: _adminNameCtrl.text.trim(),
              address: _addressCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              description: _descCtrl.text.trim(),
            ),
          ),
        ),
      ],
    );
  }
}
