import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Circular doctor avatar. Shows the uploaded photo (data URI or network URL)
/// and falls back to [fallback] (usually the initials) when there is none.
class DoctorPhotoAvatar extends StatelessWidget {
  final String photoUrl;
  final double radius;
  final Color backgroundColor;
  final Widget fallback;
  final Color borderColor;
  final double borderWidth;

  const DoctorPhotoAvatar({
    super.key,
    required this.photoUrl,
    required this.radius,
    required this.backgroundColor,
    required this.fallback,
    required this.borderColor,
    this.borderWidth = 2,
  });

  /// Returns 1-2 uppercase initials for a doctor's display name.
  static String initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'DR';
  }

  static Uint8List? _decode(String url) {
    if (!url.startsWith('data:image')) return null;
    final comma = url.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(url.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final fallbackAvatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: fallback,
    );

    final bytes = _decode(photoUrl);
    Widget? image;
    if (bytes != null) {
      image = Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallbackAvatar,
      );
    } else if (photoUrl.startsWith('http')) {
      image = Image.network(
        photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallbackAvatar,
      );
    }
    final avatar = image == null ? fallbackAvatar : ClipOval(child: image);
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: avatar,
    );
  }
}
