import '../entities/active_ticket_entity.dart';
import '../entities/clinic_entity.dart';

abstract class HomeRepository {
  /// Fetches real clinics from the Firestore database.
  Future<List<ClinicEntity>> getFeaturedClinics();

  /// Watches live clinic updates from the Firestore database.
  Stream<List<ClinicEntity>> watchFeaturedClinics();

  /// Fetches the user's active live queue ticket if any.
  Future<ActiveTicketEntity?> getActiveTicket();

  /// Joins a clinic's live queue.
  Future<ActiveTicketEntity> joinQueue({
    required String clinicId,
    required String clinicName,
    required String patientName,
    required int currentWaitingCount,
    required String currentToken,
  });

  /// Cancels an active ticket.
  Future<void> cancelTicket(String ticketId);
}
