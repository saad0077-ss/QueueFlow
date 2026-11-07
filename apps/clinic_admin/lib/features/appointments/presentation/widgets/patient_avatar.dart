import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Circular patient avatar: the patient's profile photo (raw base64, data URI
/// or http URL) with a gradient-initials fallback.
class PatientAvatar extends StatelessWidget {
  final String photo;
  final String initials;
  final double size;

  const PatientAvatar({
    super.key,
    required this.photo,
    required this.initials,
    this.size = 36,
  });

  static Uint8List? _decode(String v) {
    var s = v.trim();
    if (s.isEmpty || s.startsWith('http')) return null;
    final comma = s.indexOf(',');
    if (s.startsWith('data:') && comma >= 0) s = s.substring(comma + 1);
    try {
      return base64Decode(s);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [colors.primary, colors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );

    Widget? image;
    final bytes = _decode(photo);
    if (bytes != null) {
      image = Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
      );
    } else if (photo.trim().startsWith('http')) {
      image = Image.network(
        photo.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (image == null) return fallback;
    return ClipOval(child: SizedBox(width: size, height: size, child: image));
  }
}
