import '../repositories/clinic_dashboard_repository.dart';

/// Use case to issue a new walk-in patient token.
class IssueWalkInTokenUseCase {
  final ClinicDashboardRepository repository;

  const IssueWalkInTokenUseCase(this.repository);

  Future<void> call(int totalIssued, int waitingCount) {
    return repository.issueWalkInToken(totalIssued, waitingCount);
  }
}
