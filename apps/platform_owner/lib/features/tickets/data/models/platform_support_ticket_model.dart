import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_ticket_message_model.dart';

class PlatformSupportTicketModel extends PlatformSupportTicketEntity {
  const PlatformSupportTicketModel({
    required super.id,
    required super.ticketNumber,
    super.patientId = '',
    required super.patientName,
    super.patientEmail = '',
    super.patientPhone = '',
    super.patientPhoto = '',
    required super.clinicId,
    required super.clinicName,
    super.isClinicRelated = true,
    super.linkedTokenNumber,
    required super.category,
    required super.subject,
    required super.description,
    required super.status,
    required super.priority,
    super.slaMinutes = 15,
    super.slaNotice = '< 15m SLA',
    super.assignedTo,
    super.resolvedAt,
    super.isEscalated = false,
    required super.createdAt,
    super.createdAtDate,
    required super.messages,
  });

  factory PlatformSupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final id = doc.id;

    DateTime? createdDate;
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      createdDate = rawCreated.toDate();
    } else if (rawCreated is String) {
      createdDate = DateTime.tryParse(rawCreated);
    }

    final ticketNumber =
        data['ticketNumber'] as String? ??
        (id.startsWith('TK-')
            ? id
            : 'TK-${id.substring(0, id.length >= 6 ? 6 : id.length).toUpperCase()}');

    final rawMessages = data['messages'] as List<dynamic>? ?? [];
    final messages = rawMessages
        .map(
          (m) => PlatformTicketMessageModel.fromJson(m as Map<String, dynamic>),
        )
        .toList();

    final prio = (data['priority'] as String? ?? 'medium').toLowerCase();
    final sla =
        data['slaMinutes'] as int? ??
        (prio == 'high' ? 5 : (prio == 'medium' ? 15 : 25));

    final timeDisplay = createdDate != null
        ? '${createdDate.hour}:${createdDate.minute.toString().padLeft(2, '0')}'
        : (data['createdAt'] is String ? data['createdAt'] as String : 'Today');

    return PlatformSupportTicketModel(
      id: id,
      ticketNumber: ticketNumber,
      patientId: (data['patientId'] ?? data['userId'] ?? '').toString(),
      patientName: (data['patientName'] ?? data['userName'] ?? 'Patient')
          .toString(),
      patientEmail: (data['patientEmail'] ?? data['userEmail'] ?? '')
          .toString(),
      patientPhone: (data['patientPhone'] ?? data['userPhone'] ?? '')
          .toString(),
      patientPhoto:
          (data['patientPhoto'] ??
                  data['photoUrl'] ??
                  data['photoBase64'] ??
                  data['userPhoto'] ??
                  data['avatar'] ??
                  data['patientAvatar'] ??
                  data['photo'] ??
                  '')
              .toString(),
      clinicId: (data['clinicId'] ?? '').toString(),
      clinicName: (data['clinicName'] ?? 'Clinic').toString(),
      isClinicRelated: data['isClinicRelated'] as bool? ?? true,
      linkedTokenNumber: data['linkedTokenNumber'] as String?,
      category: (data['category'] ?? 'queue').toString(),
      subject: (data['subject'] ?? 'Patient Inquiry').toString(),
      description: (data['description'] ?? '').toString(),
      status: (data['status'] ?? 'open').toString().toLowerCase(),
      priority: prio,
      slaMinutes: sla,
      slaNotice: (data['slaNotice'] ?? '< ${sla}m SLA').toString(),
      assignedTo: data['assignedTo'] as String?,
      resolvedAt: data['resolvedAt'] as String?,
      isEscalated: data['isEscalated'] as bool? ?? false,
      createdAt: timeDisplay,
      createdAtDate: createdDate,
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketNumber': ticketNumber,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      'patientPhoto': patientPhoto,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'isClinicRelated': isClinicRelated,
      'linkedTokenNumber': linkedTokenNumber,
      'category': category,
      'subject': subject,
      'description': description,
      'status': status,
      'priority': priority,
      'slaMinutes': slaMinutes,
      'slaNotice': slaNotice,
      'assignedTo': assignedTo,
      'resolvedAt': resolvedAt,
      'isEscalated': isEscalated,
      'messages': messages
          .map((m) => PlatformTicketMessageModel.fromEntity(m).toJson())
          .toList(),
    };
  }
}
