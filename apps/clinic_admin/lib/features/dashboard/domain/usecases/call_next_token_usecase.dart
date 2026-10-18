import '../repositories/clinic_dashboard_repository.dart';

/// Use case to call the next patient token in queue.
class CallNextTokenUseCase {
  final ClinicDashboardRepository repository;

  const CallNextTokenUseCase(this.repository);

  Future<void> call(int totalIssued) {
    return repository.callNextToken(totalIssued);
  }
}
