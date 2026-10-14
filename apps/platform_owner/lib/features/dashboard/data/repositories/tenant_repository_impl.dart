import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../models/sample_clinics_seed.dart';

class TenantRepositoryImpl implements TenantRepository {
  final FirebaseFirestore _firestore;

  TenantRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<QuerySnapshot> watchClinics() {
    return _firestore.collection('clinics').snapshots();
  }

  @override
  Future<void> seedSampleClinics() async {
    for (final c in sampleClinicsSeed) {
      await _firestore.collection('clinics').add({
        ...c,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<OnboardClinicResult> onboardClinic({
    required String name,
    required String address,
    required String adminName,
    required String adminEmail,
    required String planId,
  }) async {
    final cleanEmail = adminEmail.trim().toLowerCase();
    final cleanName = name.trim();
    final cleanAdmin = adminName.trim();

    // 1. Validation: One email = One clinic
    final existingQuery = await _firestore
        .collection('clinics')
        .where('adminEmail', isEqualTo: cleanEmail)
        .limit(1)
        .get();

    if (existingQuery.docs.isNotEmpty) {
      final existingData = existingQuery.docs.first.data();
      final existingName = existingData['name'] ?? 'an existing clinic';
      throw Exception(
          'A clinic with admin email "$cleanEmail" already exists ("$existingName"). Each clinic admin can only manage one clinic.');
    }

    // 2. Add clinic with initial status 'INVITED' (will become 'ACTIVE' when admin activates)
    final docRef = await _firestore.collection('clinics').add({
      'name': cleanName,
      'category': 'General Medicine',
      'city': 'Kochi',
      'address': address.trim().isEmpty ? 'Main Medical Center' : address.trim(),
      'adminName': cleanAdmin,
      'adminEmail': cleanEmail,
      'planId': planId,
      'status': 'INVITED',
      'rating': 5.0,
      'monthlyVisits': 0,
      'practicingDoctors': 1,
      'doctorLimitText':
          planId == 'solo' ? '1 Doctor Limit' : 'Up to 10 Doctors',
      'queueStatus': 'Queue Open (0 in line)',
      'servingToken': 'A-001',
      'avgWaitTime': '0m wait',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // In development mode, point to http://localhost:5000 (HTTP for local flutter web)
    final String baseHost = kReleaseMode
        ? 'https://clinic.queueflow.com'
        : 'http://localhost:5000';

    final inviteUrl =
        '$baseHost/?invite=true&clinicId=${docRef.id}&email=$cleanEmail&name=${Uri.encodeComponent(cleanAdmin)}&clinic=${Uri.encodeComponent(cleanName)}';

    // 3. Audit & Invites record
    await _firestore.collection('invites').add({
      'clinicId': docRef.id,
      'clinicName': cleanName,
      'adminEmail': cleanEmail,
      'adminName': cleanAdmin,
      'inviteUrl': inviteUrl,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 4. Dispatch branded clinic admin invite email via Vercel microservice
    bool emailDelivered = false;
    String? emailFeedback;

    try {
      final response = await http.post(
        Uri.parse('https://queueflow-mailer.vercel.app/api/send-clinic-invite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clinicName': cleanName,
          'adminName': cleanAdmin,
          'adminEmail': cleanEmail,
          'inviterName': 'Alex Chen', // Platform Owner
          'inviteUrl': inviteUrl,
        }),
      );

      if (response.statusCode == 200) {
        emailDelivered = true;
        debugPrint('Branded clinic invite email successfully dispatched to $cleanEmail');
      } else {
        debugPrint(
            'Clinic invite email warning (${response.statusCode}): ${response.body}');
        try {
          final data = jsonDecode(response.body);
          final errorMsg = data['error']?.toString() ?? '';
          if (response.statusCode == 403 || errorMsg.contains('own email address')) {
            emailFeedback = 'Resend test sandbox only delivers to registered email (muhammedsaad007700@gmail.com).';
          } else {
            emailFeedback = errorMsg.isNotEmpty ? errorMsg : 'Email service returned error ${response.statusCode}';
          }
        } catch (_) {
          emailFeedback = 'Email service returned error ${response.statusCode}';
        }
      }
    } catch (e) {
      debugPrint('Failed to dispatch clinic invite email via microservice: $e');
      emailFeedback = 'Network error while contacting email microservice.';
    }

    return OnboardClinicResult(
      inviteUrl: inviteUrl,
      emailDelivered: emailDelivered,
      emailFeedback: emailFeedback,
    );
  }

  @override
  Future<void> updateSubscription({
    required String clinicId,
    required String planId,
    required String billingCadence,
    required String status,
  }) async {
    await _firestore.collection('clinics').doc(clinicId).update({
      'planId': planId,
      'billingCadence': billingCadence,
      'status': status.toUpperCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> toggleStatus(String clinicId, bool currentlyActive) async {
    final doc = await _firestore.collection('clinics').doc(clinicId).get();
    final currentStatus = (doc.data()?['status'] ?? '').toString().toUpperCase();
    if (currentStatus == 'INVITED') {
      throw Exception('Clinic is pending activation via email. The clinic admin must activate the account first.');
    }
    await _firestore.collection('clinics').doc(clinicId).update({
      'status': currentlyActive ? 'SUSPENDED' : 'ACTIVE',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<OnboardClinicResult> resendInvite({
    required String clinicId,
    required String clinicName,
    required String adminName,
    required String adminEmail,
  }) async {
    final cleanEmail = adminEmail.trim().toLowerCase();
    final cleanName = clinicName.trim();
    final cleanAdmin = adminName.trim();

    final inviteUrl = kDebugMode
        ? 'http://localhost:5000/?invite=true&email=$cleanEmail&clinic=${Uri.encodeComponent(cleanName)}&name=${Uri.encodeComponent(cleanAdmin)}&role=clinic_admin'
        : 'https://queueflow.app/clinic/invite?email=$cleanEmail&clinic=${Uri.encodeComponent(cleanName)}&name=${Uri.encodeComponent(cleanAdmin)}&role=clinic_admin';

    await _firestore.collection('invites').doc(cleanEmail).set({
      'clinicId': clinicId,
      'clinicName': cleanName,
      'adminName': cleanAdmin,
      'adminEmail': cleanEmail,
      'inviteUrl': inviteUrl,
      'status': 'pending',
      'resentAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    bool emailDelivered = false;
    String? emailFeedback;

    try {
      final response = await http.post(
        Uri.parse('https://queueflow-mailer.vercel.app/api/send-clinic-invite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clinicName': cleanName,
          'adminName': cleanAdmin,
          'adminEmail': cleanEmail,
          'inviterName': 'Alex Chen',
          'inviteUrl': inviteUrl,
        }),
      );

      if (response.statusCode == 200) {
        emailDelivered = true;
      } else {
        try {
          final data = jsonDecode(response.body);
          final errorMsg = data['error']?.toString() ?? '';
          if (response.statusCode == 403 || errorMsg.contains('own email address')) {
            emailFeedback = 'Resend test sandbox only delivers to registered email (muhammedsaad007700@gmail.com).';
          } else {
            emailFeedback = errorMsg.isNotEmpty ? errorMsg : 'Email service returned error ${response.statusCode}';
          }
        } catch (_) {
          emailFeedback = 'Email service returned error ${response.statusCode}';
        }
      }
    } catch (e) {
      emailFeedback = 'Network error while contacting email microservice.';
    }

    return OnboardClinicResult(
      inviteUrl: inviteUrl,
      emailDelivered: emailDelivered,
      emailFeedback: emailFeedback,
    );
  }

  @override
  Future<void> deleteClinic(String clinicId, {String? adminEmail}) async {
    // 1. Delete the clinic document
    await _firestore.collection('clinics').doc(clinicId).delete();

    // 2. Delete any matching invite records and user records for this admin email
    if (adminEmail != null && adminEmail.isNotEmpty) {
      final cleanEmail = adminEmail.trim().toLowerCase();
      try {
        final inviteSnap = await _firestore
            .collection('invites')
            .where('adminEmail', isEqualTo: cleanEmail)
            .get();
        for (final doc in inviteSnap.docs) {
          await doc.reference.delete();
        }

        final userSnap = await _firestore
            .collection('users')
            .where('email', isEqualTo: cleanEmail)
            .get();
        for (final doc in userSnap.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint('Error cleaning up invites or users on clinic delete: $e');
      }
    }
  }
}
