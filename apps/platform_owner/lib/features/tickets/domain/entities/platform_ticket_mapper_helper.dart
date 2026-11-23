import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/platform_ticket_message_model.dart';
import 'platform_support_ticket_entity.dart';

class PlatformTicketMapperHelper {
  static PlatformSupportTicketEntity fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    final id = doc.id;

    DateTime? createdDate;
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      createdDate = rawCreated.toDate();
    } else if (rawCreated is String) {
      createdDate = DateTime.tryParse(rawCreated);
    }

    final rawNum = data['ticketNumber'];
    final ticketNumber = rawNum != null && rawNum.toString().isNotEmpty
        ? rawNum.toString()
        : (id.startsWith('TK-')
            ? id
            : 'TK-${id.substring(0, id.length >= 6 ? 6 : id.length).toUpperCase()}');

    final rawMessages = data['messages'];
    final messages = <PlatformTicketMessage>[];
    if (rawMessages is List) {
      for (final m in rawMessages) {
        if (m is Map) {
          try {
            messages.add(
              PlatformTicketMessageModel.fromJson(
                Map<String, dynamic>.from(m),
              ),
            );
          } catch (e) {
            debugPrint('Error parsing platform message: $e');
          }
        }
      }
    }

    final prio = (data['priority']?.toString() ?? 'medium').toLowerCase();
    final rawSla = data['slaMinutes'];
    final sla = rawSla is num
        ? rawSla.toInt()
        : (int.tryParse(rawSla?.toString() ?? '') ??
            (prio == 'high' ? 5 : (prio == 'medium' ? 15 : 25)));

    final timeDisplay = createdDate != null
        ? '${createdDate.hour}:${createdDate.minute.toString().padLeft(2, '0')}'
        : (data['createdAt'] is String ? data['createdAt'] as String : 'Today');

    final photo = (data['patientPhoto'] ??
            data['photoBase64'] ??
            data['customerPhoto'] ??
            data['profilePhoto'] ??
            data['photoUrl'] ??
            data['userPhoto'] ??
            data['avatar'] ??
            data['patientAvatar'] ??
            data['photo'] ??
            '')
        .toString();

    final isClinic = data['isClinicRelated'] != false &&
        data['isClinicRelated'] != 'false';
    final isEscalated = data['isEscalated'] == true ||
        data['isEscalated'] == 'true';

    return PlatformSupportTicketEntity(
      id: id,
      ticketNumber: ticketNumber,
      patientId: (data['patientId'] ?? data['userId'] ?? '').toString(),
      patientName: (data['patientName'] ?? data['userName'] ?? 'Patient')
          .toString(),
      patientEmail: (data['patientEmail'] ?? data['userEmail'] ?? '').toString(),
      patientPhone: (data['patientPhone'] ?? data['userPhone'] ?? '').toString(),
      patientPhoto: photo,
      clinicId: (data['clinicId'] ?? '').toString(),
      clinicName: (data['clinicName'] ?? 'Clinic').toString(),
      isClinicRelated: isClinic,
      linkedTokenNumber: data['linkedTokenNumber']?.toString(),
      category: (data['category'] ?? 'queue').toString(),
      subject: (data['subject'] ?? 'Patient Inquiry').toString(),
      description: (data['description'] ?? '').toString(),
      status: (data['status'] ?? 'open').toString().toLowerCase(),
      priority: prio,
      slaMinutes: sla,
      slaNotice: (data['slaNotice'] ?? '< ${sla}m SLA').toString(),
      assignedTo: data['assignedTo']?.toString(),
      resolvedAt: data['resolvedAt']?.toString(),
      isEscalated: isEscalated,
      createdAt: timeDisplay,
      createdAtDate: createdDate,
      messages: messages,
    );
  }

  static Map<String, dynamic> toJson(PlatformSupportTicketEntity t) {
    return {
      'ticketNumber': t.ticketNumber,
      'patientId': t.patientId,
      'patientName': t.patientName,
      'patientEmail': t.patientEmail,
      'patientPhone': t.patientPhone,
      'patientPhoto': t.patientPhoto,
      'clinicId': t.clinicId,
      'clinicName': t.clinicName,
      'isClinicRelated': t.isClinicRelated,
      'linkedTokenNumber': t.linkedTokenNumber,
      'category': t.category,
      'subject': t.subject,
      'description': t.description,
      'status': t.status,
      'priority': t.priority,
      'slaMinutes': t.slaMinutes,
      'slaNotice': t.slaNotice,
      'assignedTo': t.assignedTo,
      'resolvedAt': t.resolvedAt,
      'isEscalated': t.isEscalated,
      'messages': t.messages
          .map((m) => PlatformTicketMessageModel.fromEntity(m).toJson())
          .toList(),
    };
  }
}
