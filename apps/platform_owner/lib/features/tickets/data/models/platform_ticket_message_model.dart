import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/platform_ticket_message_entity.dart';

class PlatformTicketMessageModel extends PlatformTicketMessage {
  const PlatformTicketMessageModel({
    required super.sender,
    super.senderRole = 'platform_owner',
    required super.text,
    required super.time,
    required super.isUser,
    super.isInternalNote = false,
    super.createdAt,
  });

  factory PlatformTicketMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final raw = json['createdAt'];
    if (raw is Timestamp) {
      created = raw.toDate();
    } else if (raw is String) {
      created = DateTime.tryParse(raw);
    }

    final isUserVal = json['isUser'] == true || json['isUser'] == 'true';
    final role = (json['senderRole'] ??
            (isUserVal ? 'patient' : 'platform_owner'))
        .toString();
    final isInternal = json['isInternalNote'] == true ||
        json['isInternalNote'] == 'true' ||
        json['isInternal'] == true ||
        json['isInternal'] == 'true';

    return PlatformTicketMessageModel(
      sender: (json['sender'] ??
              json['senderName'] ??
              (role == 'patient' ? 'Patient' : 'Platform Support'))
          .toString(),
      senderRole: role,
      text: (json['text'] ?? '').toString(),
      time: (json['time'] ?? 'Just now').toString(),
      isUser: json['isUser'] != null ? isUserVal : (role == 'patient'),
      isInternalNote: isInternal,
      createdAt: created,
    );
  }

  factory PlatformTicketMessageModel.fromEntity(PlatformTicketMessage entity) {
    return PlatformTicketMessageModel(
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
