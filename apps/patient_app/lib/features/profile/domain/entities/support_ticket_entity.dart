import 'package:equatable/equatable.dart';

class TicketMessageEntity extends Equatable {
  final String sender;
  final String text;
  final String time;
  final bool isUser;

  const TicketMessageEntity({
    required this.sender,
    required this.text,
    required this.time,
    required this.isUser,
  });

  @override
  List<Object?> get props => [sender, text, time, isUser];
}

class SupportTicketEntity extends Equatable {
  final String id;
  final String clinicId;
  final String clinicName;
  final String category;
  final String subject;
  final String description;
  final String status; // 'open', 'in_progress', 'resolved'
  final String priority;
  final String createdAt;
  final String slaNotice;
  final List<TicketMessageEntity> messages;

  const SupportTicketEntity({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.slaNotice,
    required this.messages,
  });

  SupportTicketEntity copyWith({
    String? id,
    String? clinicId,
    String? clinicName,
    String? category,
    String? subject,
    String? description,
    String? status,
    String? priority,
    String? createdAt,
    String? slaNotice,
    List<TicketMessageEntity>? messages,
  }) {
    return SupportTicketEntity(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      slaNotice: slaNotice ?? this.slaNotice,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clinicId,
        clinicName,
        category,
        subject,
        description,
        status,
        priority,
        createdAt,
        slaNotice,
        messages,
      ];
}
