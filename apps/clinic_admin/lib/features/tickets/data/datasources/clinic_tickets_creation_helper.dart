import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clinic_support_ticket_model.dart';
import '../models/clinic_ticket_message_model.dart';

class ClinicTicketsCreationHelper {
  static Future<ClinicSupportTicketModel> createManualTicket({
    required FirebaseFirestore firestore,
    required String clinicId,
    required String clinicName,
    required String patientName,
    required String patientPhone,
    String? patientEmail,
    String? tokenNumber,
    required String category,
    required String priority,
    required String subject,
    required String description,
  }) async {
    final ticketNum = (DateTime.now().millisecondsSinceEpoch % 9000) + 1000;
    final ticketCode = 'TK-$ticketNum';
    final prio = priority.toLowerCase();
    final sla = prio == 'high' ? 5 : (prio == 'medium' ? 15 : 25);

    final initMsg = ClinicTicketMessageModel(
      sender: patientName,
      senderRole: 'patient',
      text: description.isNotEmpty ? description : subject,
      time: 'Just now',
      isUser: true,
      createdAt: DateTime.now(),
    );

    final docRef = await firestore.collection('support_tickets').add({
      'ticketNumber': ticketCode,
      'patientId': 'walkin-${DateTime.now().millisecondsSinceEpoch}',
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientEmail': patientEmail ?? '',
      'clinicId': clinicId,
      'clinicName': clinicName,
      'isClinicRelated': true,
      'linkedTokenNumber': tokenNumber,
      'category': category,
      'priority': prio,
      'subject': subject,
      'description': description,
      'status': 'open',
      'slaMinutes': sla,
      'slaNotice': '< ${sla}m SLA',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'messages': [initMsg.toJson()],
    });

    final snap = await docRef.get();
    return ClinicSupportTicketModel.fromFirestore(snap);
  }
}
