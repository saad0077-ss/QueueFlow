import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/support_ticket_entity.dart';
import 'default_support_tickets.dart';
import 'ticket_message_model.dart';

export 'default_support_tickets.dart';
export 'ticket_message_model.dart';

class SupportTicketModel extends SupportTicketEntity {
  const SupportTicketModel({
    required super.id,
    super.ticketNumber,
    super.patientId,
    super.patientName,
    super.patientEmail,
    super.patientPhone,
    required super.clinicId,
    required super.clinicName,
    super.isClinicRelated,
    super.linkedTokenNumber,
    required super.category,
    required super.subject,
    required super.description,
    required super.status,
    required super.priority,
    required super.createdAt,
    super.createdAtDate,
    super.updatedAtDate,
    required super.slaNotice,
    super.slaMinutes,
    super.rating,
    super.assignedTo,
    super.resolvedAt,
    required super.messages,
  });

  factory SupportTicketModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    final messages = rawMessages
        .map((m) => TicketMessageModel.fromJson(m as Map<String, dynamic>))
        .toList();

    DateTime? createdDate;
    final rawCreated = json['createdAt'];
    if (rawCreated is Timestamp) {
      createdDate = rawCreated.toDate();
    } else if (rawCreated is String) {
      createdDate = DateTime.tryParse(rawCreated);
    }

    DateTime? updatedDate;
    final rawUpdated = json['updatedAt'];
    if (rawUpdated is Timestamp) {
      updatedDate = rawUpdated.toDate();
    } else if (rawUpdated is String) {
      updatedDate = DateTime.tryParse(rawUpdated);
    }

    final id = docId ?? json['id'] as String? ?? 'TKT-104';
    final ticketNumber =
        json['ticketNumber'] as String? ??
        (id.startsWith('TK-') || id.startsWith('TKT-')
            ? id
            : 'TK-${id.substring(0, id.length >= 6 ? 6 : id.length).toUpperCase()}');

    final priority = (json['priority'] as String? ?? 'medium').toLowerCase();
    final slaMins =
        json['slaMinutes'] as int? ??
        (priority == 'high' ? 5 : (priority == 'medium' ? 15 : 25));

    final timeDisplay =
        json['createdAtDisplay'] as String? ??
        (createdDate != null
            ? '${createdDate.day}/${createdDate.month}/${createdDate.year} ${createdDate.hour}:${createdDate.minute.toString().padLeft(2, '0')}'
            : (json['createdAt'] is String
                  ? json['createdAt'] as String
                  : 'Today'));

    return SupportTicketModel(
      id: id,
      ticketNumber: ticketNumber,
      patientId: (json['patientId'] ?? json['userId'] ?? '').toString(),
      patientName: (json['patientName'] ?? json['userName'] ?? '').toString(),
      patientEmail: (json['patientEmail'] ?? json['userEmail'] ?? '')
          .toString(),
      patientPhone: (json['patientPhone'] ?? json['userPhone'] ?? '')
          .toString(),
      clinicId: json['clinicId'] as String? ?? '',
      clinicName: json['clinicName'] as String? ?? 'QueueFlow Support',
      isClinicRelated:
          json['isClinicRelated'] as bool? ??
          (json['clinicId'] != null && json['clinicId'] != ''),
      linkedTokenNumber: json['linkedTokenNumber'] as String?,
      category: json['category'] as String? ?? 'queue',
      subject: json['subject'] as String? ?? 'Support Inquiry',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      priority: priority,
      createdAt: timeDisplay,
      createdAtDate: createdDate,
      updatedAtDate: updatedDate,
      slaMinutes: slaMins,
      slaNotice: json['slaNotice'] as String? ?? '< ${slaMins}m SLA',
      rating: json['rating'] as int?,
      assignedTo: json['assignedTo'] as String?,
      resolvedAt: json['resolvedAt'] as String?,
      messages: messages,
    );
  }

  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return SupportTicketModel.fromJson(data, docId: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'isClinicRelated': isClinicRelated,
      'linkedTokenNumber': linkedTokenNumber,
      'category': category,
      'subject': subject,
      'description': description,
      'status': status,
      'priority': priority,
      'createdAt': createdAtDate != null
          ? Timestamp.fromDate(createdAtDate!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'slaNotice': slaNotice,
      'slaMinutes': slaMinutes,
      'rating': rating,
      'assignedTo': assignedTo,
      'resolvedAt': resolvedAt,
      'messages': messages.map((m) {
        if (m is TicketMessageModel) return m.toJson();
        return {
          'sender': m.sender,
          'senderName': m.sender,
          'text': m.text,
          'time': m.time,
          'isUser': m.isUser,
          'senderRole': m.senderRole,
          'createdAt': m.createdAt != null
              ? Timestamp.fromDate(m.createdAt!)
              : FieldValue.serverTimestamp(),
        };
      }).toList(),
    };
  }

  static List<SupportTicketModel> get defaultTickets =>
      DefaultSupportTickets.defaultTickets;
}
