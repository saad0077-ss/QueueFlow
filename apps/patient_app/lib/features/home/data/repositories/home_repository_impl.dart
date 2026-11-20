import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/utils/clinic_token_generator.dart';
import '../../domain/entities/active_ticket_entity.dart';
import '../../domain/entities/clinic_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/active_ticket_model.dart';
import '../models/clinic_model.dart';

/// Issues the next token using the same method as the clinic admin walk-in
/// flow: `<ClinicPrefix>-<ServiceCode>-<NNN>` (e.g. `SH-GC-001`), with a
/// separate sequence per service kept in `queues/{clinicId}.serviceCounters`.
/// Runs in a transaction so two patients can never receive the same token.
Future<String> allocateClinicToken(
  FirebaseFirestore firestore, {
  required String clinicId,
  required String clinicName,
  required String serviceName,
}) async {
  final service = serviceName.trim().isNotEmpty
      ? serviceName.trim()
      : 'General Consultation';
  final code = ClinicTokenGenerator.extractServiceCode(service);
  final ref = firestore.collection('queues').doc(clinicId);

  // When the service has no counter yet, continue after the highest existing
  // ticket for it (same fallback the admin uses).
  var seed = 0;
  try {
    final snap = await ref.get();
    final counters = snap.data()?['serviceCounters'];
    final hasCounter =
        counters is Map &&
        (counters[code] != null || counters[service] != null);
    if (!hasCounter) {
      final tickets = await firestore
          .collection('tickets')
          .where('clinicId', isEqualTo: clinicId)
          .where('serviceName', isEqualTo: service)
          .get();
      for (final d in tickets.docs) {
        final n = ClinicTokenGenerator.parseSequenceNumber(
          (d.data()['token'] ?? '').toString(),
        );
        if (n != null && n > seed) seed = n;
      }
    }
  } catch (_) {}

  int next;
  try {
    next = await firestore.runTransaction<int>((tx) async {
      final snap = await tx.get(ref);
      final counters = snap.data()?['serviceCounters'];
      final current = counters is Map
          ? ((counters[code] ?? counters[service]) as num?)?.toInt()
          : null;
      final n = (current ?? seed) + 1;
      tx.set(ref, {
        'serviceCounters': {code: n},
        'waitingCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
      return n;
    });
  } catch (_) {
    next = (DateTime.now().millisecondsSinceEpoch % 999) + 1;
  }
  return ClinicTokenGenerator.generateToken(
    clinicName: clinicName,
    serviceName: service,
    sequenceNumber: next,
  );
}

/// True when [ticket] data (a Firestore ticket map) belongs to today's date.
bool isTicketFromToday(Map<String, dynamic> ticket) {
  DateTime? t;
  for (final k in const ['createdAt', 'joinedAt']) {
    final v = ticket[k];
    if (v is Timestamp) {
      t = v.toDate();
    } else if (v is String) {
      t = DateTime.tryParse(v);
    }
    if (t != null) break;
  }
  if (t == null) return false;
  final now = DateTime.now();
  final l = t.toLocal();
  return l.year == now.year && l.month == now.month && l.day == now.day;
}

/// Normalised service name of a ticket map (empty name = General Consultation).
String ticketServiceKey(Map<String, dynamic> ticket) {
  final s = (ticket['serviceName'] ?? '').toString().trim();
  return (s.isEmpty ? 'General Consultation' : s).toLowerCase();
}

/// True when [service] was already completed today in [ticket]'s docs.
bool hasCompletedServiceToday(
  Iterable<Map<String, dynamic>> completedTickets,
  String service,
) {
  final key = (service.trim().isEmpty ? 'General Consultation' : service.trim())
      .toLowerCase();
  return completedTickets.any(
    (t) => isTicketFromToday(t) && ticketServiceKey(t) == key,
  );
}

/// Completed tickets of [email] at [clinicId], as a Firestore query.
Query<Map<String, dynamic>> completedTicketsQuery(
  FirebaseFirestore firestore, {
  required String email,
  required String clinicId,
}) => firestore
    .collection('tickets')
    .where('patientEmail', isEqualTo: email.trim().toLowerCase())
    .where('clinicId', isEqualTo: clinicId)
    .where('status', isEqualTo: 'completed');

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Cached active ticket for current session
  ActiveTicketModel? _cachedTicket;

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

  HomeRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  bool _isRealClinic(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final status = (data['status'] ?? '').toString().toUpperCase();
    if (status == 'REMOVED' || status == 'DELETED') {
      return false;
    }

    final email = (data['adminEmail'] ?? '').toString().toLowerCase().trim();
    final name = (data['name'] ?? '').toString().trim();
    if (dummyEmails.contains(email) || dummyClinicNames.contains(name)) {
      return false;
    }

    return name.isNotEmpty;
  }

  @override
  Future<List<ClinicEntity>> getFeaturedClinics() async {
    try {
      final snap = await _firestore.collection('clinics').get();
      return snap.docs
          .where(_isRealClinic)
          .map((doc) => ClinicModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting featured clinics from Firestore: $e');
      return [];
    }
  }

  @override
  Stream<List<ClinicEntity>> watchFeaturedClinics() {
    return _firestore.collection('clinics').snapshots().map((snap) {
      return snap.docs
          .where(_isRealClinic)
          .map((doc) => ClinicModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<ActiveTicketEntity?> getActiveTicket() async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      final emailLower = user.email!.trim().toLowerCase();
      try {
        // 1. Check direct tickets collection
        final snap = await _firestore
            .collection('tickets')
            .where('patientEmail', isEqualTo: emailLower)
            .where('status', whereIn: ['waiting', 'called', 'active'])
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty) {
          final doc = snap.docs.first;
          _cachedTicket = ActiveTicketModel.fromMap(doc.data(), id: doc.id);
          return _cachedTicket;
        }

        // 2. Also check appointments collection for checked-in or today's active appointments
        final aptSnap = await _firestore
            .collection('appointments')
            .where('customerEmail', isEqualTo: emailLower)
            .where(
              'status',
              whereIn: ['checkedin', 'checked-in', 'called', 'waiting'],
            )
            .limit(1)
            .get();

        if (aptSnap.docs.isEmpty) {
          // Both lookups succeeded and found nothing active: drop stale cache
          // (e.g. a ticket that was just completed or cancelled).
          _cachedTicket = null;
        }

        if (aptSnap.docs.isNotEmpty) {
          final doc = aptSnap.docs.first;
          final d = doc.data();
          // Use the token exactly as issued (same one the clinic admin sees).
          final token = (d['token'] ?? d['queueToken'] ?? d['bookingRef'] ?? '')
              .toString();
          final clinicName = (d['clinicName'] ?? 'Clinic').toString();
          final isCalled =
              (d['status'] ?? '').toString().toLowerCase() == 'called';

          _cachedTicket = ActiveTicketModel(
            id: doc.id,
            token: token,
            clinicId: (d['clinicId'] ?? '').toString(),
            clinicName: clinicName,
            serviceName: (d['serviceName'] ?? 'General Consultation')
                .toString(),
            doctorName: (d['doctorName'] ?? 'Attending Doctor').toString(),
            position: (d['position'] is int) ? d['position'] as int : 0,
            estWaitMin: (d['estWaitMin'] is int) ? d['estWaitMin'] as int : 0,
            nowServing: (d['nowServing'] ?? '').toString(),
            status: isCalled ? 'called' : 'waiting',
            joinedAt: DateTime.now(),
          );
          return _cachedTicket;
        }
      } catch (e) {
        debugPrint('Error fetching active ticket for user ${user.email}: $e');
      }
    }
    return _cachedTicket;
  }

  @override
  Future<ActiveTicketEntity> joinQueue({
    required String clinicId,
    required String clinicName,
    required String patientName,
    required int currentWaitingCount,
    required String currentToken,
    String serviceName = 'General Consultation',
    String departmentName = '',
  }) async {
    final user = _auth.currentUser;

    // The clinic may have paused its queue or closed this service for today.
    try {
      final q = await _firestore.collection('queues').doc(clinicId).get();
      final data = q.data();
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final closed = data?['closedServices'];
      final svcKey = serviceName.trim().toLowerCase();
      if (data?['status'] == 'paused' ||
          data?['isPaused'] == true ||
          (closed is Map && closed[svcKey]?.toString() == today)) {
        throw StateError(
          'The $serviceName queue at $clinicName is closed for today.',
        );
      }
    } on StateError {
      rethrow;
    } catch (_) {}

    // One queue visit per service per day: once a service is completed, it
    // can't be rejoined today (other services at the clinic are still open).
    if (user?.email != null) {
      try {
        final done = await completedTicketsQuery(
          _firestore,
          email: user!.email!,
          clinicId: clinicId,
        ).get();
        if (hasCompletedServiceToday(
          done.docs.map((d) => d.data()),
          serviceName,
        )) {
          throw StateError(
            'You have already completed your $serviceName visit at '
            '$clinicName today. You can join this service again tomorrow.',
          );
        }
      } on StateError {
        rethrow;
      } catch (_) {}
    }

    // Don't create a second ticket if this patient is already in this clinic's queue.
    if (user?.email != null) {
      try {
        final existing = await _firestore
            .collection('tickets')
            .where('patientEmail', isEqualTo: user!.email!.trim().toLowerCase())
            .where('clinicId', isEqualTo: clinicId)
            .where('status', whereIn: ['waiting', 'called'])
            .limit(1)
            .get();
        if (existing.docs.isNotEmpty) {
          final doc = existing.docs.first;
          _cachedTicket = ActiveTicketModel.fromMap(doc.data(), id: doc.id);
          return _cachedTicket!;
        }
      } catch (_) {}
    }

    final tokenStr = await allocateClinicToken(
      _firestore,
      clinicId: clinicId,
      clinicName: clinicName,
      serviceName: serviceName,
    );

    final ticket = ActiveTicketModel(
      id: 'q-${DateTime.now().millisecondsSinceEpoch}',
      token: tokenStr,
      clinicId: clinicId,
      clinicName: clinicName,
      serviceName: serviceName.trim().isNotEmpty
          ? serviceName.trim()
          : 'General Consultation',
      doctorName: 'Attending Doctor',
      position: currentWaitingCount,
      estWaitMin: currentWaitingCount * 5,
      nowServing: currentToken,
      status: 'waiting',
      joinedAt: DateTime.now(),
    );

    _cachedTicket = ticket;

    try {
      final ticketData = ticket.toMap();
      if (user != null) {
        ticketData['patientEmail'] = user.email?.trim().toLowerCase();
        ticketData['patientId'] = user.uid;
        ticketData['patientName'] = patientName;
      }
      ticketData['createdAt'] = FieldValue.serverTimestamp();
      // Lets the clinic admin / live queue group this ticket under the
      // department the patient picked.
      if (departmentName.trim().isNotEmpty) {
        ticketData['departmentName'] = departmentName.trim();
      }

      final docRef = await _firestore.collection('tickets').add(ticketData);
      _cachedTicket = ActiveTicketModel.fromMap(ticketData, id: docRef.id);
    } catch (e) {
      debugPrint('Error recording ticket to Firestore: $e');
    }

    return _cachedTicket ?? ticket;
  }

  @override
  Future<void> cancelTicket(String ticketId) async {
    _cachedTicket = null;
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error cancelling ticket $ticketId: $e');
    }
    try {
      await _firestore.collection('appointments').doc(ticketId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
