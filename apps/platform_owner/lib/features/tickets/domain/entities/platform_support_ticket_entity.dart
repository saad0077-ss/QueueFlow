import 'package:equatable/equatable.dart';

import 'platform_ticket_message_entity.dart';

export 'platform_ticket_message_entity.dart';

class PlatformSupportTicketEntity extends Equatable {
  final String id;
  final String ticketNumber;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String patientPhoto;
  final String clinicId;
  final String clinicName;
  final bool isClinicRelated;
  final String? linkedTokenNumber;
  final String category;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final int slaMinutes;
  final String slaNotice;
  final String? assignedTo;
  final String? resolvedAt;
  final bool isEscalated;
  final String createdAt;
  final DateTime? createdAtDate;
  final List<PlatformTicketMessage> messages;

  const PlatformSupportTicketEntity({
    required this.id,
    required this.ticketNumber,
    this.patientId = '',
    required this.patientName,
    this.patientEmail = '',
    this.patientPhone = '',
    this.patientPhoto = '',
    required this.clinicId,
    required this.clinicName,
    this.isClinicRelated = true,
    this.linkedTokenNumber,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    this.slaMinutes = 15,
    this.slaNotice = '< 15m SLA',
    this.assignedTo,
    this.resolvedAt,
    this.isEscalated = false,
    required this.createdAt,
    this.createdAtDate,
    required this.messages,
  });

  PlatformSupportTicketEntity copyWith({
    String? id,
    String? ticketNumber,
    String? patientId,
    String? patientName,
    String? patientEmail,
    String? patientPhone,
    String? patientPhoto,
    String? clinicId,
    String? clinicName,
    bool? isClinicRelated,
    String? linkedTokenNumber,
    String? category,
    String? subject,
    String? description,
    String? status,
    String? priority,
    int? slaMinutes,
    String? slaNotice,
    String? assignedTo,
    String? resolvedAt,
    bool? isEscalated,
    String? createdAt,
    DateTime? createdAtDate,
    List<PlatformTicketMessage>? messages,
  }) {
    return PlatformSupportTicketEntity(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      patientPhone: patientPhone ?? this.patientPhone,
      patientPhoto: patientPhoto ?? this.patientPhoto,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      isClinicRelated: isClinicRelated ?? this.isClinicRelated,
      linkedTokenNumber: linkedTokenNumber ?? this.linkedTokenNumber,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      slaMinutes: slaMinutes ?? this.slaMinutes,
      slaNotice: slaNotice ?? this.slaNotice,
      assignedTo: assignedTo ?? this.assignedTo,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      isEscalated: isEscalated ?? this.isEscalated,
      createdAt: createdAt ?? this.createdAt,
      createdAtDate: createdAtDate ?? this.createdAtDate,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ticketNumber,
    patientId,
    patientName,
    patientEmail,
    patientPhone,
    patientPhoto,
    clinicId,
    clinicName,
    isClinicRelated,
    linkedTokenNumber,
    category,
    subject,
    description,
    status,
    priority,
    slaMinutes,
    slaNotice,
    assignedTo,
    resolvedAt,
    isEscalated,
    createdAt,
    createdAtDate,
    messages,
  ];
}
