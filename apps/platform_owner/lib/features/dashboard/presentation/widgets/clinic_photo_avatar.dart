import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Rounded-square avatar showing the photo the clinic admin uploaded in the
/// clinic profile (`clinics/{id}.imageUrl` or `clinic_images/{id}`).
/// Falls back to a gradient with the clinic initials.
class ClinicPhotoAvatar extends StatefulWidget {
  final String clinicId;
  final String name;
  final double size;
  final double radius;
  final List<Color> gradient;
  final double fontSize;
  final String? imageUrl;

  const ClinicPhotoAvatar({
    super.key,
    required this.clinicId,
    required this.name,
    this.size = 42,
    this.radius = 11,
    this.fontSize = 13.5,
    this.gradient = const [Color(0xFF2563EB), Color(0xFF06B6D4)],
    this.imageUrl,
  });

  @override
  State<ClinicPhotoAvatar> createState() => _ClinicPhotoAvatarState();
}

class _ClinicPhotoAvatarState extends State<ClinicPhotoAvatar> {
  static final Map<String, ImageProvider?> _cache = {};
  ImageProvider? _photo;

  @override
  void initState() {
    super.initState();
    _resolveInitialPhoto();
  }

  void _resolveInitialPhoto() {
    _photo = _cache[widget.clinicId];
    if (_photo == null && widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty) {
      final img = widget.imageUrl!.trim();
      if (img.startsWith('http')) {
        _photo = NetworkImage(img);
        _cache[widget.clinicId] = _photo;
      } else if (img.startsWith('data:') || img.length > 100) {
        try {
          final raw = img.contains(',') ? img.split(',').last : img;
          _photo = MemoryImage(Uint8List.fromList(base64Decode(raw)));
          _cache[widget.clinicId] = _photo;
        } catch (_) {}
      }
    }
    if (_photo == null && !_cache.containsKey(widget.clinicId)) _load();
  }

  @override
  void didUpdateWidget(ClinicPhotoAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clinicId != widget.clinicId || oldWidget.imageUrl != widget.imageUrl) {
      _resolveInitialPhoto();
    }
  }

  Future<void> _load() async {
    ImageProvider? photo;
    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection('clinics').doc(widget.clinicId).get();
      final url = (doc.data()?['imageUrl'] as String? ?? '').trim();
      if (url.isNotEmpty) {
        photo = NetworkImage(url);
      } else {
        final img = await db.collection('clinic_images').doc(widget.clinicId).get();
        final b64 = img.data()?['data'] as String?;
        if (b64 != null && b64.isNotEmpty) {
          photo = MemoryImage(Uint8List.fromList(base64Decode(b64)));
        }
      }
    } catch (_) {}
    _cache[widget.clinicId] = photo;
    if (mounted) setState(() => _photo = photo);
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final radius = BorderRadius.circular(widget.radius);
    final fallback = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: widget.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Text(
        initials.isEmpty ? 'C' : initials,
        style: TextStyle(fontSize: widget.fontSize, color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius: radius,
        child: _photo == null
            ? fallback
            : Image(image: _photo!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
      ),
    );
  }
}
