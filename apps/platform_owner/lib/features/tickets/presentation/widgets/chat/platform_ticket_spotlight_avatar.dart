import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_photo_resolver.dart';

class PlatformTicketSpotlightAvatar extends StatefulWidget {
  final PlatformSupportTicketEntity ticket;
  final String initials;
  final ImageProvider? avatarProvider;
  final double radius;

  const PlatformTicketSpotlightAvatar({
    super.key,
    required this.ticket,
    required this.initials,
    this.avatarProvider,
    this.radius = 22,
  });

  @override
  State<PlatformTicketSpotlightAvatar> createState() =>
      _PlatformTicketSpotlightAvatarState();
}

class _PlatformTicketSpotlightAvatarState
    extends State<PlatformTicketSpotlightAvatar> {
  String? _resolvedPhoto;

  @override
  void initState() {
    super.initState();
    _initPhoto();
  }

  @override
  void didUpdateWidget(PlatformTicketSpotlightAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticket.patientPhoto != widget.ticket.patientPhoto ||
        oldWidget.ticket.patientId != widget.ticket.patientId ||
        oldWidget.ticket.patientEmail != widget.ticket.patientEmail) {
      _initPhoto();
    }
  }

  void _initPhoto() {
    _resolvedPhoto = widget.ticket.patientPhoto;
    if (_resolvedPhoto == null || _resolvedPhoto!.trim().isEmpty) {
      PlatformTicketPhotoResolver.resolvePhoto(
        photo: widget.ticket.patientPhoto,
        patientId: widget.ticket.patientId,
        patientEmail: widget.ticket.patientEmail,
        patientPhone: widget.ticket.patientPhone,
        patientName: widget.ticket.patientName,
      ).then((p) {
        if (mounted && p.isNotEmpty) setState(() => _resolvedPhoto = p);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = widget.radius * 2;
    final photo = _resolvedPhoto;
    final bytes = PlatformTicketPhotoResolver.decode(photo);

    Widget? image;
    if (widget.avatarProvider != null) {
      image = Image(
        image: widget.avatarProvider!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    } else if (bytes != null) {
      image = Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallback(),
      );
    } else if (photo != null && photo.trim().startsWith('http')) {
      image = Image.network(
        photo.trim(),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
          ),
          child: ClipOval(child: image ?? _fallback()),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF0284C7),
      alignment: Alignment.center,
      child: Text(
        widget.initials.isNotEmpty ? widget.initials : 'PT',
        style: GoogleFonts.inter(
          fontSize: widget.radius * 0.72,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
