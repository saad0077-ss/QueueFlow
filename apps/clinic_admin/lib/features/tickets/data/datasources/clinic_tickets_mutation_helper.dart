import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clinic_ticket_message_model.dart';

class ClinicTicketsMutationHelper {
  static Future<void> sendReply({
    required FirebaseFirestore firestore,
    required String ticketId,
    required String text,
    required String staffName,
    bool isInternalNote = false,
  }) async {
    final msg = ClinicTicketMessageModel(
      sender: staffName,
      senderRole: 'clinic_admin',
      text: text,
      time: 'Just now',
      isUser: false,
      isInternalNote: isInternalNote,
      createdAt: DateTime.now(),
    );

    final docRef = firestore.collection('support_tickets').doc(ticketId);
    final snap = await docRef.get();
    final currentStatus = (snap.data()?['status'] ?? 'open').toString();

    final Map<String, dynamic> updateData = {
      'messages': FieldValue.arrayUnion([msg.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
      'assignedTo': staffName,
    };

    if (currentStatus == 'open' && !isInternalNote) {
      updateData['status'] = 'in_progress';
    }

    await docRef.update(updateData);
  }

  static Future<void> updateStatus({
    required FirebaseFirestore firestore,
    required String ticketId,
    required String status,
    String staffName = 'Clinic Admin',
  }) async {
    final isReopen = status.toLowerCase() != 'resolved';
    final sysMsg = ClinicTicketMessageModel(
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
    await firestore
        .collection('support_tickets')
        .doc(ticketId)
        .update(updateData);
  }

  static Future<void> updatePriority({
    required FirebaseFirestore firestore,
    required String ticketId,
    required String priority,
  }) async {
    final prio = priority.toLowerCase();
    final sla = prio == 'high' ? 5 : (prio == 'medium' ? 15 : 25);
    await firestore.collection('support_tickets').doc(ticketId).update({
      'priority': prio,
      'slaMinutes': sla,
      'slaNotice': '< ${sla}m SLA',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> escalateTicket({
    required FirebaseFirestore firestore,
    required String ticketId,
    required String staffName,
  }) async {
    final sysMsg = ClinicTicketMessageModel(
      sender: 'System Alert',
      senderRole: 'system',
      text: '🚨 Ticket escalated from $staffName to Platform Admin.',
      time: 'Just now',
      isUser: false,
      isInternalNote: false,
      createdAt: DateTime.now(),
    );

    await firestore.collection('support_tickets').doc(ticketId).update({
      'isEscalated': true,
      'priority': 'high',
      'messages': FieldValue.arrayUnion([sysMsg.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
