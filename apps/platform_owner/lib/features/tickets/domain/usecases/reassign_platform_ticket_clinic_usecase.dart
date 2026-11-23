import '../repositories/platform_support_repository.dart';

class ReassignPlatformTicketClinicUseCase {
  final PlatformSupportRepository repository;
  const ReassignPlatformTicketClinicUseCase(this.repository);

  Future<void> call({
    required String ticketId,
    required String newClinicId,
    required String newClinicName,
    required String adminName,
  }) {
    return repository.reassignClinic(
      ticketId: ticketId,
      newClinicId: newClinicId,
      newClinicName: newClinicName,
      adminName: adminName,
    );
  }
}
