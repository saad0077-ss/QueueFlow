import '../entities/support_ticket_entity.dart';
import '../repositories/profile_repository.dart';

class GetSupportTicketsUseCase {
  final ProfileRepository repository;
  GetSupportTicketsUseCase(this.repository);

  Future<List<SupportTicketEntity>> call() => repository.getSupportTickets();
}

class CreateSupportTicketUseCase {
  final ProfileRepository repository;
  CreateSupportTicketUseCase(this.repository);

  Future<SupportTicketEntity> call({
    required String clinicId,
    required String clinicName,
    required String category,
    required String subject,
    required String description,
    String priority = 'medium',
    String? linkedTokenNumber,
    bool isClinicRelated = true,
  }) {
    return repository.createSupportTicket(
      clinicId: clinicId,
      clinicName: clinicName,
      category: category,
      subject: subject,
      description: description,
      priority: priority,
      linkedTokenNumber: linkedTokenNumber,
      isClinicRelated: isClinicRelated,
    );
  }
}

class SendTicketReplyUseCase {
  final ProfileRepository repository;
  SendTicketReplyUseCase(this.repository);

  Future<SupportTicketEntity> call({
    required String ticketId,
    required String text,
    required String senderName,
    String senderRole = 'patient',
  }) {
    return repository.sendTicketReply(
      ticketId: ticketId,
      text: text,
      senderName: senderName,
      senderRole: senderRole,
    );
  }
}

class WatchSupportTicketsUseCase {
  final ProfileRepository repository;
  WatchSupportTicketsUseCase(this.repository);

  Stream<List<SupportTicketEntity>> call() => repository.watchSupportTickets();
}

class UpdateTicketStatusUseCase {
  final ProfileRepository repository;
  UpdateTicketStatusUseCase(this.repository);

  Future<void> call(String ticketId, String status) =>
      repository.updateTicketStatus(ticketId, status);
}

class RateTicketUseCase {
  final ProfileRepository repository;
  RateTicketUseCase(this.repository);

  Future<void> call(String ticketId, int rating) =>
      repository.rateTicket(ticketId, rating);
}
