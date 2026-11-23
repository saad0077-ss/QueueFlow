import 'package:equatable/equatable.dart';

class PlatformTicketMessage extends Equatable {
  final String sender;
  final String senderRole;
  final String text;
  final String time;
  final bool isUser;
  final bool isInternalNote;
  final DateTime? createdAt;

  const PlatformTicketMessage({
    required this.sender,
    this.senderRole = 'platform_owner',
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
