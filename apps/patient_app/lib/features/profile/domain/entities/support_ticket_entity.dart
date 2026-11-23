import 'package:equatable/equatable.dart';

import 'ticket_message_entity.dart';

export 'ticket_message_entity.dart';

class SupportTicketEntity extends Equatable {
  final String id;
  final String ticketNumber;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String clinicId;
  final String clinicName;
  final bool isClinicRelated;
  final String? linkedTokenNumber;
  final String category;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final String createdAt;
  final DateTime? createdAtDate;
  final DateTime? updatedAtDate;
  final String slaNotice;
  final int slaMinutes;
  final int? rating;
  final String? assignedTo;
  final String? resolvedAt;
  final List<TicketMessageEntity> messages;

  const SupportTicketEntity({
    required this.id,
    String? ticketNumber,
    this.patientId = '',
    this.patientName = '',
    this.patientEmail = '',
    this.patientPhone = '',
    required this.clinicId,
    required this.clinicName,
    this.isClinicRelated = true,
    this.linkedTokenNumber,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.createdAtDate,
    this.updatedAtDate,
    required this.slaNotice,
    this.slaMinutes = 15,
    this.rating,
    this.assignedTo,
    this.resolvedAt,
    required this.messages,
  }) : ticketNumber = ticketNumber ?? id;

  SupportTicketEntity copyWith({
    String? id,
    String? ticketNumber,
    String? patientId,
    String? patientName,
    String? patientEmail,
    String? patientPhone,
    String? clinicId,
    String? clinicName,
    bool? isClinicRelated,
    String? linkedTokenNumber,
    String? category,
    String? subject,
    String? description,
    String? status,
    String? priority,
    String? createdAt,
    DateTime? createdAtDate,
    DateTime? updatedAtDate,
    String? slaNotice,
    int? slaMinutes,
    int? rating,
    String? assignedTo,
    String? resolvedAt,
    List<TicketMessageEntity>? messages,
  }) {
    return SupportTicketEntity(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      patientPhone: patientPhone ?? this.patientPhone,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      isClinicRelated: isClinicRelated ?? this.isClinicRelated,
      linkedTokenNumber: linkedTokenNumber ?? this.linkedTokenNumber,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      createdAtDate: createdAtDate ?? this.createdAtDate,
      updatedAtDate: updatedAtDate ?? this.updatedAtDate,
      slaNotice: slaNotice ?? this.slaNotice,
      slaMinutes: slaMinutes ?? this.slaMinutes,
      rating: rating ?? this.rating,
      assignedTo: assignedTo ?? this.assignedTo,
      resolvedAt: resolvedAt ?? this.resolvedAt,
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
    clinicId,
    clinicName,
    isClinicRelated,
    linkedTokenNumber,
    category,
    subject,
    description,
    status,
    priority,
    createdAt,
    createdAtDate,
    updatedAtDate,
    slaNotice,
    slaMinutes,
    rating,
    assignedTo,
    resolvedAt,
    messages,
  ];
}
