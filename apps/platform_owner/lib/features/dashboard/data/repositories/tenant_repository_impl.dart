import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import '../../domain/repositories/tenant_repository.dart';

class TenantRepositoryImpl implements TenantRepository {
  final FirebaseFirestore _firestore;

  TenantRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const Set<String> dummyEmails = {
    'priya@sunrisehealth.com',
    'rahul@smiledental.com',
    'fatima@citycare.com',
    'meera@wellnessskin.com',
    'anjali@kochifamily.com',
    'suresh@metrodiag.com',
  };

  static const Set<String> dummyClinicNames = {
    'Sunrise Health Clinic',
    'Smile Dental Clinic',
    'CityCare General Clinic',
    'Wellness Skin Studio',
    'Kochi Family Clinic',
    'Metro Diagnostics Center',
  };

  static bool isDummyClinic(TenantClinicEntity clinic) {
    return dummyEmails.contains(clinic.adminEmail.toLowerCase().trim()) ||
        dummyClinicNames.contains(clinic.name.trim());
  }

  @override
  Stream<QuerySnapshot> watchClinics() {
    return _firestore.collection('clinics').snapshots();
  }

  @override
  Stream<Map<String, int>> watchMonthlyAppointmentCounts() {
    // joinedAt is a Timestamp (clinic admin) or an ISO string (patient app), so filter client-side
    return _firestore.collection('tickets').snapshots().map((snap) {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month);
      final counts = <String, int>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final clinicId = (data['clinicId'] ?? '').toString();
        if (clinicId.isEmpty) continue;
        final raw = data['joinedAt'];
        // A pending serverTimestamp reads as null, which means "just now"
        final joinedAt = raw is Timestamp ? raw.toDate() : (raw is String ? DateTime.tryParse(raw) : now);
        if (joinedAt == null || joinedAt.isBefore(monthStart)) continue;
        counts[clinicId] = (counts[clinicId] ?? 0) + 1;
      }
      return counts;
    });
  }

  @override
  Future<void> seedSampleClinics() async {
    // Disabled: dummy seeding is turned off so only admin-added clinics exist.
  }

  @override
  Future<void> purgeDummyClinics() async {
    try {
      final snap = await _firestore.collection('clinics').get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final email = (data['adminEmail'] ?? '').toString().toLowerCase().trim();
        final name = (data['name'] ?? '').toString().trim();
        if (dummyEmails.contains(email) || dummyClinicNames.contains(name)) {
          await doc.reference.delete();
        }
      }

      final invitesSnap = await _firestore.collection('invites').get();
      for (final doc in invitesSnap.docs) {
        final data = doc.data();
        final email = (data['adminEmail'] ?? doc.id).toString().toLowerCase().trim();
        if (dummyEmails.contains(email)) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      debugPrint('Error purging dummy clinics from Firestore: $e');
    }
  }

  @override
  Future<OnboardClinicResult> onboardClinic({
    required String name,
    required String address,
    required String adminName,
    required String adminEmail,
    required String planId,
    List<String> departmentIds = const [],
    List<String> departmentNames = const [],
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

    // Clear any previous tombstone in removed_clinics if this email was previously removed
    try {
      await _firestore.collection('removed_clinics').doc(cleanEmail).delete();
    } catch (_) {}

    String pName = 'Solo Doctor Plan';
    String doctorLimitText = '1 Doctor Limit';
    if (planId == 'multi') {
      pName = 'Multi-Doctor Clinic Plan';
      doctorLimitText = 'Up to 10 Doctors';
    } else if (planId == 'enterprise') {
      pName = 'Unlimited Doctors Plan';
      doctorLimitText = 'Unlimited Doctors';
    }

    final category = departmentNames.isNotEmpty
        ? departmentNames.join(', ')
        : 'General Medicine';

    // 2. Add clinic with initial status 'INVITED' (will become 'ACTIVE' when admin activates)
    final docRef = await _firestore.collection('clinics').add({
      'name': cleanName,
      'category': category,
      'city': 'Kochi',
      'address': address.trim().isEmpty ? 'Main Medical Center' : address.trim(),
      'adminName': cleanAdmin,
      'adminEmail': cleanEmail,
      'planId': planId,
      'planName': pName,
      'status': 'INVITED',
      'rating': 5.0,
      'monthlyVisits': 0,
      'doctorLimitText': doctorLimitText,
      'queueStatus': 'Queue Open (0 in line)',
      'servingToken': 'A-001',
      'avgWaitTime': '0m wait',
      'departmentIds': departmentIds,
      'departments': departmentNames,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2.1 Update assignedClinics in departments collection for each selected department
    for (final deptId in departmentIds) {
      try {
        await _firestore.collection('departments').doc(deptId).update({
          'assignedClinics': FieldValue.arrayUnion([docRef.id]),
        });
      } catch (e) {
        debugPrint('Error linking department $deptId to clinic ${docRef.id}: $e');
      }
    }

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
  Future<void> updateClinic({
    required String clinicId,
    required String name,
    required String address,
    required String city,
    required String adminName,
    required String planId,
    String? phone,
    List<String> departmentIds = const [],
    List<String> departmentNames = const [],
  }) async {
    final cleanName = name.trim();
    final cleanAdmin = adminName.trim();
    final cleanAddress = address.trim();
    final cleanCity = city.trim().isEmpty ? 'Kochi' : city.trim();

    String pName = 'Solo Doctor Plan';
    String doctorLimitText = '1 Doctor Limit';
    if (planId == 'multi') {
      pName = 'Multi-Doctor Clinic Plan';
      doctorLimitText = 'Up to 10 Doctors';
    } else if (planId == 'enterprise') {
      pName = 'Unlimited Doctors Plan';
      doctorLimitText = 'Unlimited Doctors';
    }

    final category = departmentNames.isNotEmpty
        ? departmentNames.join(', ')
        : 'General Medicine';

    // 1. Update clinic document
    final Map<String, dynamic> updateData = {
      'name': cleanName,
      'address': cleanAddress,
      'city': cleanCity,
      'adminName': cleanAdmin,
      'planId': planId,
      'planName': pName,
      'doctorLimitText': doctorLimitText,
      'category': category,
      'departmentIds': departmentIds,
      'departments': departmentNames,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (phone != null && phone.trim().isNotEmpty) {
      updateData['phone'] = phone.trim();
    }

    await _firestore.collection('clinics').doc(clinicId).update(updateData);

    // 2. Sync assignedClinics in departments collection
    try {
      final allDeptsSnap = await _firestore.collection('departments').get();
      final slug = cleanName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

      for (final doc in allDeptsSnap.docs) {
        final isSelected = departmentIds.contains(doc.id);
        if (isSelected) {
          await doc.reference.update({
            'assignedClinics': FieldValue.arrayUnion([clinicId]),
          });
        } else {
          await doc.reference.update({
            'assignedClinics': FieldValue.arrayRemove([clinicId, slug]),
          });
        }
      }
    } catch (e) {
      debugPrint('Error syncing departments for clinic $clinicId: $e');
    }

    // 3. Update user profile document in users collection if exists
    try {
      final clinicDoc = await _firestore.collection('clinics').doc(clinicId).get();
      final adminEmail = (clinicDoc.data()?['adminEmail'] as String?)?.toLowerCase();
      if (adminEmail != null && adminEmail.isNotEmpty) {
        final usersSnap = await _firestore.collection('users').where('email', isEqualTo: adminEmail).get();
        for (final userDoc in usersSnap.docs) {
          await userDoc.reference.update({
            'name': cleanAdmin,
            'clinicName': cleanName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating user document for clinic $clinicId: $e');
    }
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
    String? resolvedAdminEmail = adminEmail;
    String? clinicName;

    // Fetch clinic doc first if details missing
    try {
      final cDoc = await _firestore.collection('clinics').doc(clinicId).get();
      if (cDoc.exists) {
        final data = cDoc.data() ?? {};
        if (resolvedAdminEmail == null || resolvedAdminEmail.isEmpty) {
          resolvedAdminEmail = data['adminEmail'] as String?;
        }
        clinicName = data['name'] as String?;
      }
    } catch (e) {
      debugPrint('Error reading clinic info prior to delete: $e');
    }

    final cleanEmail = resolvedAdminEmail?.trim().toLowerCase();
    final slug = clinicName?.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

    // 1. Record removal tombstones so active clinic sessions detect immediately
    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      try {
        await _firestore.collection('removed_clinics').doc(cleanEmail).set({
          'clinicId': clinicId,
          'clinicName': clinicName ?? 'Clinic',
          'adminEmail': cleanEmail,
          'removedAt': FieldValue.serverTimestamp(),
          'reason': 'The platform owner has removed the clinic facility and account.',
        });
      } catch (e) {
        debugPrint('Error recording removed_clinics entry for $cleanEmail: $e');
      }
    }

    try {
      await _firestore.collection('removed_clinics').doc(clinicId).set({
        'clinicId': clinicId,
        'clinicName': clinicName ?? 'Clinic',
        'adminEmail': cleanEmail,
        'removedAt': FieldValue.serverTimestamp(),
        'reason': 'The platform owner has removed the clinic facility and account.',
      });
    } catch (e) {
      debugPrint('Error recording removed_clinics entry for clinicId $clinicId: $e');
    }

    // 2. Erase queues
    try {
      await _firestore.collection('queues').doc(clinicId).delete();
    } catch (e) {
      debugPrint('Error erasing queue: $e');
    }

    // 3. Erase services
    try {
      final servicesSnap = await _firestore.collection('services').where('clinicId', isEqualTo: clinicId).get();
      for (final doc in servicesSnap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error erasing services: $e');
    }

    // 4. Erase tickets
    try {
      final ticketsSnap = await _firestore.collection('tickets').where('clinicId', isEqualTo: clinicId).get();
      for (final doc in ticketsSnap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error erasing tickets: $e');
    }

    // 5. Erase service_requests
    try {
      final sReqSnap = await _firestore.collection('service_requests').where('clinicId', isEqualTo: clinicId).get();
      for (final doc in sReqSnap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error erasing service_requests: $e');
    }

    // 6. Erase department_requests
    try {
      final dReqSnap = await _firestore.collection('department_requests').where('clinicId', isEqualTo: clinicId).get();
      for (final doc in dReqSnap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error erasing department_requests: $e');
    }

    // 7. Unlink clinic from all departments in departments collection
    try {
      final deptsSnap = await _firestore.collection('departments').get();
      for (final doc in deptsSnap.docs) {
        final removals = [clinicId];
        if (slug != null && slug.isNotEmpty) removals.add(slug);
        await doc.reference.update({
          'assignedClinics': FieldValue.arrayRemove(removals),
        });
      }
    } catch (e) {
      debugPrint('Error unlinking clinic from departments: $e');
    }

    // 8. Erase invites
    try {
      final inviteByClinic = await _firestore.collection('invites').where('clinicId', isEqualTo: clinicId).get();
      for (final doc in inviteByClinic.docs) {
        await doc.reference.delete();
      }
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        final inviteByEmail = await _firestore.collection('invites').where('adminEmail', isEqualTo: cleanEmail).get();
        for (final doc in inviteByEmail.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      debugPrint('Error erasing invites: $e');
    }

    // 9. Erase user profiles in users collection
    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      try {
        final userSnap = await _firestore.collection('users').where('email', isEqualTo: cleanEmail).get();
        for (final doc in userSnap.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint('Error erasing users for $cleanEmail: $e');
      }
    }

    // 10. Delete the clinic facility document itself
    await _firestore.collection('clinics').doc(clinicId).delete();
  }
}
