import 'package:equatable/equatable.dart';

class ClinicTicketMessage extends Equatable {
  final String sender;
  final String senderRole;
  final String text;
  final String time;
  final bool isUser;
  final bool isInternalNote;
  final DateTime? createdAt;

  const ClinicTicketMessage({
    required this.sender,
    this.senderRole = 'clinic_admin',
    required this.text,
    required this.time,
    required this.isUser,
    this.isInternalNote = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    sender,
    senderRole,
    text,
    time,
    isUser,
    isInternalNote,
    createdAt,
  ];
}
