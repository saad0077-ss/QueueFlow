import 'package:equatable/equatable.dart';

class TicketMessageEntity extends Equatable {
  final String sender;
  final String text;
  final String time;
  final bool isUser;
  final String senderRole;
  final DateTime? createdAt;

  const TicketMessageEntity({
    required this.sender,
    required this.text,
    required this.time,
    required this.isUser,
    this.senderRole = 'patient',
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    sender,
    text,
    time,
    isUser,
    senderRole,
    createdAt,
  ];
}
