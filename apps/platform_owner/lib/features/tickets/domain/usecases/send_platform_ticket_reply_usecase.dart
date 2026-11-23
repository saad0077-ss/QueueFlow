import '../repositories/platform_support_repository.dart';

class SendPlatformTicketReplyUseCase {
  final PlatformSupportRepository repository;
  const SendPlatformTicketReplyUseCase(this.repository);

  Future<void> call({
    required String ticketId,
    required String text,
    required String senderName,
    bool isInternalNote = false,
  }) {
    return repository.sendReply(
      ticketId: ticketId,
      text: text,
      senderName: senderName,
      isInternalNote: isInternalNote,
    );
  }
}
