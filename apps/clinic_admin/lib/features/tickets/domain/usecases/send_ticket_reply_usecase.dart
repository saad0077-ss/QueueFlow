import '../repositories/clinic_support_repository.dart';

class SendTicketReplyUseCase {
  final ClinicSupportRepository repository;

  const SendTicketReplyUseCase(this.repository);

  Future<void> call({
    required String ticketId,
    required String text,
    required String staffName,
    bool isInternalNote = false,
  }) {
    return repository.sendReply(
      ticketId: ticketId,
      text: text,
      staffName: staffName,
      isInternalNote: isInternalNote,
    );
  }
}
