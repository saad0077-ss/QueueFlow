import '../../domain/entities/clinic_support_ticket_entity.dart';
import '../../domain/repositories/clinic_support_repository.dart';
import '../datasources/clinic_tickets_remote_datasource.dart';
import '../datasources/clinic_tickets_remote_datasource_impl.dart';

class ClinicSupportRepositoryImpl implements ClinicSupportRepository {
  final ClinicTicketsRemoteDataSource _remoteDataSource;

  ClinicSupportRepositoryImpl({ClinicTicketsRemoteDataSource? remoteDataSource})
    : _remoteDataSource =
          remoteDataSource ?? ClinicTicketsRemoteDataSourceImpl();

  @override
  Stream<List<ClinicSupportTicketEntity>> watchClinicTickets({
    required String clinicId,
    String? clinicName,
  }) {
    return _remoteDataSource.watchTickets(
      clinicId: clinicId,
      clinicName: clinicName,
    );
  }

  @override
  Future<void> sendReply({
    required String ticketId,
    required String text,
    required String staffName,
    bool isInternalNote = false,
  }) {
    return _remoteDataSource.sendReply(
      ticketId: ticketId,
      text: text,
      staffName: staffName,
      isInternalNote: isInternalNote,
    );
  }

  @override
  Future<void> updateStatus({
    required String ticketId,
    required String status,
    String staffName = 'Clinic Admin',
  }) {
    return _remoteDataSource.updateStatus(
      ticketId: ticketId,
      status: status,
      staffName: staffName,
    );
  }

  @override
  Future<void> updatePriority({
    required String ticketId,
    required String priority,
  }) {
    return _remoteDataSource.updatePriority(
      ticketId: ticketId,
      priority: priority,
    );
  }

  @override
  Future<void> escalateTicket({
    required String ticketId,
    required String staffName,
  }) {
    return _remoteDataSource.escalateTicket(
      ticketId: ticketId,
      staffName: staffName,
    );
  }

  @override
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
  }) {
    return _remoteDataSource.createManualTicket(
      clinicId: clinicId,
      clinicName: clinicName,
      patientName: patientName,
      patientPhone: patientPhone,
      patientEmail: patientEmail,
      tokenNumber: tokenNumber,
      category: category,
      priority: priority,
      subject: subject,
      description: description,
    );
  }
}
