import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/active_ticket_entity.dart';
import '../../domain/entities/clinic_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/active_ticket_model.dart';
import '../models/clinic_model.dart';

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

  HomeRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
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
      try {
        final snap = await _firestore
            .collection('tickets')
            .where('patientEmail', isEqualTo: user.email!.trim().toLowerCase())
            .where('status', whereIn: ['waiting', 'called', 'active'])
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty) {
          final doc = snap.docs.first;
          _cachedTicket = ActiveTicketModel.fromMap(doc.data(), id: doc.id);
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
  }) async {
    final user = _auth.currentUser;
    final nextNum = currentWaitingCount + 1;
    final tokenStr = 'A-${nextNum.toString().padLeft(3, '0')}';

    final ticket = ActiveTicketModel(
      id: 'q-${DateTime.now().millisecondsSinceEpoch}',
      token: tokenStr,
      clinicId: clinicId,
      clinicName: clinicName,
      serviceName: 'General Consultation',
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
  }
}
