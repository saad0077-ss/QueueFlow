import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/clinic_location_entity.dart';
import '../../domain/entities/clinic_profile_entity.dart';
import 'clinic_profile_header.dart';
import 'profile_location_summary_card.dart';

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
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _descCtrl;
  Uint8List? _pickedBytes;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _addressCtrl = TextEditingController(text: _resolvedAddress);
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _descCtrl = TextEditingController(text: widget.profile.description);
  }

  /// The address configured in the Location tab, falling back to the stored profile address.
  String get _resolvedAddress {
    final fromLocation = widget.location.fullAddress;
    return fromLocation.isNotEmpty ? fromLocation : widget.profile.address;
  }

  @override
  void didUpdateWidget(covariant ClinicProfilePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location || oldWidget.profile.address != widget.profile.address) {
      final address = _resolvedAddress;
      if (_addressCtrl.text != address) _addressCtrl.text = address;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600, imageQuality: 70);
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
        _field('Clinic name', _nameCtrl),
        const SizedBox(height: 14),
        _field(
          'Address',
          _addressCtrl,
          readOnly: true,
          helperText: 'Filled from the Location tab. Use "Configure Location" below to change it.',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _field('Contact phone', _phoneCtrl)),
            const SizedBox(width: 14),
            Expanded(child: _field('Email', _emailCtrl)),
          ],
        ),
        const SizedBox(height: 14),
        _field('Description', _descCtrl, maxLines: 3),
        const SizedBox(height: 20),
        ProfileLocationSummaryCard(
          location: widget.location,
          onConfigureLocation: widget.onJumpToLocationTab,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            widget.onSave(widget.profile.copyWith(
              name: _nameCtrl.text.trim(),
              address: _addressCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              description: _descCtrl.text.trim(),
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Save Changes', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, bool readOnly = false, String? helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          readOnly: readOnly,
          style: GoogleFonts.inter(fontSize: 13, color: readOnly ? const Color(0xFFCBD5E1) : Colors.white),
          decoration: InputDecoration(
            hintText: readOnly ? 'No address set yet' : null,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
            helperText: helperText,
            helperStyle: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
            suffixIcon: readOnly ? const Icon(Icons.lock_outline_rounded, size: 15, color: Color(0xFF64748B)) : null,
            filled: true,
            fillColor: const Color(0xFF162238),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
      ],
    );
  }
}
