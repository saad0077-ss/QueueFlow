import '../entities/active_ticket_entity.dart';
import '../repositories/home_repository.dart';

class JoinQueueUseCase {
  final HomeRepository repository;

  JoinQueueUseCase(this.repository);

  Future<ActiveTicketEntity> call({
    required String clinicId,
    required String clinicName,
    required String patientName,
    required int currentWaitingCount,
    required String currentToken,
  }) {
    return repository.joinQueue(
      clinicId: clinicId,
      clinicName: clinicName,
      patientName: patientName,
      currentWaitingCount: currentWaitingCount,
      currentToken: currentToken,
    );
  }
}
