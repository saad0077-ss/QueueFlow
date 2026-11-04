import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Circular avatar: shows the user's photo when one is saved, otherwise the
/// first letter of their name.
class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? photoBase64;
  final double size;
  final double fontSize;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.photoBase64,
    required this.size,
    required this.fontSize,
    this.border,
    this.boxShadow,
  });

  static Uint8List? _decode(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decode(photoBase64);
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: border,
        boxShadow: boxShadow,
      ),
      alignment: Alignment.center,
      child: bytes != null
          ? ClipOval(
              child: SizedBox.expand(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => _letter(letter),
                ),
              ),
            )
          : _letter(letter),
    );
  }

  Widget _letter(String letter) => Text(
        letter,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
}
