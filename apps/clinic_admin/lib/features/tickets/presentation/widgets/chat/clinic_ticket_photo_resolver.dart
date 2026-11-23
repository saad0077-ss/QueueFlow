import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicTicketPhotoResolver {
  static final Map<String, String> _cache = {};

  static Uint8List? decode(String? v) {
    if (v == null) return null;
    var s = v.trim();
    if (s.isEmpty || s.startsWith('http')) return null;
    final comma = s.indexOf(',');
    if (s.startsWith('data:') && comma >= 0) {
      s = s.substring(comma + 1);
    }
    try {
      return base64Decode(s);
    } catch (_) {
      return null;
    }
  }

  static Future<String> resolvePhoto({
    required String? photo,
    required String? patientId,
    required String? patientEmail,
  }) async {
    if (photo != null && photo.trim().isNotEmpty) {
      return photo.trim();
    }
    final uid = patientId?.trim() ?? '';
    final email = patientEmail?.trim().toLowerCase() ?? '';
    final key = uid.isNotEmpty ? 'uid:$uid' : 'mail:$email';
    if (key.isEmpty || key == 'mail:') return '';

    if (_cache.containsKey(key)) {
      return _cache[key] ?? '';
    }

    try {
      final fs = FirebaseFirestore.instance;
      Map<String, dynamic>? data;
      if (uid.isNotEmpty) {
        final doc = await fs.collection('users').doc(uid).get();
        if (doc.exists) data = doc.data();
      }
      if (data == null && email.isNotEmpty) {
        final q = await fs
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) data = q.docs.first.data();
      }
      final resolved =
          (data?['photoBase64'] ??
                  data?['patientPhoto'] ??
                  data?['photoUrl'] ??
                  data?['avatar'] ??
                  '')
              .toString();
      _cache[key] = resolved;
      return resolved;
    } catch (_) {
      _cache[key] = '';
      return '';
    }
  }
}
