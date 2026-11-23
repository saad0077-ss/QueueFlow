import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'platform_ticket_photo_resolver.dart';

class PlatformTicketPatientAvatar extends StatefulWidget {
  final String initials;
  final String? photo;
  final String? patientId;
  final String? patientEmail;
  final String? patientPhone;
  final String? patientName;
  final ImageProvider? avatarProvider;
  final double size;

  const PlatformTicketPatientAvatar({
    super.key,
    required this.initials,
    this.photo,
    this.patientId,
    this.patientEmail,
    this.patientPhone,
    this.patientName,
    this.avatarProvider,
    this.size = 28,
  });

  @override
  State<PlatformTicketPatientAvatar> createState() =>
      _PlatformTicketPatientAvatarState();
}

class _PlatformTicketPatientAvatarState
    extends State<PlatformTicketPatientAvatar> {
  String? _resolvedPhoto;

  @override
  void initState() {
    super.initState();
    _initPhoto();
  }

  @override
  void didUpdateWidget(PlatformTicketPatientAvatar oldWidget) {
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
      PlatformTicketPhotoResolver.resolvePhoto(
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
    if (widget.avatarProvider != null) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: Image(
            image: widget.avatarProvider!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _fallback(),
          ),
        ),
      );
    }

    final photo = _resolvedPhoto;
    final bytes = PlatformTicketPhotoResolver.decode(photo);
    final isHttp = photo != null && photo.trim().startsWith('http');

    Widget? image;
    if (bytes != null) {
      image = Image.memory(
        bytes,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallback(),
      );
    } else if (isHttp) {
      image = Image.network(
        photo.trim(),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(child: image ?? _fallback()),
    );
  }

  Widget _fallback() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        color: Color(0xFF0284C7),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        widget.initials,
        style: GoogleFonts.inter(
          fontSize: widget.size * 0.36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
