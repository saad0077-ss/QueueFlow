import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_avatar_image_loader.dart';

class ClinicListAvatar extends StatefulWidget {
  final String clinicId;
  final String name;
  final String? imageUrl;
  final bool isSelected;
  final AppColorsExtension colors;
  final double size;

  const ClinicListAvatar({
    super.key,
    required this.clinicId,
    required this.name,
    this.imageUrl,
    required this.isSelected,
    required this.colors,
    this.size = 38,
  });

  @override
  State<ClinicListAvatar> createState() => _ClinicListAvatarState();
}

class _ClinicListAvatarState extends State<ClinicListAvatar> {
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant ClinicListAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clinicId != widget.clinicId ||
        oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  void _loadImage() async {
    final img = await ClinicAvatarImageLoader.resolve(
      widget.clinicId,
      widget.imageUrl,
    );
    if (mounted) setState(() => _imageProvider = img);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    if (_imageProvider != null) {
      return Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF2563EB)
                : widget.colors.border,
            width: widget.isSelected ? 1.5 : 1,
          ),
          image: DecorationImage(image: _imageProvider!, fit: BoxFit.cover),
        ),
      );
    }

    final initials = _getInitials(widget.name);
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? const Color(0xFF2563EB)
            : widget.colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isSelected
              ? const Color(0xFF2563EB)
              : widget.colors.border,
          width: widget.isSelected ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            fontSize: s * 0.32,
            fontWeight: FontWeight.w800,
            color: widget.isSelected ? Colors.white : const Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CL';
  }
}
