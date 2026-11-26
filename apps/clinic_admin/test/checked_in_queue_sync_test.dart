import 'package:clinic_admin/features/queue/data/services/checked_in_queue_mapper.dart';
import 'package:clinic_admin/features/queue/data/services/queue_token_allocator.dart';
import 'package:clinic_admin/features/queue/domain/entities/clinic_queue_item_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckedInQueueMapper', () {
    test('recognizes checkedin and checked-in statuses case-insensitively', () {
      expect(CheckedInQueueMapper.isCheckedInStatus('checkedin'), isTrue);
      expect(CheckedInQueueMapper.isCheckedInStatus(' CHECKED-IN '), isTrue);
      expect(CheckedInQueueMapper.isCheckedInStatus('confirmed'), isFalse);
      expect(CheckedInQueueMapper.isCheckedInStatus('completed'), isFalse);
      expect(CheckedInQueueMapper.isCheckedInStatus(null), isFalse);
    });

    test('maps appointment fields to waiting queue item', () {
      final checkedInAt = DateTime(2026, 11, 26, 9, 15);
      final item = CheckedInQueueMapper.fromAppointmentMap('appt-1', {
        'clinicId': 'green-heaven',
        'customerName': 'Aarav Mehta',
        'serviceName': 'Orthopedic Joint Assessment',
        'doctorName': 'Dr. Rao',
        'serviceDuration': 25,
        'servicePrice': 800,
        'payment': {'status': 'paid', 'amount': 800},
        'checkedInAt': Timestamp.fromDate(checkedInAt),
      });

      expect(item.id, 'appt-1');
      expect(item.clinicId, 'green-heaven');
      expect(item.patientName, 'Aarav Mehta');
      expect(item.serviceName, 'Orthopedic Joint Assessment');
      expect(item.doctorName, 'Dr. Rao');
      expect(item.estDuration, '25 min');
      expect(item.fee, 800.0);
      expect(item.paymentStatus, 'paid');
      expect(item.status, 'waiting');
      expect(item.joinedTime, '9:15 AM');
      expect(item.joinedAt, checkedInAt);
    });

    test('merges missing checked-in appointments and suppresses represented ones', () {
      final now = DateTime(2026, 11, 26, 10, 0);
      final missingIds = <String>[];
      final completedTicket = ClinicQueueItemEntity(
        id: 'appt-done',
        token: 'GH-OJ-001',
        clinicId: 'green-heaven',
        patientName: 'Completed Patient',
        serviceName: 'Orthopedic Joint Assessment',
        joinedAt: now.subtract(const Duration(minutes: 30)),
        status: 'completed',
      );
      final linkedWalkInIdTicket = ClinicQueueItemEntity(
        id: 't-linked',
        token: 'GH-OJ-002',
        clinicId: 'green-heaven',
        patientName: 'Called Patient',
        serviceName: 'Orthopedic Joint Assessment',
        joinedAt: now.subtract(const Duration(minutes: 20)),
        status: 'called',
      );

      final merged = CheckedInQueueMapper.mergeEntries(
        ticketEntries: [
          (id: 'appt-done', appointmentId: '', item: completedTicket),
          (id: 't-linked', appointmentId: 'appt-called', item: linkedWalkInIdTicket),
          (
            id: 'appt-cancelled',
            appointmentId: 'appt-cancelled',
            item: completedTicket.copyWith(id: 'appt-cancelled', status: 'cancelled'),
          ),
        ],
        checkedInAppts: [
          (id: 'appt-done', data: {'clinicId': 'green-heaven', 'serviceName': 'Orthopedic Joint Assessment'}),
          (id: 'appt-called', data: {'clinicId': 'green-heaven', 'serviceName': 'Orthopedic Joint Assessment'}),
          (id: 'appt-cancelled', data: {'clinicId': 'green-heaven', 'serviceName': 'Orthopedic Joint Assessment'}),
          (
            id: 'appt-missing',
            data: {
              'clinicId': 'green-heaven',
              'customerName': 'Neha Kapoor',
              'serviceName': 'Orthopedic Joint Assessment',
              'checkedInAt': Timestamp.fromDate(now),
            },
          ),
        ],
        onMissingTicket: (id, _) => missingIds.add(id),
      );

      expect(missingIds, ['appt-missing']);
      expect(merged.map((e) => e.id).toList(), [
        't-linked', // called comes first
        'appt-missing', // waiting comes second
        'appt-done', // completed comes last
      ]);
      expect(merged[1].patientName, 'Neha Kapoor');
      expect(merged[1].status, 'waiting');
    });
  });

  group('QueueTokenAllocator', () {
    test('uses service counter by code or service name before fallback', () {
      expect(
        QueueTokenAllocator.nextSeqFromQueueData(
          {'serviceCounters': {'OJ': 3}},
          serviceCode: 'OJ',
          serviceName: 'Orthopedic Joint Assessment',
          fallbackMax: 1,
        ),
        4,
      );
      expect(
        QueueTokenAllocator.nextSeqFromQueueData(
          const {},
          serviceCode: 'OJ',
          serviceName: 'Orthopedic Joint Assessment',
          fallbackMax: 3,
        ),
        4,
      );
    });
  });
}
