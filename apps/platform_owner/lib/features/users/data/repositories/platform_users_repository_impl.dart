import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../dashboard/data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/platform_user_entity.dart';
import '../../domain/repositories/platform_users_repository.dart';
import '../models/platform_user_model.dart';

class PlatformUsersRepositoryImpl implements PlatformUsersRepository {
  final FirebaseFirestore _firestore;

  PlatformUsersRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<PlatformUserEntity>> watchPlatformUsers() {
    late final StreamController<List<PlatformUserEntity>> controller;
    StreamSubscription? usersSub;
    StreamSubscription? ticketsSub;
    StreamSubscription? apptsSub;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> latestUsersDocs = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> latestTicketsDocs = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> latestApptsDocs = [];
    List<PlatformUserEntity>? cachedUsers;

    void recomputeAndEmit() {
      try {
        final users = _aggregateAllUsersFromDocs(
          tickets: latestTicketsDocs,
          appts: latestApptsDocs,
          userDocs: latestUsersDocs,
        );
        cachedUsers = users;
        if (!controller.isClosed) {
          controller.add(users);
        }
      } catch (e) {
        debugPrint('Error aggregating platform users: $e');
      }
    }

    controller = StreamController<List<PlatformUserEntity>>.broadcast(
      onListen: () {
        if (cachedUsers != null && !controller.isClosed) {
          controller.add(cachedUsers!);
        }

        // Fetch all 3 collections simultaneously for initial state
        Future.wait([
          _firestore
              .collection('users')
              .get()
              .then((snap) => latestUsersDocs = snap.docs)
              .catchError((e) {
                debugPrint('Initial users get warning: $e');
                return <QueryDocumentSnapshot<Map<String, dynamic>>>[];
              }),
          _firestore
              .collection('tickets')
              .get()
              .then((snap) => latestTicketsDocs = snap.docs)
              .catchError((e) {
                debugPrint('Initial tickets get warning: $e');
                return <QueryDocumentSnapshot<Map<String, dynamic>>>[];
              }),
          _firestore
              .collection('appointments')
              .get()
              .then((snap) => latestApptsDocs = snap.docs)
              .catchError((e) {
                debugPrint('Initial appts get warning: $e');
                return <QueryDocumentSnapshot<Map<String, dynamic>>>[];
              }),
        ]).then((_) {
          recomputeAndEmit();
        });

        // 1. Real-time users stream
        try {
          usersSub = _firestore
              .collection('users')
              .snapshots()
              .listen(
                (snap) {
                  latestUsersDocs = snap.docs;
                  recomputeAndEmit();
                },
                onError: (e) {
                  debugPrint('Firestore users snapshot warning: $e');
                },
              );
        } catch (e) {
          debugPrint('Error attaching users collection listener: $e');
        }

        // 2. Real-time tickets stream
        try {
          ticketsSub = _firestore
              .collection('tickets')
              .snapshots()
              .listen(
                (snap) {
                  latestTicketsDocs = snap.docs;
                  recomputeAndEmit();
                },
                onError: (e) {
                  debugPrint('Firestore tickets snapshot warning: $e');
                },
              );
        } catch (e) {
          debugPrint('Error attaching tickets collection listener: $e');
        }

        // 3. Real-time appointments stream
        try {
          apptsSub = _firestore
              .collection('appointments')
              .snapshots()
              .listen(
                (snap) {
                  latestApptsDocs = snap.docs;
                  recomputeAndEmit();
                },
                onError: (e) {
                  debugPrint('Firestore appointments snapshot warning: $e');
                },
              );
        } catch (e) {
          debugPrint('Error attaching appointments collection listener: $e');
        }
      },
      onCancel: () {
        usersSub?.cancel();
        ticketsSub?.cancel();
        apptsSub?.cancel();
      },
    );

    return controller.stream;
  }

  List<PlatformUserEntity> _aggregateAllUsersFromDocs({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> tickets,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> appts,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
  }) {
    final Map<String, PlatformUserEntity> usersById = {};
    final Map<String, String> emailToId = {};
    final Map<String, String> phoneToId = {};

    final Map<String, int> totalQueuesByKey = {};
    final Map<String, int> totalApptsByKey = {};
    final Map<String, Map<String, dynamic>> activeTicketByKey = {};

    for (final doc in tickets) {
      final d = doc.data();
      final uid = (d['patientId'] ?? d['userId'] ?? d['customerId'] ?? '')
          .toString()
          .trim();
      final email =
          (d['patientEmail'] ?? d['userEmail'] ?? d['customerEmail'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      final phone =
          (d['patientPhone'] ?? d['userPhone'] ?? d['customerPhone'] ?? '')
              .toString()
              .trim();
      final status = (d['status'] ?? '').toString().toLowerCase();

      void bump(String key) {
        if (key.isNotEmpty) {
          totalQueuesByKey[key] = (totalQueuesByKey[key] ?? 0) + 1;
        }
      }

      bump(uid);
      bump(email);
      bump(phone);

      if (status == 'waiting' || status == 'called') {
        if (uid.isNotEmpty) activeTicketByKey[uid] = d;
        if (email.isNotEmpty) activeTicketByKey[email] = d;
        if (phone.isNotEmpty) activeTicketByKey[phone] = d;
      }
    }

    for (final doc in appts) {
      final d = doc.data();
      final uid = (d['customerId'] ?? d['userId'] ?? d['patientId'] ?? '')
          .toString()
          .trim();
      final email =
          (d['customerEmail'] ?? d['userEmail'] ?? d['patientEmail'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      final phone =
          (d['customerPhone'] ?? d['userPhone'] ?? d['patientPhone'] ?? '')
              .toString()
              .trim();

      void bump(String key) {
        if (key.isNotEmpty) {
          totalApptsByKey[key] = (totalApptsByKey[key] ?? 0) + 1;
        }
      }

      bump(uid);
      bump(email);
      bump(phone);
    }

    // Process user documents from 'users' collection
    for (final doc in userDocs) {
      final d = doc.data();
      final role = (d['role'] ?? '').toString().toLowerCase();
      // Exclude platform owner and clinic admins
      if (role == 'platform_owner' || role == 'clinic_admin') continue;

      final uid = doc.id;
      final email = (d['email'] ?? '').toString().trim().toLowerCase();
      final phone = (d['phone'] ?? d['phoneNumber'] ?? '').toString().trim();

      final activeTicket =
          activeTicketByKey[uid] ??
          activeTicketByKey[email] ??
          activeTicketByKey[phone];
      final tokenCode =
          (activeTicket?['tokenCode'] ??
                  activeTicket?['ticketNumber'] ??
                  activeTicket?['token'])
              ?.toString();
      final tokenStatus = activeTicket?['status']?.toString();
      final tokenService = activeTicket?['serviceName']?.toString();
      final tokenDoctor = activeTicket?['doctorName']?.toString();
      final tokenClinic = activeTicket?['clinicName']?.toString();

      String? tokenJoinedAt;
      final rawJoined = activeTicket?['joinedAt'];
      if (rawJoined is Timestamp) {
        final t = rawJoined.toDate();
        tokenJoinedAt =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      } else if (rawJoined is String) {
        tokenJoinedAt = rawJoined;
      }

      final int apptsCount =
          (totalApptsByKey[uid] ?? 0) + (totalApptsByKey[email] ?? 0);
      final int queuesCount =
          (totalQueuesByKey[uid] ?? 0) + (totalQueuesByKey[email] ?? 0);

      final user = PlatformUserModel.fromFirestore(
        doc,
        clinicName: tokenClinic,
        tokenCode: tokenCode,
        tokenStatus: tokenStatus,
        tokenService: tokenService,
        tokenDoctor: tokenDoctor,
        tokenJoinedAt: tokenJoinedAt,
        totalBookings: apptsCount > 0
            ? apptsCount
            : (d['visitsCount'] as int? ?? 0),
        totalQueues: queuesCount > 0
            ? queuesCount
            : (d['queuesCount'] as int? ?? 0),
      );

      usersById[uid] = user;
      if (email.isNotEmpty) emailToId[email] = uid;
      if (phone.isNotEmpty) phoneToId[phone] = uid;
    }

    // Also harvest patient records from appointments if not in usersById
    for (final doc in appts) {
      final d = doc.data();
      final uid = (d['customerId'] ?? d['userId'] ?? d['patientId'] ?? '')
          .toString()
          .trim();
      final email =
          (d['customerEmail'] ?? d['userEmail'] ?? d['patientEmail'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      final phone =
          (d['customerPhone'] ?? d['userPhone'] ?? d['patientPhone'] ?? '')
              .toString()
              .trim();
      final name =
          (d['customerName'] ?? d['userName'] ?? d['patientName'] ?? '')
              .toString()
              .trim();

      if (name.isEmpty && email.isEmpty && phone.isEmpty) continue;
      if (usersById.containsKey(uid) ||
          (email.isNotEmpty && emailToId.containsKey(email)) ||
          (phone.isNotEmpty && phoneToId.containsKey(phone))) {
        continue;
      }

      final keyId = uid.isNotEmpty
          ? uid
          : (email.isNotEmpty ? email : (phone.isNotEmpty ? phone : doc.id));
      final activeTicket =
          activeTicketByKey[keyId] ??
          activeTicketByKey[email] ??
          activeTicketByKey[phone];
      final tokenCode =
          (activeTicket?['tokenCode'] ??
                  activeTicket?['ticketNumber'] ??
                  activeTicket?['token'])
              ?.toString();
      final tokenStatus = activeTicket?['status']?.toString();
      final tokenService = activeTicket?['serviceName']?.toString();
      final tokenDoctor = activeTicket?['doctorName']?.toString();
      final tokenClinic = activeTicket?['clinicName']?.toString();

      String? tokenJoinedAt;
      final rawJoined = activeTicket?['joinedAt'];
      if (rawJoined is Timestamp) {
        final t = rawJoined.toDate();
        tokenJoinedAt =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      } else if (rawJoined is String) {
        tokenJoinedAt = rawJoined;
      }

      final int apptsCount =
          (totalApptsByKey[keyId] ?? 0) + (totalApptsByKey[email] ?? 0);
      final int queuesCount =
          (totalQueuesByKey[keyId] ?? 0) + (totalQueuesByKey[email] ?? 0);

      String initials = 'P';
      if (name.isNotEmpty) {
        final p = name
            .split(RegExp(r'\s+'))
            .where((s) => s.isNotEmpty)
            .toList();
        initials = p.length > 1
            ? '${p[0][0]}${p.last[0]}'.toUpperCase()
            : p[0][0].toUpperCase();
      }

      DateTime? apptDate;
      final rawApptDate =
          d['createdAt'] ?? d['bookedAt'] ?? d['dateTime'] ?? d['date'];
      if (rawApptDate is Timestamp) {
        apptDate = rawApptDate.toDate();
      } else if (rawApptDate is String) {
        apptDate = DateTime.tryParse(rawApptDate);
      }
      final memberSince = _formatDateTime(rawApptDate);

      final isWalkIn =
          (d['isWalkIn'] == true) ||
          name.toLowerCase().contains('walk-in') ||
          (d['source'] == 'walk-in');
      final userType = isWalkIn ? 'walk-in' : 'platform_user';

      final patient = PlatformUserEntity(
        id: keyId,
        name: name.isNotEmpty ? name : 'Patient User',
        initials: initials,
        email: email,
        phone: phone,
        healthId:
            'QF-${keyId.substring(0, keyId.length >= 6 ? 6 : keyId.length).toUpperCase()}',
        homeClinicName:
            tokenClinic ?? (d['clinicName'] ?? 'Unassigned').toString(),
        activeQueueToken: tokenCode,
        activeQueueStatus: tokenStatus,
        activeQueueService: tokenService,
        activeQueueDoctor: tokenDoctor,
        activeQueueJoinedAt: tokenJoinedAt,
        memberSince: memberSince,
        totalBookings: apptsCount > 0 ? apptsCount : 1,
        totalQueues: queuesCount,
        isVerified: phone.isNotEmpty || email.isNotEmpty,
        status: tokenCode != null && tokenCode.isNotEmpty
            ? 'in-queue'
            : 'active',
        userType: userType,
        createdAt: apptDate,
      );

      usersById[keyId] = patient;
      if (email.isNotEmpty) emailToId[email] = keyId;
      if (phone.isNotEmpty) phoneToId[phone] = keyId;
    }

    // Also harvest patient records from tickets if not in usersById
    for (final doc in tickets) {
      final d = doc.data();
      final uid = (d['patientId'] ?? d['userId'] ?? d['customerId'] ?? '')
          .toString()
          .trim();
      final email =
          (d['patientEmail'] ?? d['userEmail'] ?? d['customerEmail'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      final phone =
          (d['patientPhone'] ?? d['userPhone'] ?? d['customerPhone'] ?? '')
              .toString()
              .trim();
      final name =
          (d['patientName'] ?? d['userName'] ?? d['customerName'] ?? '')
              .toString()
              .trim();

      if (name.isEmpty && email.isEmpty && phone.isEmpty) continue;
      if (usersById.containsKey(uid) ||
          (email.isNotEmpty && emailToId.containsKey(email)) ||
          (phone.isNotEmpty && phoneToId.containsKey(phone))) {
        continue;
      }

      final keyId = uid.isNotEmpty
          ? uid
          : (email.isNotEmpty ? email : (phone.isNotEmpty ? phone : doc.id));
      final tokenCode = (d['tokenCode'] ?? d['ticketNumber'] ?? d['token'])
          ?.toString();
      final tokenStatus = d['status']?.toString();
      final tokenService = d['serviceName']?.toString();
      final tokenDoctor = d['doctorName']?.toString();
      final tokenClinic = d['clinicName']?.toString();

      String? tokenJoinedAt;
      final rawJoined = d['joinedAt'];
      if (rawJoined is Timestamp) {
        final t = rawJoined.toDate();
        tokenJoinedAt =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      } else if (rawJoined is String) {
        tokenJoinedAt = rawJoined;
      }

      final int apptsCount =
          (totalApptsByKey[keyId] ?? 0) + (totalApptsByKey[email] ?? 0);
      final int queuesCount =
          (totalQueuesByKey[keyId] ?? 0) + (totalQueuesByKey[email] ?? 0);

      String initials = 'P';
      if (name.isNotEmpty) {
        final p = name
            .split(RegExp(r'\s+'))
            .where((s) => s.isNotEmpty)
            .toList();
        initials = p.length > 1
            ? '${p[0][0]}${p.last[0]}'.toUpperCase()
            : p[0][0].toUpperCase();
      }

      DateTime? ticketDate;
      final rawTicketDate = d['joinedAt'] ?? d['createdAt'] ?? d['timestamp'];
      if (rawTicketDate is Timestamp) {
        ticketDate = rawTicketDate.toDate();
      } else if (rawTicketDate is String) {
        ticketDate = DateTime.tryParse(rawTicketDate);
      }
      final memberSince = _formatDateTime(rawTicketDate);

      final isWalkIn =
          (d['isWalkIn'] == true) ||
          name.toLowerCase().contains('walk-in') ||
          (d['source'] == 'walk-in');
      final userType = isWalkIn ? 'walk-in' : 'platform_user';

      final isQueueActive = tokenStatus == 'waiting' || tokenStatus == 'called';

      final patient = PlatformUserEntity(
        id: keyId,
        name: name.isNotEmpty ? name : 'Patient User',
        initials: initials,
        email: email,
        phone: phone,
        healthId:
            'QF-${keyId.substring(0, keyId.length >= 6 ? 6 : keyId.length).toUpperCase()}',
        homeClinicName: tokenClinic ?? 'Unassigned',
        activeQueueToken: isQueueActive ? tokenCode : null,
        activeQueueStatus: isQueueActive ? tokenStatus : null,
        activeQueueService: isQueueActive ? tokenService : null,
        activeQueueDoctor: isQueueActive ? tokenDoctor : null,
        activeQueueJoinedAt: isQueueActive ? tokenJoinedAt : null,
        memberSince: memberSince,
        totalBookings: apptsCount,
        totalQueues: queuesCount > 0 ? queuesCount : 1,
        isVerified: phone.isNotEmpty || email.isNotEmpty,
        status: isQueueActive ? 'in-queue' : 'active',
        userType: userType,
        createdAt: ticketDate,
      );

      usersById[keyId] = patient;
      if (email.isNotEmpty) emailToId[email] = keyId;
      if (phone.isNotEmpty) phoneToId[phone] = keyId;
    }

    return usersById.values.toList();
  }

  @override
  Future<void> setUserStatus(String userId, String status) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user $userId status: $e');
      rethrow;
    }
  }

  @override
  Future<void> registerPatient({
    required String name,
    required String phone,
    required String email,
    String? age,
    String? gender,
    String? bloodGroup,
    String? clinicId,
    String? clinicName,
    String? emergencyContact,
    String? notes,
  }) async {
    try {
      final docRef = _firestore.collection('users').doc();
      final healthId =
          'QF-${docRef.id.substring(0, docRef.id.length >= 6 ? 6 : docRef.id.length).toUpperCase()}';

      await docRef.set({
        'name': name.trim(),
        'fullName': name.trim(),
        'phone': phone.trim(),
        'phoneNumber': phone.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'patient',
        'status': 'active',
        'isVerified': true,
        'healthId': healthId,
        'userType': 'platform_user',
        'age': age?.trim(),
        'gender': gender?.trim(),
        'bloodGroup': bloodGroup?.trim(),
        'clinicId': clinicId?.trim(),
        'clinicName': clinicName?.trim(),
        'emergencyContact': emergencyContact?.trim(),
        'notes': notes?.trim(),
        'visitsCount': 0,
        'queuesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error registering patient in platform admin: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendNotification({
    required String targetUserId,
    required String title,
    required String message,
    String? targetEmail,
    String? type,
  }) async {
    try {
      final isBroadcast = targetUserId == 'all';
      await _firestore.collection('notifications').add({
        'title': title.trim(),
        'desc': message.trim(),
        'message': message.trim(),
        'userId': targetUserId,
        'userEmail':
            targetEmail?.trim().toLowerCase() ?? (isBroadcast ? 'all' : ''),
        'isBroadcast': isBroadcast,
        'type': type ?? (isBroadcast ? 'broadcast' : 'personal'),
        'unread': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending notification from platform admin: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, String>>> getActiveClinics() async {
    try {
      final snap = await _firestore.collection('clinics').get();
      final list = <Map<String, String>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final name = (d['name'] ?? '').toString().trim();
        final adminEmail = (d['adminEmail'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        if (TenantRepositoryImpl.isDummyClinicName(name, adminEmail)) continue;

        list.add({'id': doc.id, 'name': name});
      }
      list.sort((a, b) => a['name']!.compareTo(b['name']!));
      return list;
    } catch (e) {
      debugPrint('Error fetching active clinics: $e');
      return [];
    }
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
        _firestore
            .collection('appointments')
            .where('customerId', isEqualTo: userId),
        _firestore
            .collection('appointments')
            .where('userId', isEqualTo: userId),
        _firestore
            .collection('appointments')
            .where('patientId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        apptQueries.add(
          _firestore
              .collection('appointments')
              .where('customerEmail', isEqualTo: cleanEmail),
        );
        apptQueries.add(
          _firestore
              .collection('appointments')
              .where('patientEmail', isEqualTo: cleanEmail),
        );
        apptQueries.add(
          _firestore
              .collection('appointments')
              .where('userEmail', isEqualTo: cleanEmail),
        );
      }
      await collectDocs('appointments', apptQueries);

      // 2. Tickets
      final ticketQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('tickets').where('patientId', isEqualTo: userId),
        _firestore.collection('tickets').where('userId', isEqualTo: userId),
        _firestore.collection('tickets').where('customerId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        ticketQueries.add(
          _firestore
              .collection('tickets')
              .where('patientEmail', isEqualTo: cleanEmail),
        );
        ticketQueries.add(
          _firestore
              .collection('tickets')
              .where('userEmail', isEqualTo: cleanEmail),
        );
      }
      await collectDocs('tickets', ticketQueries);

      // 3. Reviews
      final reviewQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('reviews').where('userId', isEqualTo: userId),
        _firestore.collection('reviews').where('patientId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        reviewQueries.add(
          _firestore
              .collection('reviews')
              .where('userEmail', isEqualTo: cleanEmail),
        );
      }
      await collectDocs('reviews', reviewQueries);

      // 4. Doctor Reviews
      final docReviewQueries = <Query<Map<String, dynamic>>>[
        _firestore
            .collection('doctor_reviews')
            .where('userId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        docReviewQueries.add(
          _firestore
              .collection('doctor_reviews')
              .where('userEmail', isEqualTo: cleanEmail),
        );
      }
      await collectDocs('doctor_reviews', docReviewQueries);

      // 5. Notifications
      final notifQueries = <Query<Map<String, dynamic>>>[
        _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        notifQueries.add(
          _firestore
              .collection('notifications')
              .where('userEmail', isEqualTo: cleanEmail),
        );
      }
      await collectDocs('notifications', notifQueries);

      // 6. Support Tickets
      final supportQueries = <Query<Map<String, dynamic>>>[
        _firestore
            .collection('support_tickets')
            .where('patientId', isEqualTo: userId),
        _firestore
            .collection('support_tickets')
            .where('userId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        supportQueries.add(
          _firestore
              .collection('support_tickets')
              .where('userEmail', isEqualTo: cleanEmail),
        );
      }
      await collectDocs('support_tickets', supportQueries);

      // 7. Payments
      final payQueries = <Query<Map<String, dynamic>>>[
        _firestore.collection('payments').where('userId', isEqualTo: userId),
        _firestore
            .collection('payments')
            .where('customerId', isEqualTo: userId),
      ];
      if (cleanEmail != null && cleanEmail.isNotEmpty) {
        payQueries.add(
          _firestore
              .collection('payments')
              .where('userEmail', isEqualTo: cleanEmail),
        );
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
          final subSnap = await _firestore
              .collection('users')
              .doc(userId)
              .collection(sub)
              .get();
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

      // Finally delete user root document
      try {
        await _firestore.collection('users').doc(userId).delete();
      } catch (_) {}
    } catch (e) {
      debugPrint('Error deleting user $userId from platform admin: $e');
      rethrow;
    }
  }

  static String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return '—';
    DateTime? dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is String) {
      dt = DateTime.tryParse(timestamp);
    }
    if (dt == null) return timestamp.toString();

    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthName = (dt.month >= 1 && dt.month <= 12)
        ? months[dt.month - 1]
        : 'Jan';
    return '${dt.day.toString().padLeft(2, '0')} $monthName ${dt.year}, $hour:$minute $period';
  }
}
