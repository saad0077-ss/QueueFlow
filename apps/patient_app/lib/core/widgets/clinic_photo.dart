import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Shows a clinic's photo, stored as Base64 in `clinic_images/{clinicId}`.
///
/// Falls back to [imageUrl] for clinics with an older hosted image, and to
/// [placeholder] when there is no photo or it fails to load.
class ClinicPhoto extends StatefulWidget {
  final String clinicId;
  final int imageVersion;
  final String? imageUrl;
  final Widget placeholder;
  final BoxFit fit;

  const ClinicPhoto({
    super.key,
    required this.clinicId,
    required this.imageVersion,
    required this.placeholder,
    this.imageUrl,
    this.fit = BoxFit.cover,
  });

  // Keyed by clinic id + version so a new upload invalidates the cached photo.
  static final Map<String, Future<Uint8List?>> _cache = {};

  static Future<Uint8List?> _load(String clinicId, int version) {
    return _cache.putIfAbsent('$clinicId@$version', () async {
      try {
        final doc = await FirebaseFirestore.instance.collection('clinic_images').doc(clinicId).get();
        final data = doc.data()?['data'];
        return data is String && data.isNotEmpty ? base64Decode(data) : null;
      } catch (_) {
        return null;
      }
    });
  }

  @override
  State<ClinicPhoto> createState() => _ClinicPhotoState();
}

class _ClinicPhotoState extends State<ClinicPhoto> {
  Future<Uint8List?>? _future;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant ClinicPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clinicId != widget.clinicId || oldWidget.imageVersion != widget.imageVersion) _resolve();
  }

  void _resolve() {
    _future = widget.imageVersion > 0 ? ClinicPhoto._load(widget.clinicId, widget.imageVersion) : null;
  }

  Widget _fallback() {
    final url = widget.imageUrl?.trim() ?? '';
    if (url.isEmpty) return widget.placeholder;
    return Image.network(url, fit: widget.fit, errorBuilder: (_, _, _) => widget.placeholder);
  }

  @override
  Widget build(BuildContext context) {
    final future = _future;
    if (future == null) return _fallback();
    return FutureBuilder<Uint8List?>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return widget.placeholder;
        final bytes = snap.data;
        if (bytes == null) return _fallback();
        return Image.memory(bytes, fit: widget.fit, gaplessPlayback: true, errorBuilder: (_, _, _) => widget.placeholder);
      },
    );
  }
}
