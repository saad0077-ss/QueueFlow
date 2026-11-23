import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/ticket_message_entity.dart';

class TicketMessageModel extends TicketMessageEntity {
  const TicketMessageModel({
    required super.sender,
    required super.text,
    required super.time,
    required super.isUser,
    super.senderRole,
    super.createdAt,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    final rawDate = json['createdAt'];
    if (rawDate is Timestamp) {
      dt = rawDate.toDate();
    } else if (rawDate is String) {
      dt = DateTime.tryParse(rawDate);
    }

    return TicketMessageModel(
      sender: json['sender'] as String? ?? json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      time:
          json['time'] as String? ??
          (dt != null
              ? '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}'
              : 'Just now'),
      isUser: json['isUser'] as bool? ?? (json['senderRole'] == 'patient'),
      senderRole:
          json['senderRole'] as String? ??
          (json['isUser'] == true ? 'patient' : 'clinic_admin'),
      createdAt: dt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'senderName': sender,
      'text': text,
      'time': time,
      'isUser': isUser,
      'senderRole': senderRole,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
