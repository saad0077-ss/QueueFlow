import '../repositories/platform_support_repository.dart';

class UpdatePlatformTicketStatusUseCase {
  final PlatformSupportRepository repository;
  const UpdatePlatformTicketStatusUseCase(this.repository);

  Future<void> call({
    required String ticketId,
    required String status,
    String staffName = 'Platform Admin',
  }) {
    return repository.updateStatus(
      ticketId: ticketId,
      status: status,
      staffName: staffName,
    );
  }
}
