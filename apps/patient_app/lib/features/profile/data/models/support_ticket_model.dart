import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/support_ticket_entity.dart';

class TicketMessageModel extends TicketMessageEntity {
  const TicketMessageModel({
    required super.sender,
    required super.text,
    required super.time,
    required super.isUser,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      sender: json['sender'] as String? ?? '',
      text: json['text'] as String? ?? '',
      time: json['time'] as String? ?? 'Just now',
      isUser: json['isUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
      'time': time,
      'isUser': isUser,
    };
  }
}

class SupportTicketModel extends SupportTicketEntity {
  const SupportTicketModel({
    required super.id,
    required super.clinicId,
    required super.clinicName,
    required super.category,
    required super.subject,
    required super.description,
    required super.status,
    required super.priority,
    required super.createdAt,
    required super.slaNotice,
    required super.messages,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    final messages = rawMessages.map((m) => TicketMessageModel.fromJson(m as Map<String, dynamic>)).toList();

    return SupportTicketModel(
      id: docId ?? json['id'] as String? ?? 'TKT-104',
      clinicId: json['clinicId'] as String? ?? 'sunrise-health',
      clinicName: json['clinicName'] as String? ?? 'Sunrise Health Clinic',
      category: json['category'] as String? ?? 'queue',
      subject: json['subject'] as String? ?? 'Queue slot reschedule query',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'in_progress',
      priority: json['priority'] as String? ?? 'medium',
      createdAt: json['createdAt'] as String? ?? 'Today, 10:15 AM',
      slaNotice: json['slaNotice'] as String? ?? 'Est. SLA: Resolution within 2 hrs',
      messages: messages.isNotEmpty
          ? messages
          : [
              const TicketMessageModel(
                sender: 'Aisha Rahman',
                text: 'Can I defer my afternoon queue slot by 30 mins due to commute delay?',
                time: '10:15 AM',
                isUser: true,
              ),
              const TicketMessageModel(
                sender: 'Clinic Front Desk (Anu)',
                text: 'Hello Aisha! Yes, we have applied a 25-minute buffer to Token A-024. See you soon.',
                time: '10:22 AM',
                isUser: false,
              ),
            ],
    );
  }

  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return SupportTicketModel.fromJson(data, docId: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'category': category,
      'subject': subject,
      'description': description,
      'status': status,
      'priority': priority,
      'createdAt': createdAt,
      'slaNotice': slaNotice,
      'messages': messages.map((m) {
        if (m is TicketMessageModel) return m.toJson();
        return {
          'sender': m.sender,
          'text': m.text,
          'time': m.time,
          'isUser': m.isUser,
        };
      }).toList(),
    };
  }

  static List<SupportTicketModel> get defaultTickets => [
        const SupportTicketModel(
          id: 'TKT-104',
          clinicId: 'sunrise-health',
          clinicName: 'Sunrise Health Clinic',
          category: 'queue',
          subject: 'Queue slot reschedule query',
          description: 'Can I defer my afternoon queue slot by 30 mins due to commute delay?',
          status: 'in_progress',
          priority: 'medium',
          createdAt: 'Today, 10:15 AM',
          slaNotice: 'Est. SLA: Resolution within 2 hrs',
          messages: [
            TicketMessageModel(
              sender: 'Aisha Rahman',
              text: 'Can I defer my afternoon queue slot by 30 mins due to commute delay?',
              time: '10:15 AM',
              isUser: true,
            ),
            TicketMessageModel(
              sender: 'Clinic Front Desk (Anu)',
              text: 'Hello Aisha! Yes, we have applied a 25-minute buffer to Token A-024. See you soon.',
              time: '10:22 AM',
              isUser: false,
            ),
          ],
        ),
        const SupportTicketModel(
          id: 'TKT-098',
          clinicId: 'smile-dental',
          clinicName: 'Smile Dental Clinic',
          category: 'billing',
          subject: 'Digital invoice copy requested',
          description: 'Please email the tax invoice for the teeth cleaning procedure.',
          status: 'resolved',
          priority: 'low',
          createdAt: '12 Jun 2026',
          slaNotice: 'Resolved on 12 Jun 2026',
          messages: [
            TicketMessageModel(
              sender: 'Aisha Rahman',
              text: 'Please send an itemized invoice for dental insurance claim.',
              time: '12 Jun, 2:00 PM',
              isUser: true,
            ),
            TicketMessageModel(
              sender: 'Smile Dental Accounts',
              text: 'Sent the PDF receipt to aisha.rahman@email.com with ARN ref.',
              time: '12 Jun, 2:45 PM',
              isUser: false,
            ),
          ],
        ),
      ];
}
