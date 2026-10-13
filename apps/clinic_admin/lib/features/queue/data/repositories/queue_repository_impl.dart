import 'package:cloud_firestore/cloud_firestore.dart';

class QueueRepositoryImpl {
  final FirebaseFirestore _firestore;
  final String clinicId;

  QueueRepositoryImpl({
    FirebaseFirestore? firestore,
    this.clinicId = 'clinic_main_01',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<DocumentSnapshot> watchQueue() {
    return _firestore.collection('queues').doc(clinicId).snapshots();
  }

  Future<void> callNextToken(int totalIssued) async {
    final queueRef = _firestore.collection('queues').doc(clinicId);
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(queueRef);
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      final waiting = data['waitingCount'] ?? 0;
      final currentNum = int.tryParse(
            (data['currentToken'] ?? 'A-000').replaceAll('A-', ''),
          ) ??
          0;
      if (waiting > 0 && currentNum < totalIssued) {
        final nextNum = currentNum + 1;
        final nextToken = 'A-${nextNum.toString().padLeft(3, '0')}';
        tx.update(queueRef, {
          'currentToken': nextToken,
          'waitingCount': waiting - 1,
          'lastCalledAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> issueWalkInToken(int totalIssued, int waitingCount) async {
    final queueRef = _firestore.collection('queues').doc(clinicId);
    final nextTotal = totalIssued + 1;
    final tokenString = 'A-${nextTotal.toString().padLeft(3, '0')}';
    await queueRef.set({
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

  Future<void> resetQueue() async {
    await _firestore.collection('queues').doc(clinicId).set({
      'currentToken': '---',
      'totalIssued': 0,
      'waitingCount': 0,
      'status': 'open',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
