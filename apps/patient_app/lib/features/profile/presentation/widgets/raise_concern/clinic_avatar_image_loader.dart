import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClinicAvatarImageLoader {
  static final Map<String, ImageProvider?> _cache = {};

  static Future<ImageProvider?> resolve(
    String clinicId,
    String? imageUrl,
  ) async {
    if (_cache.containsKey(clinicId)) return _cache[clinicId];
    final direct = imageUrl?.trim() ?? '';
    if (direct.isNotEmpty) {
      if (direct.startsWith('http')) {
        return _cache[clinicId] = NetworkImage(direct);
      } else if (direct.startsWith('data:') || direct.length > 100) {
        try {
          final raw = direct.contains(',') ? direct.split(',').last : direct;
          return _cache[clinicId] = MemoryImage(
            Uint8List.fromList(base64Decode(raw)),
          );
        } catch (_) {}
      }
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('clinic_images')
          .doc(clinicId)
          .get();
      if (snap.exists) {
        final b64 = snap.data()?['data'] as String?;
        if (b64 != null && b64.isNotEmpty) {
          final raw = b64.contains(',') ? b64.split(',').last : b64;
          return _cache[clinicId] = MemoryImage(
            Uint8List.fromList(base64Decode(raw)),
          );
        }
      }
      final cDoc = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .get();
      if (cDoc.exists) {
        final url =
            (cDoc.data()?['imageUrl'] ??
                    cDoc.data()?['photoUrl'] as String? ??
                    '')
                .toString()
                .trim();
        if (url.startsWith('http')) {
          return _cache[clinicId] = NetworkImage(url);
        }
      }
    } catch (_) {}
    return _cache[clinicId] = null;
  }
}
