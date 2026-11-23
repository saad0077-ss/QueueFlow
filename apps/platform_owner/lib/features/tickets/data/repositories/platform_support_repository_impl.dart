import '../../domain/entities/platform_support_ticket_entity.dart';
import '../../domain/repositories/platform_support_repository.dart';
import '../datasources/platform_tickets_remote_datasource.dart';
import '../datasources/platform_tickets_remote_datasource_impl.dart';

class PlatformSupportRepositoryImpl implements PlatformSupportRepository {
  final PlatformTicketsRemoteDataSource _remoteDataSource;

  PlatformSupportRepositoryImpl({
    PlatformTicketsRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? PlatformTicketsRemoteDataSourceImpl();

  @override
  Stream<List<PlatformSupportTicketEntity>> watchAllTickets() {
    return _remoteDataSource.watchAllTickets();
  }

  @override
  Future<void> sendReply({
    required String ticketId,
    required String text,
    required String senderName,
    bool isInternalNote = false,
  }) {
    return _remoteDataSource.sendReply(
      ticketId: ticketId,
      text: text,
      senderName: senderName,
      isInternalNote: isInternalNote,
    );
  }

  @override
  Future<void> updateStatus({
    required String ticketId,
    required String status,
    String staffName = 'Platform Admin',
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
  Future<void> reassignClinic({
    required String ticketId,
    required String newClinicId,
    required String newClinicName,
    required String adminName,
  }) {
    return _remoteDataSource.reassignClinic(
      ticketId: ticketId,
      newClinicId: newClinicId,
      newClinicName: newClinicName,
      adminName: adminName,
    );
  }

  @override
  Future<void> deleteTicket({required String ticketId}) {
    return _remoteDataSource.deleteTicket(ticketId: ticketId);
  }
}
