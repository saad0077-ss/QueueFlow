import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_queue_entity.dart';
import '../../domain/repositories/clinic_dashboard_repository.dart';
import '../models/clinic_queue_model.dart';

/// Implementation of ClinicDashboardRepository using Firebase Firestore.
class ClinicDashboardRepositoryImpl implements ClinicDashboardRepository {
  final FirebaseFirestore _firestore;
  final String clinicId;

  ClinicDashboardRepositoryImpl({
    FirebaseFirestore? firestore,
    this.clinicId = 'clinic_main_01',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _queueRef =>
      _firestore.collection('queues').doc(clinicId);

  @override
  Stream<ClinicQueueEntity> watchQueue() {
    return _queueRef.snapshots().map((doc) => ClinicQueueModel.fromFirestore(doc));
  }

  @override
  Future<void> callNextToken(int totalIssued) async {
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(_queueRef);
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      final waiting = data['waitingCount'] as int? ?? 0;
      final currentNum = int.tryParse(
            (data['currentToken'] as String? ?? 'A-000').replaceAll('A-', ''),
          ) ??
          0;

      if (waiting > 0 && currentNum < totalIssued) {
        final nextNum = currentNum + 1;
        final nextToken = 'A-${nextNum.toString().padLeft(3, '0')}';
        tx.update(_queueRef, {
          'currentToken': nextToken,
          'waitingCount': waiting - 1,
          'lastCalledAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> issueWalkInToken(int totalIssued, int waitingCount) async {
    final nextTotal = totalIssued + 1;
    final tokenString = 'A-${nextTotal.toString().padLeft(3, '0')}';

    await _queueRef.set({
      'totalIssued': nextTotal,
      'waitingCount': waitingCount + 1,
      'status': 'open',
    }, SetOptions(merge: true));

    await _firestore.collection('tickets').add({
      'token': tokenString,
      'clinicId': clinicId,
      'patientName': 'Walk-In Patient #$nextTotal',
      'status': 'waiting',
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> togglePauseQueue(bool isPaused) async {
    await _queueRef.set({
      'status': isPaused ? 'paused' : 'open',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
