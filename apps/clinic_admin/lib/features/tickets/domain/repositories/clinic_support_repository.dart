import '../entities/clinic_support_ticket_entity.dart';

abstract class ClinicSupportRepository {
  Stream<List<ClinicSupportTicketEntity>> watchClinicTickets({
    required String clinicId,
    String? clinicName,
  });

  Future<void> sendReply({
    required String ticketId,
    required String text,
    required String staffName,
    bool isInternalNote = false,
  });

  Future<void> updateStatus({
    required String ticketId,
    required String status,
    String staffName = 'Clinic Admin',
  });

  Future<void> updatePriority({
    required String ticketId,
    required String priority,
  });

  Future<void> escalateTicket({
    required String ticketId,
    required String staffName,
  });

  Future<ClinicSupportTicketEntity> createManualTicket({
    required String clinicId,
    required String clinicName,
    required String patientName,
    required String patientPhone,
    String? patientEmail,
    String? tokenNumber,
    required String category,
    required String priority,
    required String subject,
    required String description,
  });
}
