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
    if (s.contains(';base64,') && comma >= 0) {
      s = s.substring(comma + 1);
    } else if (s.startsWith('data:') && comma >= 0) {
      s = s.substring(comma + 1);
    }
    s = s.replaceAll(RegExp(r'\s+'), '');
    final mod = s.length % 4;
    if (mod > 0) s += '=' * (4 - mod);
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
    String? patientPhone,
    String? patientName,
  }) async {
    if (photo != null && photo.trim().isNotEmpty) return photo.trim();

    final uid = patientId?.trim() ?? '';
    final email = patientEmail?.trim().toLowerCase() ?? '';
    final phone = patientPhone?.replaceAll(RegExp(r'\D'), '') ?? '';
    final name = patientName?.trim().toLowerCase() ?? '';
    final key = uid.isNotEmpty
        ? 'u:$uid'
        : (email.isNotEmpty
              ? 'm:$email'
              : (phone.isNotEmpty ? 'p:$phone' : 'n:$name'));
    if (key.isEmpty) return '';

    if (_cache.containsKey(key) && (_cache[key]?.isNotEmpty ?? false)) {
      return _cache[key]!;
    }

    try {
      final fs = FirebaseFirestore.instance;
      Map<String, dynamic>? data;

      if (uid.isNotEmpty && !uid.startsWith('walkin-') && uid != 'user-1') {
        final doc = await fs.collection('users').doc(uid).get();
        if (doc.exists) data = doc.data();
      }

      if (data == null && email.isNotEmpty) {
        final q = await fs
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          data = q.docs.first.data();
        } else if (patientEmail != null && patientEmail.trim() != email) {
          final q2 = await fs
              .collection('users')
              .where('email', isEqualTo: patientEmail.trim())
              .limit(1)
              .get();
          if (q2.docs.isNotEmpty) data = q2.docs.first.data();
        }
      }

      if (data == null && phone.isNotEmpty) {
        final rawPhone = patientPhone?.trim() ?? '';
        for (final p in [phone, rawPhone, '+91$phone', '+91 $phone']) {
          final q = await fs
              .collection('users')
              .where('phone', isEqualTo: p)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) {
            data = q.docs.first.data();
            break;
          }
          final q2 = await fs
              .collection('users')
              .where('phoneNumber', isEqualTo: p)
              .limit(1)
              .get();
          if (q2.docs.isNotEmpty) {
            data = q2.docs.first.data();
            break;
          }
        }
      }

      if (data == null && name.isNotEmpty) {
        final q = await fs
            .collection('users')
            .where('name', isEqualTo: patientName?.trim())
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          data = q.docs.first.data();
        } else {
          final q2 = await fs
              .collection('users')
              .where('fullName', isEqualTo: patientName?.trim())
              .limit(1)
              .get();
          if (q2.docs.isNotEmpty) data = q2.docs.first.data();
        }
      }

      final resolved =
          (data?['photoBase64'] ??
                  data?['patientPhoto'] ??
                  data?['customerPhoto'] ??
                  data?['profilePhoto'] ??
                  data?['photoUrl'] ??
                  data?['avatar'] ??
                  data?['photo'] ??
                  '')
              .toString();

      if (resolved.isNotEmpty) _cache[key] = resolved;
      return resolved;
    } catch (_) {
      return '';
    }
  }
}
