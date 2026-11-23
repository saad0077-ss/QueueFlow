import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_ticket_photo_resolver.dart';

class ClinicTicketPatientAvatar extends StatefulWidget {
  final String? photo;
  final String initials;
  final String? patientId;
  final String? patientEmail;
  final String? patientPhone;
  final String? patientName;
  final double size;

  const ClinicTicketPatientAvatar({
    super.key,
    required this.photo,
    required this.initials,
    this.patientId,
    this.patientEmail,
    this.patientPhone,
    this.patientName,
    this.size = 28,
  });

  @override
  State<ClinicTicketPatientAvatar> createState() =>
      _ClinicTicketPatientAvatarState();
}

class _ClinicTicketPatientAvatarState extends State<ClinicTicketPatientAvatar> {
  String? _resolvedPhoto;

  @override
  void initState() {
    super.initState();
    _initPhoto();
  }

  @override
  void didUpdateWidget(ClinicTicketPatientAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo != widget.photo ||
        oldWidget.patientId != widget.patientId ||
        oldWidget.patientEmail != widget.patientEmail) {
      _initPhoto();
    }
  }

  void _initPhoto() {
    _resolvedPhoto = widget.photo;
    if (_resolvedPhoto == null || _resolvedPhoto!.trim().isEmpty) {
      ClinicTicketPhotoResolver.resolvePhoto(
        photo: widget.photo,
        patientId: widget.patientId,
        patientEmail: widget.patientEmail,
        patientPhone: widget.patientPhone,
        patientName: widget.patientName,
      ).then((p) {
        if (mounted && p.isNotEmpty) setState(() => _resolvedPhoto = p);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final photo = _resolvedPhoto;
    final bytes = ClinicTicketPhotoResolver.decode(photo);
    final isHttp = photo != null && photo.trim().startsWith('http');

    Widget? image;
    if (bytes != null) {
      image = Image.memory(
        bytes,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallback(colors),
      );
    } else if (isHttp) {
      image = Image.network(
        photo.trim(),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(colors),
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(child: image ?? _fallback(colors)),
    );
  }

  Widget _fallback(AppColorsExtension colors) {
    return Container(
      color: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
      alignment: Alignment.center,
      child: Text(
        widget.initials,
        style: GoogleFonts.inter(
          fontSize: widget.size * 0.36,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0284C7),
        ),
      ),
    );
  }
}
