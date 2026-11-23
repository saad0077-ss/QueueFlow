import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/platform_support_ticket_model.dart';
import '../models/platform_ticket_message_model.dart';
import 'platform_tickets_remote_datasource.dart';

class PlatformTicketsRemoteDataSourceImpl
    implements PlatformTicketsRemoteDataSource {
  final FirebaseFirestore _firestore;

  PlatformTicketsRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? _safeFirestore();

  static FirebaseFirestore _safeFirestore() => FirebaseFirestore.instance;

  @override
  Stream<List<PlatformSupportTicketModel>> watchAllTickets() {
    return _firestore.collection('support_tickets').snapshots().map((snap) {
      final list = <PlatformSupportTicketModel>[];
      for (final doc in snap.docs) {
        try {
          list.add(PlatformSupportTicketModel.fromFirestore(doc));
        } catch (e) {
          debugPrint('Error parsing platform support ticket ${doc.id}: $e');
        }
      }

      list.sort(
        (a, b) => (b.createdAtDate ?? DateTime(2000)).compareTo(
          a.createdAtDate ?? DateTime(2000),
        ),
      );
      return list;
    });
  }

  @override
  Future<void> sendReply({
    required String ticketId,
    required String text,
    required String senderName,
    bool isInternalNote = false,
  }) async {
    final msg = PlatformTicketMessageModel(
      sender: senderName,
      senderRole: 'platform_owner',
      text: text,
      time: 'Just now',
      isUser: false,
      isInternalNote: isInternalNote,
      createdAt: DateTime.now(),
    );

    final docRef = _firestore.collection('support_tickets').doc(ticketId);
    final snap = await docRef.get();
    final currentStatus = (snap.data()?['status'] ?? 'open').toString();
    final Map<String, dynamic> updateData = {
      'messages': FieldValue.arrayUnion([msg.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
      'assignedTo': senderName,
    };
    if (currentStatus == 'open' && !isInternalNote) {
      updateData['status'] = 'in_progress';
    }
    await docRef.update(updateData);
  }

  @override
  Future<void> updateStatus({
    required String ticketId,
    required String status,
    String staffName = 'Platform Admin',
  }) async {
    final isReopen = status.toLowerCase() != 'resolved';
    final sysMsg = PlatformTicketMessageModel(
      sender: 'System Alert',
      senderRole: 'system',
      text: isReopen
          ? '🔄 Ticket reopened by $staffName. Chat is now active.'
          : '✓ Ticket marked as resolved by $staffName.',
      time: 'Just now',
      isUser: false,
      isInternalNote: false,
      createdAt: DateTime.now(),
    );

    final Map<String, dynamic> updateData = {
      'status': status.toLowerCase(),
      'messages': FieldValue.arrayUnion([sysMsg.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (status.toLowerCase() == 'resolved') {
      updateData['resolvedAt'] = 'Just now';
    }
    await _firestore
        .collection('support_tickets')
        .doc(ticketId)
        .update(updateData);
  }

  @override
  Future<void> updatePriority({
    required String ticketId,
    required String priority,
  }) {
    final prio = priority.toLowerCase();
    final sla = prio == 'high' ? 5 : (prio == 'medium' ? 15 : 25);
    return _firestore.collection('support_tickets').doc(ticketId).update({
      'priority': prio,
      'slaMinutes': sla,
      'slaNotice': '< ${sla}m SLA',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reassignClinic({
    required String ticketId,
    required String newClinicId,
    required String newClinicName,
    required String adminName,
  }) async {
    final sysMsg = PlatformTicketMessageModel(
      sender: 'Platform Operations',
      senderRole: 'system',
      text:
          '🔄 Ticket reassigned to $newClinicName by Platform Admin $adminName',
      time: 'Just now',
      isUser: false,
      isInternalNote: false,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('support_tickets').doc(ticketId).update({
      'clinicId': newClinicId,
      'clinicName': newClinicName,
      'isClinicRelated': true,
      'messages': FieldValue.arrayUnion([sysMsg.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteTicket({required String ticketId}) =>
      _firestore.collection('support_tickets').doc(ticketId).delete();
}
