import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_support_ticket_entity.dart';
import 'clinic_ticket_photo_resolver.dart';

class ClinicTicketSpotlightAvatar extends StatefulWidget {
  final ClinicSupportTicketEntity ticket;
  final String initials;

  const ClinicTicketSpotlightAvatar({
    super.key,
    required this.ticket,
    required this.initials,
  });

  @override
  State<ClinicTicketSpotlightAvatar> createState() =>
      _ClinicTicketSpotlightAvatarState();
}

class _ClinicTicketSpotlightAvatarState
    extends State<ClinicTicketSpotlightAvatar> {
  String? _resolvedPhoto;

  @override
  void initState() {
    super.initState();
    _initPhoto();
  }

  @override
  void didUpdateWidget(ClinicTicketSpotlightAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticket.patientPhoto != widget.ticket.patientPhoto ||
        oldWidget.ticket.patientId != widget.ticket.patientId) {
      _initPhoto();
    }
  }

  void _initPhoto() {
    _resolvedPhoto = widget.ticket.patientPhoto;
    if (_resolvedPhoto == null || _resolvedPhoto!.trim().isEmpty) {
      ClinicTicketPhotoResolver.resolvePhoto(
        photo: widget.ticket.patientPhoto,
        patientId: widget.ticket.patientId,
        patientEmail: widget.ticket.patientEmail,
      ).then((p) {
        if (mounted && p.isNotEmpty) {
          setState(() => _resolvedPhoto = p);
        }
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
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallback(colors),
      );
    } else if (isHttp) {
      image = Image.network(
        photo.trim(),
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(colors),
      );
    }

    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
          ),
          child: ClipOval(child: image ?? _fallback(colors)),
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
                color: colors.isDark ? const Color(0xFF0F172A) : Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallback(AppColorsExtension colors) {
    return Container(
      color: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
      alignment: Alignment.center,
      child: Text(
        widget.initials,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: colors.isDark
              ? const Color(0xFF38BDF8)
              : const Color(0xFF0284C7),
        ),
      ),
    );
  }
}
