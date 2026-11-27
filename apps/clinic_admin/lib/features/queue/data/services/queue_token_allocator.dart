import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import '../../domain/utils/clinic_token_generator.dart';

/// Allocates sequential service-scoped queue tokens for walk-ins & check-ins.
class QueueTokenAllocator {
  const QueueTokenAllocator._();

  static Future<({String serviceCode, int seq, String token})> allocate(
    FirebaseFirestore fs, {
    required String clinicId,
    required String clinicName,
    required String serviceName,
    List<ClinicQueueItemEntity> fallbackItems = const [],
  }) async {
    final eff = serviceName.trim().isNotEmpty
        ? serviceName.trim()
        : 'General Consultation';
    final code = ClinicTokenGenerator.extractServiceCode(eff);
    var nextSeq = 1;
    try {
      final qSnap = await fs.collection('queues').doc(clinicId).get();
      final qData = qSnap.data();
      final counter = _counterForService(qData, code, eff);
      if (counter != null) {
        nextSeq = counter + 1;
      } else {
        nextSeq = (await maxSeqFromTickets(fs, clinicId, eff)) + 1;
      }
    } catch (_) {
      nextSeq = _maxSeqFromFallback(fallbackItems, eff, code) + 1;
    }
    return (
      serviceCode: code,
      seq: nextSeq,
      token: ClinicTokenGenerator.generateToken(
        clinicName: clinicName,
        serviceName: eff,
        sequenceNumber: nextSeq,
      ),
    );
  }

  static int nextSeqFromQueueData(
    Map<String, dynamic>? queueData, {
    required String serviceCode,
    required String serviceName,
    required int fallbackMax,
  }) {
    final counter = _counterForService(queueData, serviceCode, serviceName);
    return (counter ?? fallbackMax) + 1;
  }

  static int? _counterForService(
    Map<String, dynamic>? queueData,
    String code,
    String serviceName,
  ) {
    final counters = queueData?['serviceCounters'];
    if (counters is! Map) return null;
    final raw = counters[code] ?? counters[serviceName];
    return raw is num ? raw.toInt() : null;
  }

  static Future<int> maxSeqFromTickets(
    FirebaseFirestore fs,
    String clinicId,
    String serviceName,
  ) async {
    final snap = await fs
        .collection('tickets')
        .where('clinicId', isEqualTo: clinicId)
        .where('serviceName', isEqualTo: serviceName)
        .get();
    var maxNum = 0;
    for (final doc in snap.docs) {
      final tok = (doc.data()['token'] ?? '').toString();
      final n = ClinicTokenGenerator.parseSequenceNumber(tok);
      if (n != null && n > maxNum) maxNum = n;
    }
    return maxNum;
  }

  static int _maxSeqFromFallback(
    List<ClinicQueueItemEntity> items,
    String serviceName,
    String code,
  ) {
    var maxNum = 0;
    for (final item in items) {
      if (item.serviceName.toLowerCase() == serviceName.toLowerCase() ||
          item.token.contains('-$code-')) {
        final n = ClinicTokenGenerator.parseSequenceNumber(item.token);
        if (n != null && n > maxNum) maxNum = n;
      }
    }
    return maxNum;
  }
}
