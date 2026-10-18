import '../entities/active_ticket_entity.dart';
import '../entities/clinic_entity.dart';

abstract class HomeRepository {
  Future<List<ClinicEntity>> getFeaturedClinics();

  Future<ActiveTicketEntity?> getActiveTicket();

  Future<ActiveTicketEntity> joinQueue({
    required String clinicId,
    required String clinicName,
    required String patientName,
    required int currentWaitingCount,
    required String currentToken,
  });

  Future<void> cancelTicket(String ticketId);
}
