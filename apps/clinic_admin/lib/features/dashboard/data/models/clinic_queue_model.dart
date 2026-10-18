import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_queue_entity.dart';

/// Data model representing the clinic queue with Firestore serialization.
class ClinicQueueModel extends ClinicQueueEntity {
  const ClinicQueueModel({
    super.currentToken,
    super.totalIssued,
    super.waitingCount,
    super.status,
    super.isPaused,
  });

  /// Factory to parse from a Firestore document snapshot.
  factory ClinicQueueModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      return const ClinicQueueModel();
    }
    final data = doc.data() as Map<String, dynamic>;
    final rawToken = data['currentToken'] as String?;
    final currentToken = (rawToken == null || rawToken.isEmpty || rawToken == '---')
        ? 'A-029'
        : rawToken;
    final totalIssued = data['totalIssued'] as int? ?? 29;
    final waitingCount = data['waitingCount'] as int? ?? 0;
    final status = data['status'] as String? ?? 'open';
    final isPaused = status == 'paused';

    return ClinicQueueModel(
      currentToken: currentToken,
      totalIssued: totalIssued,
      waitingCount: waitingCount,
      status: status,
      isPaused: isPaused,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentToken': currentToken,
      'totalIssued': totalIssued,
      'waitingCount': waitingCount,
      'status': isPaused ? 'paused' : 'open',
    };
  }
}
