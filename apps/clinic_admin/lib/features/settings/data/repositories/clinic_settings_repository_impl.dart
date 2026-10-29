import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../domain/entities/clinic_location_entity.dart';
import '../../domain/entities/clinic_operating_schedule_entity.dart';
import '../../domain/entities/clinic_profile_entity.dart';
import '../../domain/entities/clinic_queue_rules_entity.dart';
import '../../domain/entities/clinic_settings_entity.dart';
import '../../domain/repositories/clinic_settings_repository.dart';
import '../models/clinic_settings_mapper.dart';

class ClinicSettingsRepositoryImpl implements ClinicSettingsRepository {
  /// Firestore documents are capped at 1 MiB; Base64 adds ~33%, so keep raw photos under this.
  static const _maxImageBytes = 700 * 1024;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ClinicSettingsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<String> _resolveClinicId() async =>
      (await CurrentClinicResolver.require(auth: _auth, firestore: _firestore)).id;

  @override
  Future<ClinicSettingsEntity> getClinicSettings() async {
    final doc = await CurrentClinicResolver.require(auth: _auth, firestore: _firestore);
    final data = doc.data() ?? <String, dynamic>{};
    final settings = ClinicSettingsMapper.fromFirestore(doc.id, data);
    if (((data['imageVersion'] as num?)?.toInt() ?? 0) <= 0) return settings;

    final imageBytes = await _loadImage(doc.id);
    if (imageBytes == null) return settings;
    return settings.copyWith(profile: settings.profile.copyWith(imageBytes: imageBytes));
  }

  Future<Uint8List?> _loadImage(String clinicId) async {
    try {
      final snap = await _firestore.collection('clinic_images').doc(clinicId).get();
      final encoded = snap.data()?['data'];
      return encoded is String && encoded.isNotEmpty ? base64Decode(encoded) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(ClinicProfileEntity profile) async {
    final id = await _resolveClinicId();
    await _firestore.collection('clinics').doc(id).set({
      'name': profile.name, 'address': profile.address, 'phone': profile.phone,
      'email': profile.email, 'description': profile.description,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> uploadProfileImage(Uint8List bytes, String fileName) async {
    if (bytes.length > _maxImageBytes) {
      throw Exception('This photo is too large (${(bytes.length / 1024).round()} KB). Please choose an image under 700 KB.');
    }
    final id = await _resolveClinicId();
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    final type = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };

    // The photo lives in its own document so clinic list queries stay small.
    final batch = _firestore.batch()
      ..set(_firestore.collection('clinic_images').doc(id), {
        'data': base64Encode(bytes),
        'contentType': type,
        'sizeBytes': bytes.length,
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..set(_firestore.collection('clinics').doc(id), {
        // Lets apps know a photo exists and refresh cached copies on change.
        'imageVersion': DateTime.now().millisecondsSinceEpoch,
        'imageUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> saveLocation(ClinicLocationEntity loc) async {
    final id = await _resolveClinicId();
    await _firestore.collection('clinics').doc(id).set({
      'location': {
        'building': loc.building, 'street': loc.street, 'area': loc.area,
        'city': loc.city, 'state': loc.state, 'pincode': loc.pincode,
        'landmark': loc.landmark, 'googleMapsUrl': loc.googleMapsUrl,
        'latitude': loc.latitude, 'longitude': loc.longitude,
        'parking': loc.parking, 'directions': loc.directions,
      },
      'address': loc.fullAddress,
      'city': loc.city,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> saveOperatingSchedule(ClinicOperatingScheduleEntity s) async {
    final id = await _resolveClinicId();
    final hoursMap = <String, dynamic>{};
    for (final e in s.days.entries) {
      hoursMap[e.key] = {
        'isOpen': e.value.isOpen, 'openTime': e.value.openTime, 'closeTime': e.value.closeTime,
        'hasBreak': e.value.hasBreak, 'breakStart': e.value.breakStart, 'breakEnd': e.value.breakEnd,
      };
    }
    await _firestore.collection('clinics').doc(id).set({
      'operatingHours': hoursMap,
      'openingHours': s.scheduleSummary,
      'scheduleSummary': s.scheduleSummary,
      'queueCutoffMin': s.queueCutoffMin,
      'slotDurationMin': s.slotDurationMin,
      'emergencyOnCall': s.emergencyOnCall,
      'emergencyPhone': s.emergencyPhone,
      'holidayNotice': s.holidayNotice,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> saveQueueRules(ClinicQueueRulesEntity rules) async {
    final id = await _resolveClinicId();
    await _firestore.collection('clinics').doc(id).set({
      'maxQueueCapacity': rules.maxQueueCapacity,
      'avgConsultationTimeMin': rules.avgConsultationTimeMin,
      'allowWalkIns': rules.allowWalkIns,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateSecurity({
    required String currentPassword,
    required String newPassword,
    required bool requireTwoFactor,
  }) async {
    final id = await _resolveClinicId();
    await _firestore.collection('clinics').doc(id).set({
      'requireTwoFactor': requireTwoFactor,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
