import '../repositories/clinic_support_repository.dart';

class UpdateTicketStatusUseCase {
  final ClinicSupportRepository repository;

  const UpdateTicketStatusUseCase(this.repository);

  Future<void> call({
    required String ticketId,
    required String status,
    String staffName = 'Clinic Admin',
  }) {
    return repository.updateStatus(
      ticketId: ticketId,
      status: status,
      staffName: staffName,
    );
  }
}
