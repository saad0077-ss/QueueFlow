import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/platform_user_entity.dart';
import '../../domain/repositories/platform_users_repository.dart';
import '../models/platform_user_model.dart';

class PlatformUsersRepositoryImpl implements PlatformUsersRepository {
  final FirebaseFirestore _firestore;

  PlatformUsersRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<PlatformUserEntity>> watchPlatformUsers() {
    return _firestore.collection('users').snapshots().asyncMap((userSnap) async {
      try {
        final ticketsSnap = await _firestore
            .collection('tickets')
            .where('status', whereIn: ['waiting', 'called'])
            .get();

        final activeTicketsByUser = <String, Map<String, dynamic>>{};
        for (final doc in ticketsSnap.docs) {
          final d = doc.data();
          final uid = (d['patientId'] ?? d['userId'] ?? d['customerId'] ?? '').toString();
          final email = (d['patientEmail'] ?? d['userEmail'] ?? '').toString().toLowerCase();
          if (uid.isNotEmpty) activeTicketsByUser[uid] = d;
          if (email.isNotEmpty) activeTicketsByUser[email] = d;
        }

        final users = <PlatformUserEntity>[];
        for (final doc in userSnap.docs) {
          final data = doc.data();
          final role = (data['role'] ?? '').toString().toLowerCase();
          // Filter out platform owners and clinic admins
          if (role == 'platform_owner' || role == 'clinic_admin') continue;

          final uid = doc.id;
          final email = (data['email'] ?? '').toString().toLowerCase();

          final activeTicket = activeTicketsByUser[uid] ?? activeTicketsByUser[email];
          final tokenCode = activeTicket?['tokenCode'] as String? ?? activeTicket?['ticketNumber'] as String?;
          final tokenStatus = activeTicket?['status'] as String?;
          final clinicName = activeTicket?['clinicName'] as String?;

          users.add(PlatformUserModel.fromFirestore(
            doc,
            clinicName: clinicName,
            tokenCode: tokenCode,
            tokenStatus: tokenStatus,
          ));
        }

        return users;
      } catch (e) {
        debugPrint('Error mapping platform users: $e');
        return const [];
      }
    });
  }

  @override
  Future<void> deletePatientAccount(String userId, {String? email}) async {
    final cleanEmail = email?.trim().toLowerCase();
    try {
      final docsToDelete = <String, DocumentReference>{};

      Future<void> collectDocs(
        String collectionName,
        List<Query<Map<String, dynamic>>> queries,
      ) async {
        for (final q in queries) {
          try {
            final snap = await q.get();
            for (final doc in snap.docs) {
              docsToDelete[doc.reference.path] = doc.reference;
            }
          } catch (e) {
            debugPrint('Platform delete $collectionName query error: $e');
          }
        }
      }

      // 1. Appointments
      final apptQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('appointments').where('customerId', isEqualTo: userId),
        _firestore.collection('appointments').where('userId', isEqualTo: userId),
        _firestore.collection('appointments').where('patientId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        apptQueries.add(_firestore.collection('appointments').where('customerEmail', isEqualTo: cleanEmail));
        apptQueries.add(_firestore.collection('appointments').where('patientEmail', isEqualTo: cleanEmail));
        apptQueries.add(_firestore.collection('appointments').where('userEmail', isEqualTo: cleanEmail));
      }
      await collectDocs('appointments', apptQueries);

      // 2. Tickets
      final ticketQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('tickets').where('patientId', isEqualTo: userId),
        _firestore.collection('tickets').where('userId', isEqualTo: userId),
        _firestore.collection('tickets').where('customerId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        ticketQueries.add(_firestore.collection('tickets').where('patientEmail', isEqualTo: cleanEmail));
        ticketQueries.add(_firestore.collection('tickets').where('userEmail', isEqualTo: cleanEmail));
      }
      await collectDocs('tickets', ticketQueries);

      // 3. Reviews
      final reviewQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('reviews').where('userId', isEqualTo: userId),
        _firestore.collection('reviews').where('patientId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        reviewQueries.add(_firestore.collection('reviews').where('userEmail', isEqualTo: cleanEmail));
      }
      await collectDocs('reviews', reviewQueries);

      // 4. Doctor Reviews
      final docReviewQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('doctor_reviews').where('userId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        docReviewQueries.add(_firestore.collection('doctor_reviews').where('userEmail', isEqualTo: cleanEmail));
      }
      await collectDocs('doctor_reviews', docReviewQueries);

      // 5. Notifications
      final notifQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('notifications').where('userId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        notifQueries.add(_firestore.collection('notifications').where('userEmail', isEqualTo: cleanEmail));
      }
      await collectDocs('notifications', notifQueries);

      // 6. Support Tickets
      final supportQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('support_tickets').where('patientId', isEqualTo: userId),
        _firestore.collection('support_tickets').where('userId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        supportQueries.add(_firestore.collection('support_tickets').where('userEmail', isEqualTo: cleanEmail));
      }
      await collectDocs('support_tickets', supportQueries);

      // 7. Payments
      final payQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('payments').where('userId', isEqualTo: userId),
        _firestore.collection('payments').where('customerId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        payQueries.add(_firestore.collection('payments').where('userEmail', isEqualTo: cleanEmail));
      }
      await collectDocs('payments', payQueries);

      // 8. Subcollections
      const subcollections = [
        'vital_history',
        'medical_records',
        'favorites',
        'notifications',
        'devices',
        'activity',
        'prescriptions',
      ];
      for (final sub in subcollections) {
        try {
          final subSnap = await _firestore.collection('users').doc(userId).collection(sub).get();
          for (final d in subSnap.docs) {
            docsToDelete[d.reference.path] = d.reference;
          }
        } catch (_) {}
      }

      // Batch delete
      final docList = docsToDelete.values.toList();
      for (var i = 0; i < docList.length; i += 400) {
        final batch = _firestore.batch();
        final end = (i + 400 < docList.length) ? i + 400 : docList.length;
        for (var j = i; j < end; j++) {
          batch.delete(docList[j]);
        }
        await batch.commit();
      }

      // Finally delete the user root document
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      debugPrint('Error deleting user $userId from platform admin: $e');
      rethrow;
    }
  }
}
