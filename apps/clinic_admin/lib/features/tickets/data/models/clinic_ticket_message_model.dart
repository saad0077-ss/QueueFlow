import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_ticket_message_entity.dart';

class ClinicTicketMessageModel extends ClinicTicketMessage {
  const ClinicTicketMessageModel({
    required super.sender,
    super.senderRole = 'clinic_admin',
    required super.text,
    required super.time,
    required super.isUser,
    super.isInternalNote = false,
    super.createdAt,
  });

  factory ClinicTicketMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final raw = json['createdAt'];
    if (raw is Timestamp) {
      created = raw.toDate();
    } else if (raw is String) {
      created = DateTime.tryParse(raw);
    }

    final role =
        (json['senderRole'] ??
                (json['isUser'] == true ? 'patient' : 'clinic_admin'))
            .toString();
    final isInternal =
        json['isInternalNote'] as bool? ?? json['isInternal'] as bool? ?? false;

    return ClinicTicketMessageModel(
      sender:
          (json['sender'] ??
                  json['senderName'] ??
                  (role == 'patient' ? 'Patient' : 'Clinic Care Desk'))
              .toString(),
      senderRole: role,
      text: (json['text'] ?? '').toString(),
      time: (json['time'] ?? 'Just now').toString(),
      isUser: json['isUser'] as bool? ?? (role == 'patient'),
      isInternalNote: isInternal,
      createdAt: created,
    );
  }

  factory ClinicTicketMessageModel.fromEntity(ClinicTicketMessage entity) {
    return ClinicTicketMessageModel(
      sender: entity.sender,
      senderRole: entity.senderRole,
      text: entity.text,
      time: entity.time,
      isUser: entity.isUser,
      isInternalNote: entity.isInternalNote,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'senderName': sender,
      'senderRole': senderRole,
      'text': text,
      'time': time,
      'isUser': isUser,
      'isInternalNote': isInternalNote,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
