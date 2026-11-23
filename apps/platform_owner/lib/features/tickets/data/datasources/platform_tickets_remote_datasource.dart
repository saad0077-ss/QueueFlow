import '../models/platform_support_ticket_model.dart';

abstract class PlatformTicketsRemoteDataSource {
  Stream<List<PlatformSupportTicketModel>> watchAllTickets();

  Future<void> sendReply({
    required String ticketId,
    required String text,
    required String senderName,
    bool isInternalNote = false,
  });

  Future<void> updateStatus({
    required String ticketId,
    required String status,
    String staffName = 'Platform Admin',
  });

  Future<void> updatePriority({
    required String ticketId,
    required String priority,
  });

  Future<void> reassignClinic({
    required String ticketId,
    required String newClinicId,
    required String newClinicName,
    required String adminName,
  });

  Future<void> deleteTicket({required String ticketId});
}
